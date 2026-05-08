function res = resistance(year)

obs=csvread('obs_net.csv');

load('net.mat') %Gets adjacency matrix (net) and list of ID, birth, death (dates)

obs=obs(:,1:5);

net_y=net(dates(:,2)<=year & dates(:,3)>=year,dates(:,2)<=year & dates(:,3)>=year);

obs_y=obs(obs(:,3)==year,:);

ppl=dates(dates(:,2)<=year & dates(:,3)>=year,:);


D=diag(sum(net_y));

L=D-net_y;

Gamma=pinv(L);

res=zeros(length(obs_y),1);

for i = 1:length(res)
    
    try
    
    R1=find(ppl(:,1)==obs_y(i,4));
    R2=find(ppl(:,1)==obs_y(i,5));
    
    res(i,1)= Gamma(R1,R1)+Gamma(R2,R2)-2*Gamma(R1,R2);
    
    catch
        i
    end
end
end