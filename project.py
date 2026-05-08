import re
import networkx as nx
import pandas as pd
import matplotlib.pyplot as plt

ged_path = "117045-V2/Replication-Code/00---Data-Collection/royal2014.GED"
xlsx_path = "117045-V2/Replication-Code/00---Data-Collection/Master Data.xlsx"
ruler_sheet = "Ruler+Adjacency"

UK_POLITY = "Kingdom of England/ England-Scotland/Great Britain/United Kingdom"

periods = [
    ("1495-1599", 1495, 1599),
    ("1600-1699", 1600, 1699),
    ("1700-1799", 1700, 1799),
    ("1800-1918", 1800, 1918),
]


"""
Build an undirected kinship graph from GEDCOM:
    - spouse edges (HUSB-WIFE)
    - parent-child edges (HUSB-CHIL, WIFE-CHIL)
Nodes are GED IDs, e.g., '@I625@'.
"""
def parse_gedcom_to_kin_graph(path):
    G = nx.Graph()
    fam_children = {}
    fam_parents = {}

    current_type = None
    fam_id = None

    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()

            m0 = re.match(r"^0\s+(@[IF]\d+@)\s+(\w+)", line)
            if m0:
                rec_id, rec_type = m0.group(1), m0.group(2)
                current_type = rec_type

                if rec_type == "FAM":
                    fam_id = rec_id
                    fam_children.setdefault(fam_id, [])
                    fam_parents.setdefault(fam_id, (None, None))
                else:
                    fam_id = None
                continue

            if current_type == "FAM" and fam_id:
                m_husb = re.match(r"^1\s+HUSB\s+(@I\d+@)", line)
                if m_husb:
                    husband = m_husb.group(1)
                    _, wife = fam_parents[fam_id]
                    fam_parents[fam_id] = (husband, wife)
                    G.add_node(husband)
                    continue

                m_wife = re.match(r"^1\s+WIFE\s+(@I\d+@)", line)
                if m_wife:
                    wife = m_wife.group(1)
                    husband, _ = fam_parents[fam_id]
                    fam_parents[fam_id] = (husband, wife)
                    G.add_node(wife)
                    continue

                m_chil = re.match(r"^1\s+CHIL\s+(@I\d+@)", line)
                if m_chil:
                    child = m_chil.group(1)
                    fam_children[fam_id].append(child)
                    G.add_node(child)
                    continue

    for fid, kids in fam_children.items():
        husband, wife = fam_parents.get(fid, (None, None))

        if husband and wife:
            G.add_edge(husband, wife, relation="spouse")

        for c in kids:
            if husband:
                G.add_edge(husband, c, relation="parent_child")
            if wife:
                G.add_edge(wife, c, relation="parent_child")

    return G


def to_ged_id(x):
    try:
        return f"@I{int(x)}@"
    except Exception:
        return None


def load_rulers(xlsx_path):
    df = pd.read_excel(xlsx_path, sheet_name=ruler_sheet)
    df["Rule Start Year"] = pd.to_numeric(df["Rule Start Year"], errors="coerce")
    df["Rule End Year"] = pd.to_numeric(df["Rule End Year"], errors="coerce")
    df["ged_id"] = df["Person ID"].apply(to_ged_id)
    return df


def overlaps_period(rule_start, rule_end, start, end):
    if pd.isna(rule_start) or pd.isna(rule_end):
        return False
    return (rule_end >= start) and (rule_start <= end)


"""
Nodes = ruler_ids
Edge between rulers i,j if connected in kinG

NOTE: how related are 2 rulers to each other = 1 / distance
"""
def build_weighted_ruler_network(kinG, ruler_ids):
    G = nx.Graph()
    G.add_nodes_from(ruler_ids)

    for idx, ruler_i in enumerate(ruler_ids):
        lengths = nx.single_source_shortest_path_length(kinG, ruler_i)
        for ruler_j in ruler_ids[idx + 1:]:
            d = lengths.get(ruler_j)
            if d is None:
                continue

            kinship_weight = 1.0 / d
            G.add_edge(ruler_i, ruler_j, distance=d, sim=kinship_weight, weight=kinship_weight)

    return G


def compute_centralities(G):
    nodes = list(G.nodes())
    weighted_degree = dict(G.degree(weight="weight"))
    eigen = nx.eigenvector_centrality(G, weight="weight")

    bet = nx.betweenness_centrality(G, weight="distance", normalized=True)
    clo = nx.closeness_centrality(G, distance="distance")

    return pd.DataFrame({
        "ged_id": nodes,
        "weighted_degree": [weighted_degree.get(n, 0.0) for n in nodes],
        "eigenvector": [eigen.get(n, 0.0) for n in nodes],
        "betweenness": [bet.get(n, 0.0) for n in nodes],
        "closeness": [clo.get(n, 0.0) for n in nodes],
    })


kinG = parse_gedcom_to_kin_graph(ged_path)
print(f"Nodes = {kinG.number_of_nodes():,} Edges = {kinG.number_of_edges():,}")

rulers = load_rulers(xlsx_path)

all_period_results = []
uk_summary_rows = []

for label, start, end in periods:
    print(f"\n=== Period {label} ===")

    period_rulers = rulers[
        rulers.apply(lambda r: overlaps_period(r["Rule Start Year"], r["Rule End Year"], start, end), axis=1)
    ].dropna(subset=["ged_id"]).copy()

    period_ids = [gid for gid in period_rulers["ged_id"].unique() if gid in kinG]
    print(f"Rulers in period (present in GED): {len(period_ids):,}")

    R = build_weighted_ruler_network(kinG, period_ids)
    print(f"Ruler network: nodes = {R.number_of_nodes():,} edges = {R.number_of_edges():,} components = {nx.number_connected_components(R):,}")

    centrality_df = compute_centralities(R)
    centrality_df["period"] = label

    ruler_metadata = period_rulers.drop_duplicates(subset=["ged_id"]).set_index("ged_id")
    centrality_df["country"] = centrality_df["ged_id"].map(lambda g: ruler_metadata.loc[g, "Country Name"] if g in ruler_metadata.index else None)
    centrality_df["dynasty"] = centrality_df["ged_id"].map(lambda g: ruler_metadata.loc[g, "Ruler Dynasty"] if g in ruler_metadata.index else None)
    centrality_df["is_british"] = centrality_df["country"] == UK_POLITY

    all_period_results.append(centrality_df)

    british = centrality_df[centrality_df["is_british"]]
    non = centrality_df[~centrality_df["is_british"]]

    for metric in ["weighted_degree", "eigenvector", "betweenness", "closeness"]:
        uk_summary_rows.append({
            "period": label,
            "metric": metric,
            "british_n": len(british),
            "nonbritish_n": len(non),
            "british_mean": british[metric].mean(),
            "british_median": british[metric].median(),
            "nonbritish_mean": non[metric].mean(),
            "nonbritish_median": non[metric].median(),
        })

british_summary = pd.DataFrame(uk_summary_rows)
out2 = "british_summary_by_period.csv"
british_summary.to_csv(out2, index=False)
print(f"Saved: {out2}")

plot_df = british_summary[british_summary["metric"] == "eigenvector"].copy()

plt.figure(figsize=(8, 5))
plt.plot(plot_df["period"], plot_df["british_mean"], marker="o", label="British mean", color="blue")
plt.plot(plot_df["period"], plot_df["nonbritish_mean"], marker="o", label="Non-British mean", color="red")
plt.title(f"Eigenvector centrality over time (British vs Non-British)")
plt.xlabel("Period")
plt.ylabel("Eigenvector")
plt.legend()
plt.xticks(rotation=20)
plt.tight_layout()
plt.show()

def plot_metric(british_summary, metric_name, title):
    plot_df = british_summary[british_summary["metric"] == metric_name].copy()

    plt.figure(figsize=(8, 5))

    plt.plot(
        plot_df["period"],
        plot_df["british_mean"],
        marker="o",
        color="blue",
        linestyle="-",
        label="British"
    )

    plt.plot(
        plot_df["period"],
        plot_df["nonbritish_mean"],
        marker="o",
        color="red",
        linestyle="-",
        label="Non-British"
    )

    plt.title(title)
    plt.xlabel("Period")
    plt.ylabel(metric_name.replace("_", " ").title())
    plt.legend()
    plt.xticks(rotation=20)
    plt.tight_layout()
    plt.show()
    
plot_metric(british_summary, "weighted_degree", "Weighted Degree centrality over time (British vs Non-British)")
plot_metric(british_summary, "betweenness", "Betweenness centrality over time (British vs Non-British)")
plot_metric(british_summary, "closeness", "Closeness centrality over time (British vs Non-British)")
