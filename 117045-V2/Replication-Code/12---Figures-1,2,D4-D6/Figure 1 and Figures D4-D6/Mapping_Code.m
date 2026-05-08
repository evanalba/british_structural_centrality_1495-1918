% Add Land Masses

for year=[1500:50:1900, 1618, 1649, 1650, 1715, 1739,1913]


figure
hold on
worldmap([35 63],[-15 40]);
setm(gca,'MapProjection','mercator');
tightmap;
geoshow('landareas.shp','FaceColor',[.94 .95 .8]);


%Add Cities
rulers=csvread('Rulers.csv',1);
obs=csvread('obs_net2.csv');
obs_blood=csvread('obs_blood.csv');


r_y=rulers(rulers(:,3)<=year & rulers(:,4)>=year,[1 10:11]);


for i=1:length(r_y)

for j=1:length(r_y)

if obs(obs(:,1)==r_y(i,1) & obs(:,2)==r_y(j,1) & obs(:,3)==year,6)<50

plotm([r_y(i,2) r_y(j,2)],[r_y(i,3) r_y(j,3)],'Color', 'blue');

end
end

plotm(r_y(i,2),r_y(i,3), 'Marker', '.', 'MarkerSize', 25, 'Color', 'black');

end
saveas(gcf,strcat(num2str(year),'a.eps'),'epsc')


end


for year=[1500:50:1900, 1618, 1649, 1650, 1715, 1739,1913]

figure
hold on
worldmap([35 63],[-15 40]);
setm(gca,'MapProjection','mercator');
tightmap;
geoshow('landareas.shp','FaceColor',[.94 .95 .8]);


%Add Cities
rulers=csvread('Rulers.csv',1);
obs=csvread('obs_net2.csv');
obs_blood=csvread('obs_blood.csv');


r_y=rulers(rulers(:,3)<=year & rulers(:,4)>=year,[1 10:11]);


for i=1:length(r_y)

for j=1:length(r_y)

if obs_blood(obs_blood(:,1)==r_y(i,1) & obs_blood(:,2)==r_y(j,1) & obs_blood(:,3)==year,6)<4
    
plotm([r_y(i,2) r_y(j,2)],[r_y(i,3) r_y(j,3)],'Color', 'red');

end
end

plotm(r_y(i,2),r_y(i,3), 'Marker', '.', 'MarkerSize', 25, 'Color', 'black');

end
saveas(gcf,strcat(num2str(year),'b.eps'),'epsc')


end


 