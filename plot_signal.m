
% plot_signal: Plot the time domain signal
%
% Inputs: 
%   - signal: the complex baseband signal
%   - symbol_duration: number of samples per symbol
%   - Fs:sampling frequency
% Outputs:
%   - Signal constellation

function plot_signal(signal,symbol_duration,Fs)
    figure
    plot(((1:20*symbol_duration)-1)*1/Fs, real(signal(1:20*symbol_duration)), 'LineWidth', 2)
    hold on; grid on; box on;
    xlabel('t','FontSize',18,'FontName', 'Times');
    ylabel('Signal(t)','FontSize',18,'FontName', 'Times');
    set(gca,'fontsize',18);
    ylim([-1.1*max(abs(signal)) 1.1*max(abs(signal))])
end