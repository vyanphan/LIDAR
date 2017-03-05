clear;
clf;
%parameters
dc_current = [10 15 20 25]; %mA
func_volt = .10; %volt

%variables
amplitude = [];
mid = [];

%loop
m = [1000];
while m(end)*1.1 < 15000000
    m = [m round(m(end)*1.1)];
end
m = [m 15000000];
for dc_curr = dc_current
    for i = m
        func_freq = i;
        data = csvread([num2str(dc_curr) 'mA_' num2str(func_freq) 'hz_' num2str(func_volt) 'volt.csv']);
        %find amplitude
        sync = data(:,1);
        signal1 = data(:,2);
        xRange = data(1,3);

        max1 = max(signal1);
        min1 = min(signal1);
        mid = [mid (max1-min1)/2];
        amplitude = [amplitude max1-min1];
    end
    plot(m,amplitude)
        set(gca,'YScale','log')
    hold on;
    ylabel('Voltage (V)');
    yyaxis right;
    %plot(m, mid, 'c')
    %set(gca,'YScale','log')
    amplitude = [];
    mid = [];
end
leg = num2str(dc_current');
leg = strcat(leg,'mA');
legend(leg);
set(gca,'XScale','log')
xlabel('Freq(Hz)'), ylabel('mean voltage(V)');
grid on;
hold off
title([num2str(func_volt*1000) 'mV freq modulation'])

