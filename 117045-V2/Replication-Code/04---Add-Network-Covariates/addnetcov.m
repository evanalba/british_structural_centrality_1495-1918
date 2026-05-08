function [obsarray] = addnetcov
% ADDNETCOV  takes an obs file and adds
% 		shortest path length, pairwise degree (number of first degree 
%		connections), death, deathID, placebo_death, resistance dist, 
%%
tic
obs=csvread('obs.csv');
obs=obs(:,1:5);

%Loads net and dates
load('net.mat');
net=full(net);
dates=dates;

%Import ID, birth year, death year, and marriage dates
marriage=csvread('marriages.csv',1);
years=min(obs(:,3)):max(obs(:,3));

% add 6 columns for: path length, pair degree, 
% death, deathID, off-path death, resistance; 

obs=[obs zeros(length(obs),6)];
				   
net2=cell(1,size(years,2));
person=cell(1,size(years,2));



%array of future marriages
marr=cell(1,length(years));

for y=1:length(years)
    marr{y}=marriage(marriage(:,3)>=years(y),:);
    marr{y}=marr{y}(marr{y}(:,3)<max(years),:);
end




for y=1:length(years)

%  Row, ID, alive dummy   
alive=[(1:length(dates))' dates(:,1) (dates(:,2)<=years(y)).*(dates(:,3)>=years(y))];

%Shrink network to ppl alive
net2{y}=net(any(alive(:,3),2),:);
net2{y}=net2{y}(:,any(alive(:,3),2));


%person ID for each row of net2
person{y}=alive(any(alive(:,3),2),2);


%Remove spouse links before marriage

for j=1:length(marr{y})
    m=marr{y}(j,:);
    
    %If a living man has a future marriage unlink future wife in present   
    
    if ismember(m(:,1),person{y})     
               
     net2{y}(find(person{y}==m(1)),find(person{y}==m(2)))=0;
     net2{y}(find(person{y}==m(2)),find(person{y}==m(1)))=0;
                                      
    end
end

end


toc


%% Break obs into year-by-year array

obsarray=cell(1,length(years));

error_array=cell(1,length(years));

for y=1:length(years)    
obsarray{y}=obs(obs(:,3)==years(y),:);
end

pairsrow=cell(length(years),1);
pairs=cell(length(years),1);

%Generate ruler pairs by year
for y=1:length(years)

pairs{y}=obsarray{y}(:,4:5);
pairsrow{y}=obsarray{y}(:,4:5);

	for k=1:length(pairs{y})
		A=[find(person{y}==pairs{y}(k,1)) find(person{y}==pairs{y}(k,2))];
			
			if ~isempty(A) 
				pairsrow{y}(k,:)= A;
			else
				pairsrow{y}(k,:)= [0 0];    
			end
	end

end

toc

%%

parpool(12)

% Network calculations (Parallel processing by year)

parfor y=1:length(years)

%Shortest path, degree, deaths
for p=1:length(pairsrow{y})

            p1=pairsrow{y}(p,1);
            p2=pairsrow{y}(p,2);

        if p1*p2>0
	

        [dist,path]=graphshortestpath(sparse(net2{y}),p1,p2);

        newdist=dist;
        path=person{y}(path); %converts network position to person ID
        

	% Add dummy for off-path (placebo) deaths 
	% (1st degree connections who are not on path)

	imm_fam1=find(net2{y}(:,p1)==1);
	imm_fam1=person{y}(imm_fam1);  %converts network position to person ID
	imm_fam2=find(net2{y}(:,p2)==1);
	imm_fam2=person{y}(imm_fam2);  %converts network position to person ID
	
	if  any(ismember(setdiff(union(imm_fam1,imm_fam2),path),dates(dates(:,3)==years(y),1)))
	
	obsarray{y}(p,end-1)=1; % dummy for off-path death

	end
        

	%adds a 1 to column (end-3) of obs if on-path death
	%adds ID of deceased to column (end-2)


            if any(ismember( path,dates(dates(:,3)==years(y),1) ) )
                
            try
            deathID=min(path(ismember( path,dates(dates(:,3)==years(y),1))));
            obsarray{y}(p,[end-3 end-2])=[1 deathID];  %adds death and death ID
            
            catch
            obsarray{y}(p,end-2)= nan;
            end

            end

	%Add variables to obs
		
	%Sum of first degree connections of both rulers
	   obsarray{y}(p,end-4)=sum(net2{y}(:,p1))+ sum(net2{y}(:,p2));
	
	%Shortest path distance (pre death)
          obsarray{y}(p,end-5)=dist; 
        
        end

end

%Calculate Resistance Distance (before death)

res_dist=nan(length(obsarray{y}),1);

try        


        D=diag(sum(net2{y}));

        L=D-net2{y};

        Gamma=pinv(L);

        
        for i = 1:size(res_dist,1)
    
            try
    
            R1=find(person{y}==obsarray{y}(i,4));
            R2=find(person{y}==obsarray{y}(i,5));

            res_dist(i,end)= Gamma(R1,R1)+Gamma(R2,R2)-2*Gamma(R1,R2);
            end

        end
catch
disp('Resistance fail in year:')
disp(years(y))
end    
 
obsarray{y}(:,end)=res_dist;

end


obsout=obsarray{1};

for i=2:length(years)
obsout=[obsout;obsarray{i}];
end

save('obsdeg.mat','obsout');
csvwrite('obs_net.csv',obsout);

toc
end
