%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET KEITHLEY TO 10mA MINIMUM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
dc_current = 15; %mA

% test of I/O with DSO5054A scope!!!
fclose(instrfind)
clf;

%open connection to oscilloscope
osc = gpib('ni',0,7);
set(osc, 'InputBufferSize', 131072);
fopen(osc);
fprintf(1,query(osc,'*IDN?'));

%Open connection to function generator
fgen = gpib('ni',0,11);
fopen(fgen);
fprintf(1,query(fgen,'*IDN?'));

%Set signal parameters on fgen
func_volt = .100;
fprintf(fgen,['FREQ ' num2str(1000)]);
fprintf(fgen,['VOLT ' num2str(func_volt)]);
fprintf(fgen, 'FUNC:SHAP SIN');

%set global parameters
samples = 1000;

%loop
m = [1000];
while m(end)*1.1 < 15000000
    m = [m round(m(end)*1.1)];
end
m = [m 15000000];
for i = m
    func_freq = i;
    fprintf(fgen,['FREQ ' num2str(func_freq)]);
    %set scale and time HERE
    yRange = 9;
    yRange2 = .05; % TODO figure out the range for different DC and AC laser currents
    xRange = 3/func_freq; % at least 2 periods
    fprintf(osc, [':CHANNEL1:RANGE ' num2str(yRange)])
    fprintf(osc, [':CHANNEL2:RANGE ' num2str(yRange2)])
    fprintf(osc, ':CHANNEL1:OFFSET 0')
    fprintf(osc, ':CHANNEL2:OFFSET 0.05') %.02 for 15mA; .05 for 20mA; .1 for 25mA
    fprintf(osc, [':TIMEBASE:RANGE ' num2str(xRange)])
    fprintf(osc, [':TIMEBASE:DELay ' num2str(0)])

    %set format and collect data
    fprintf(osc, ':ACQuire:TYPE AVERage');
    fprintf(osc, ':ACQuire:COMPlete 100');
    fprintf(osc, ':ACQuire:COUNt 8');
    fprintf(osc, ':TRIG:SOURce CHANnel1');
    fprintf(osc, ':TRIG:LEV 1');

    %individual channel parameters
    fprintf(osc, ':WAVeform:SOURce CHANnel1');  
    fprintf(osc, ':WAVeform:Format ASCII');
    fprintf(osc, [':WAVeform:POINts ' samples]);

    %collect data
    fprintf(osc, ':DIG CHANnel1,CHANnel2');
    data = query(osc, ':WAVeform:DATA?');
    fprintf(osc, ':WAVeform:SOURce CHANnel2');
    fprintf(osc, ':WAVeform:Format ASCII');
    fprintf(osc, [':WAVeform:POINts ' samples]);
    data2 = query(osc, ':WAVeform:DATA?');
    fprintf(osc, ':WAVeform:Format ASCII');
    fprintf(osc, [':WAVeform:POINts ' samples]);
    data3 = query(osc, ':WAVeform:DATA?');

    %TODO parse data, definite-block length syntax
    num_digits = str2double(data(2));
    num_bytes = str2double( data(3:2+num_digits));
    %2nd channel
    num_digits2 = str2double(data2(2));
    num_bytes2 = str2double( data2(3:2+num_digits2));

    %put data in matrix format
    datab = data(2+num_digits+1:2+num_digits+num_bytes);
    data_parsed = eval(['[',datab,']']);
    %2nd channel
    data2b = data2(2+num_digits2+1:2+num_digits2+num_bytes2);
    data_parsed2 = eval(['[',data2b,']']);
    
    if i == 10000
        clf;
        %plot data signal vs time
        data_points = size(data_parsed);
        x = linspace(-xRange/2,xRange/2,data_points(2));
        yyaxis left;
        plot(x,data_parsed,'b');
        hold on;
        yyaxis right
        plot(x,data_parsed2,'r');
        %plot graph labels
        xlabel('Time (s)'), ylabel('Voltage (V)'), title(['Oscilloscope Data ' num2str(func_freq) ' hz']);
        grid on%, axis([-xRange/2, xRange/2, -yRange/2, yRange/2]);
        ax = gca;
        ax.XAxis.Exponent = -9;
    end

    %combine and save data to file
    len = size(data_parsed);
    units = (1:len(2));
    units(1) = xRange;
    save_data = [data_parsed; data_parsed2; units];
    save_data = save_data.';
    csvwrite([num2str(dc_current) 'mA_' num2str(func_freq) 'hz_' num2str(func_volt) 'volt.csv'], save_data, 0, 0);
end

%protect laser
fprintf(fgen,['FREQ ' num2str(1000)]);
fprintf(fgen,['VOLT ' num2str(.05)]);

%clean up
clear;
%
fclose(instrfind);