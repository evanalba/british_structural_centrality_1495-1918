function obs = Royal_import
%% This function outputs the basic set of observations with simple covariates.  This includes:
%  Index: Country 1 ID, Country 2 ID, Year, Ruler 1 ID, Ruler 2 ID, War_ID
%  Simple Covariates: log(Capital distance), Same Religious Group dummy, 
%                     Both Landlocked dummy, Adjacency dummy, Either Hapsburg dummy
%  Outcome dummies:  War, Any war
%
%%  Wars.csv and Rulers.csv files are required to be in the working directory.
%%

Rulers=csvread('Rulers.csv',1);
Rulers=Rulers(:,1:14);
Adj=csvread('Rulers.csv');
Adj=Adj(:,[[1:4] [15:end]]);
C2_list=Adj(1,5:end)';

% Rulers includes: Country ID, Ruler ID, Rule Start, Rule End
% and member of dummies for: HRE,GC,NGC,Habsburg, and Spanish Empire
% and  covariates: capital latitude, capital longitude, 
% Religious group, Landlocked dummy, Habsburg Dynasty dummy

Countries=unique(Rulers(:,1));


Countries=[Countries zeros(length(Countries),2)];

i=0;

for cid = unique(Rulers(:,1))'
    i=i+1;
    
    Countries(i,2:3)=[min(Rulers(Rulers(:,1)==cid ,3))...
                      max(Rulers(Rulers(:,1)==cid ,4))];
end

obs=zeros(110000,10); %Columns for index variables and simple covariates

%Add Country pairs and year to observation list

i1=0;
j=0;

for C1 = unique(Rulers(:,1))'
    i1=i1+1;
    i2=0;
    for C2 = unique(Rulers(:,1))'
        i2=i2+1;
     if C2>C1
         for year=1495:1918
             if year>=max(Countries(i1,2),Countries(i2,2))&...
                year<=min(Countries(i1,3),Countries(i2,3))     
                
                j=j+1;
         
                obs(j,1:3)=[C1 C2 year];
             end
         end
     end
    end
end


%Fill in Ruler info
for i=1:length(obs)

try    %A year's ruler is determined by year end ruler (ie new rulers are backdated to jan 1)
R1= Rulers(Rulers(:,1)==obs(i,1) & Rulers(:,3)<=obs(i,3) &...
                 Rulers(:,4)>=obs(i,3) ,2);    

             obs(i,4)= R1(end);  %If multiple listings use first one
end
try
R2= Rulers(Rulers(:,1)==obs(i,2) & Rulers(:,3)<=obs(i,3) &...
                 Rulers(:,4)>=obs(i,3) ,2); 
             
             obs(i,5)=R2(end);

end
end

%Drop observation if missing Rulers (or year or country ID)
obs=obs(all(obs(:,1:5),2),:);

%Fill in Covariates
for i=1:length(obs)

    C1   = obs(i,1);    
    C2   = obs(i,2);
    year = obs(i,3);
    R1   = obs(i,4);    
    R2   = obs(i,5);
    
    try    
    cov1= Rulers(Rulers(:,1)==C1 & Rulers(:,3)<=year &...
                 Rulers(:,4)>=year ,10:14);   

             cov1= cov1(end,:);  %If multiple listings use last one
    end
    try    
    cov2= Rulers(Rulers(:,1)==C2 & Rulers(:,3)<=year &...
                 Rulers(:,4)>=year ,10:14);   

             cov2= cov2(end,:);  %If multiple listings use last one
    end
    
    % Capital distance in log(kilometers)
    obs(i,6)= log(lldistkm([cov1(1) cov1(2)],[cov2(1) cov2(2)]));
    
    % Same Religion
    if cov1(3)==cov2(3)
        obs(i,7)=1;
    else
        obs(i,7)=0;
    end
    
    % Landlocked
    if cov1(4)==cov2(4)
        obs(i,8)=1;
    else
        obs(i,8)=0;
    end

   %Add adjacency dummy

    try
    obs(i,9)= max(Adj(Adj(:,1)==C1 & Adj(:,3)<=year & Adj(:,4)>=year,...
              4+find(C2_list==C2)));
    catch
    obs(i,9)=NaN;
    end


   % either Habsburg dummy
    if max(cov1(5),cov2(5))==1
        obs(i,10)=1;
    else
        obs(i,10)=0;
    end   
end


%% Wars Data
% Adjust war list for posses/coalitions

wars=csvread('Wars.csv',1); % wars includes: C1, C2, year, 
                          % fractured dummies for 
                          % HRE,GC,NGC, Spanish Empire, and Austria
                          
                          

posse_wars=wars(:,[1:3 end]);

for i=1:length(wars)

C1=wars(i,1);
C2=wars(i,2);
year=wars(i,3);

war_id=wars(i,end);

% Add coalition members to wars  (9/8/17...earlier versions had Spanish and Austrian Coalition switched)

% Spanish Posse
if C1==375 & wars(i,7)==0  
        

       minions=Rulers(Rulers(:,3)<=year & Rulers(:,4)>=year &...
                      Rulers(:,9)==1,1); %List of members
	for m=minions'
       posse_wars=[posse_wars;[C2 m year war_id]];
	end


    end
  
if C2==375 & wars(i,7)==0  

       minions=Rulers(Rulers(:,3)<=year & Rulers(:,4)>=year &...
                      Rulers(:,9)==1,1); %List of members
                  
	for m=minions'
       posse_wars=[posse_wars;[C1 m year war_id]];
	end
    end

%For Austrian posse  
    if C1==216 & wars(i,8)==0  

       minions=Rulers(Rulers(:,3)<=year & Rulers(:,4)>=year &...
                      Rulers(:,8)==1,1); %List of members
                  
	for m=minions'
       posse_wars=[posse_wars;[C2 m year war_id]];
	end
    end
    
    if C2==216 & wars(i,8)==0  

       minions=Rulers(Rulers(:,3)<=year & Rulers(:,4)>=year &...
                      Rulers(:,8)==1,1); %List of members
	for m=minions'
       posse_wars=[posse_wars;[C1 m year war_id]];
	end
    end


%For  HRE/GC/NGC posse    
    if C1==379 & ~any(wars(i,4:6)) 
        
       minions=Rulers(Rulers(:,3)<=year & Rulers(:,4)>=year &...
                      max(Rulers(:,5:7),[],2)==1,1); %List of members
                  
	for m=minions'
       posse_wars=[posse_wars;[C2 m year war_id]];
	end
    end

    if C2==379 & ~any(wars(i,4:6))
         
       minions=Rulers(Rulers(:,3)<=year & Rulers(:,4)>=year &...
                      max(Rulers(:,5:7),[],2)==1,1); %List of members
                  
	for m=minions'
       posse_wars=[posse_wars;[C1 m year war_id]];
	end
    end

                  
        
end


% Add war_id, battle deaths and dummies for war and any_war to obs

obs=[obs zeros(length(obs),4)];

wars=posse_wars;


for i=1:length(wars)

%Put smallest country ID first (ie ensure C1<C2)
    
wars(i,1:2)=[min(wars(i,1),wars(i,2)), max(wars(i,1),wars(i,2))];

C1=wars(i,1);
C2=wars(i,2);
year=wars(i,3);
war_id=wars(i,4);

% Make war dummy

    obs(ismember(obs(:,1:3),[C1 C2 year],'rows'),end-3)=1;
    obs(ismember(obs(:,1:3),[C1 C2 year],'rows'),end-1)=war_id;

end

% Make any_war dummy

obs(ismember(obs(:,[1 3]), [wars(:, [1 3]); wars(:,[2 3])],'rows'),end-2)=1;
obs(ismember(obs(:,[2 3]), [wars(:, [1 3]); wars(:,[2 3])],'rows'),end-2)=1;


battle=csvread('BattleDeaths.csv',1);

for i=1:length(battle)
    
obs(obs(:,end-1)==battle(i,1),end)=battle(i,2);

end

csvwrite('obs.csv',obs);


end
    
    


        

