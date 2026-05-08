%Import data (dates and families)

dates=csvread('dates.csv',1);
dates=dates(dates(:,2)<=1918 & dates(:,3)>=1200,:); %Include people before sample to get parentage of early rulers
dates=dates(dates(:,2)~=0,:);

family=csvread('families.csv',1);


%Generate directed acyclic graph (only connect kids TO parents)

famnet=sparse(length(dates),length(dates));

for i=1:length(family) %for each family

    for j=3:length(family(i,:)) %for child, j, in family i
    
    try   
    famnet(dates(:,1)==family(i,j),dates(:,1)==family(i,1))=1; %connect kid to father
    end
    
    try
    famnet(dates(:,1)==family(i,j),dates(:,1)==family(i,2))=1; %connect kid to mother
    end
    
    end
end
    
clear i j family
save famnet   