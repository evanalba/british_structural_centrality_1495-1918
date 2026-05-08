%Load birth/death dates matching network data;
load('net.mat');

alive=[(1495:1918)', nan(1918-1495+1,1)];

for y=1:length(alive)
    year=y+1494;
    alive(y,2)=sum((dates(:,2)<=year).*(dates(:,3)>=year));
end

scatter(alive(:,1),alive(:,2));

set(gcf,'color','w');

title('People Alive In Sample By Year');

saveas(gcf,strcat(num2str(year),'.eps'),'epsc')


%Number of people alive in network data in median year = 872;

med=median(alive(:,2));

saveas(gcf,'alive','epsc')

fileID=fopen('alive.txt','w');
fprintf(fileID,'The genealogy has %d individuals alive in the median year. \n',med);


