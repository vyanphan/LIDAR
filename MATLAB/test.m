clear;
clf;
for delay = 0:20
    x = [ones(1,45) 1 2 3 4 5 6 7 8 9  10 ones(1,45)*10];
    signal_y = [ones(1, delay) x(1:end-delay)];
    x = x-5;
    signal_y = signal_y-5;
    %y = fliplr(signal_y);
    y = signal_y;
    %corr = xcorr(x,y)
    %var_conv = cconv(x,y)
    conv_size = size(x);
    var_cconv = xcorr(x,y,conv_size(2));
    [largest, idx] = max(var_cconv);
    hold on;
    yyaxis left;
    plot(x,'r');
    plot(signal_y,'g');
    yyaxis right;
    plot(var_cconv);
    hold off;
    fprintf('delay of 2nd in samples = %i, should be %i; find_delay() = %i\n',conv_size(2)-(idx-1), delay, finddelay(x,signal_y));
    grid on;
end
