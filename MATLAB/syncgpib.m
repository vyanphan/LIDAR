% test of I/O with DSO5054A scope!!!
clear;
%fclose(instrfind);
clf;


%open connection to oscilloscope
osc = gpib('ni',0,7);
set(osc, 'InputBufferSize', 131072);
fopen(osc);

%fprintf(1,query(osc,'*IDN?'));

%Open connection to function generator
fgen = gpib('ni',0,10);
fopen(fgen);
fprintf(1,query(fgen,'*IDN?'));

%TODO: Set signal parameters on fgen

%set output ON on fgen
%fprintf(fgen,'OUTP ON');
fprintf(fgen,'FREQ 1.0E+3');
fprintf(fgen,'VOLT 2');
fprintf(fgen,'VOLTage:OFFSet 1');
fprintf(fgen, 'FUNC:SHAP SQUARE');

%set scale and time HERE
yRange = 6;
yRange4 = 6;
xRange = 10e-8;
fprintf(osc, [':CHANNEL1:RANGE ' num2str(yRange)])
fprintf(osc, [':CHANNEL4:RANGE ' num2str(yRange4)])
fprintf(osc, ':CHANNEL1:OFFSET 0')
fprintf(osc, ':CHANNEL4:OFFSET 0')
fprintf(osc, [':TIMEBASE:RANGE ' num2str(xRange)])
fprintf(osc, [':TIMEBASE:DELay ' num2str(0)])
%fprintf(osc, 'AUTOSCALE');

%set active channel, format and collect data
fprintf(osc, ':ACQuire:TYPE AVERage');
fprintf(osc, ':ACQuire:COMPlete 100');
fprintf(osc, ':ACQuire:COUNt 8');
fprintf(osc, ':WAVeform:SOURce CHANnel1');
fprintf(osc, ':WAVeform:Format ASCII');
fprintf(osc, ':WAVeform:POINts 1000');
fprintf(osc, ':TRIG:SOURce CHANnel1');
fprintf(osc, ':TRIG:LEV 1.5');
fprintf(osc, ':DIG CHANnel1,CHANnel4');

data = query(osc, ':WAVeform:DATA?');

fprintf(osc, ':WAVeform:SOURce CHANnel4');
fprintf(osc, ':WAVeform:Format ASCII');
fprintf(osc, ':WAVeform:POINts 1000');
data4 = query(osc, ':WAVeform:DATA?');

%TODO parse data, definite-block length syntax
num_digits = str2double(data(2));
num_bytes = str2double( data(3:2+num_digits));
%data4
num_digits4 = str2double(data4(2));
num_bytes4 = str2double( data4(3:2+num_digits4));

%put data in matrix format
datab = data(2+num_digits+1:2+num_digits+num_bytes);
data_parsed = eval(['[',datab,']']);
%data4
data4b = data4(2+num_digits4+1:2+num_digits4+num_bytes4);
data_parsed4 = eval(['[',data4b,']']);

clf;
%plot data signal vs time
data_points = size(data_parsed);
x = linspace(-xRange/2,xRange/2,data_points(2));
plot(x,data_parsed,'b',x,data_parsed4,'r')
%plot(x,data_parsed4,'r')
xlabel('Time (s)'), ylabel('Voltage (V)'), title('Oscilloscope Data');
grid on, axis([-xRange/2, xRange/2, -yRange/2, yRange/2]);
ax = gca;
ax.XAxis.Exponent = -9;


%combine and save data to file
units = (1:1000);
units(1) = xRange;
save_data = [data_parsed; data_parsed4; units];
save_data = save_data.';
csvwrite('data.csv', save_data, 0, 0);
%csvwrite(['data-', datestr(now,30), '.csv'], save_data, 0, 0);


%clean up
clear;
%
fclose(instrfind);