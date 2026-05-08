function bdeg = blooddist
%%
% For each observation, this lists max path distance to the pair of
% rulers' lowest common ancestor. (up to 5 generations)
%%
tic

%Import data 

load('famnet.mat') %loads dates and famnet (acyclic network with only links from 	           %kids to parents) Important to use this dates matrix with famnet!!
famnet=famnet; %Necessary to declare for parallel workers
dates=dates;

obs=csvread('obs.csv');
obs=obs(:,1:5);
%%

ruler_pairs=unique(obs(:,4:5),'rows');

bdeg_rp=cell(length(ruler_pairs),1);
bdeg=nan(length(obs),1);

parpool(12)

parfor row=1:length(ruler_pairs) %for each rulers_pair
    
gen=0;
bdeg_rp{row}=NaN;

R1=find(dates(:,1)==ruler_pairs(row,1)); %Ruler 1's network row
R2=find(dates(:,1)==ruler_pairs(row,2)); %Ruler 2's network row

anc_R1=R1;
anc_R2=R2;

if R1==R2
    bdeg_rp{row}=0;
end

while gen<=6 & R1~=R2
    
    gen=gen+1; %gen is generation depth
    
    
    %Generate list of R1's ancestors of depth "gen"

    for k=anc_R1'
    anc_R1=unique([anc_R1;find(famnet(k,:))']); 
    end
    
    %Generate list of R2's ancestors of depth "gen"
    
    for k=anc_R2'
    anc_R2=unique([anc_R2;find(famnet(k,:))']);
    end
    
    if ~isempty(intersect(anc_R1,anc_R2)) % Do ancestor lists overlap?
        bdeg_rp{row}=gen; %if so, print search depth.
        break
    end
end
end


for row=1:length(ruler_pairs)
    
bdeg(ismember(obs(:,4:5),ruler_pairs(row,:),'rows'))=bdeg_rp{row};

end

obs_blood=[obs bdeg];

csvwrite('obs_blood.csv',obs_blood);

toc
end
