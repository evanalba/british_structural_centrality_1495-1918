third=csvread('thirdparty.csv',1);

obs=csvread('obs_net.csv');

obs=[obs zeros(length(obs),1)];

for i=1:length(obs)
    
% Set third party dummy equal 1 if an on-path death occured in 1) Neither
% dyad state and 2) Was not a member of either dyad's dynasty.    

if  obs(i,9)>0
 
deathID=obs(i,9);

associates=third(third(:,1)==deathID,2:end);

if isempty(intersect(obs(i,1:2),associates))
obs(i,end)=1;
end

end
end

csvwrite('obs_net2.csv',obs);

