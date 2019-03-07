clear all;
close all;
clc;

load('STUDY.mat');

erps = STUDY.ERP.data;
granderps = mean(erps,4);

time = STUDY.ERP.times(:,1);

subplot(1,3,1);
plot(time,granderps(52,:,1));
hold on;
plot(time,granderps(52,:,2));
hold off;
ylim([-2 16]);

dwerps = erps(:,:,1,:) - erps(:,:,2,:);
granddwerps = mean(dwerps,4);

subplot(1,3,2);
plot(time,granddwerps(52,:));
ylim([-2 16]);

[max, maxPosition] = max(granddwerps(52,:));

[maxp300Peaks, maxp300Times, maxP300Topos] = maxPeakDetection(dwerps,time,52,time(maxPosition),50);

[meanp300Peaks, meanp300Times, meanP300Topos] = meanPeakDetection(dwerps,time,52,time(maxPosition),20);

subplot(1,3,3);
topoData = mean(maxP300Topos,2);
chanlocs = STUDY.ERP.chanlocs{1};
topoplot(topoData,chanlocs,'verbose','off','style','fill','numcontour',8);