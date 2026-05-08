function [net,dates]=royalnet
tic

%Generate target network matrix

dates=csvread('dates.csv',1);
dates=dates(dates(:,2)<=1920 & dates(:,3)>=1400,:);
dates=dates(dates(:,2)~=0,:);


net=zeros(length(dates));

fam=csvread('families.csv',1);

%Populate Network Adjacency Matrix

for i=1:length(fam) %Each family
    for j=1:size(fam,2) %Each family member
        
    %Person ID
    
    person=fam(i,j); %Look at person j in family i
    
        if person>0
       
            % Connect with all family members
    
            for k=1:size(fam,2)
    
            fam_mem=fam(i,k);
        
                if fam_mem>0 && fam_mem~=person 
                    net(find(dates(:,1)==person),find(dates(:,1)==fam_mem))=1;
                    net(find(dates(:,1)==fam_mem),find(dates(:,1)==person))=1;
                end
            end
        end
    end
end

clearvars -except net dates;

save net;

toc

end
