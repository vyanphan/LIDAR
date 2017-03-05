clear;
clf;
%find crossing of (min+max)/2
data = csvread('data.csv');
signal1 = data(:,1);
signal2 = data(:,2);
xRange = data(1,3);

max1 = max(signal1);
min1 = min(signal1);
max2 = max(signal2);
min2 = min(signal2);

mid1 = (abs(max1)+abs(min1)) / 3 + min1;
mid2 = (abs(max2)+abs(min2)) / 3 + min2;

idx1 = 1;
for i = 1:1000
    if signal1(i) < mid1
        idx1 = i;
    end
end
idx2 = 1;
for i = 1:1000
    if signal2(i) < mid2
        idx2 = i;
    end
end
diff = idx2-idx1
fprintf('precision: %d, crossing1: %i, crossing2: %i\n',xRange/1000, idx1, idx2);
time_diff = diff * xRange/1000;
%dlmwrite('time_diff.txt', time_diff, '-append');

%plot data signal vs time
data_points = size(signal1.');
x = linspace(-xRange/2,xRange/2,data_points(2));
plot(x,signal1,'b',x,signal2,'r')
y1=get(gca,'ylim');
x1 = x(idx1);
hold on
plot([x1 x1],y1, 'Color', 'b');

plot([x(idx2) x(idx2)],y1, 'Color', 'r');
hold off
ax = gca;
ax.XAxis.Exponent = -9;

xlabel('Time (s)'), ylabel('Voltage (V)'), title('Oscilloscope Data');
grid on, axis([-xRange/2, xRange/2, min(min1,min2)*1.25, max(max1, max2)*1.25]);

title('822mm bnc cable length difference')
mix = xcorr(signal1,signal2)/1000;
[largest, idx] = max(mix);
hold on;
plot(linspace(-xRange/2,xRange/2,data_points(2)*2-1), mix);
hold off;
fprintf('delay of 2nd in samples = %i\n',data_points(2)-(idx-1));

finddelay(signal1,signal2)