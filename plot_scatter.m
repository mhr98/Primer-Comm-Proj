
% plot_scatter: Plot the constellation digram
%
% Inputs: 
%   - rx_pixels_QPSK: the complex baseband signal
%   - title_str: figure title
% Outputs:
%   - Signal constellation

function plot_scatter(rx_pixels_QPSK,title_str)
    figure
    scatter(real(rx_pixels_QPSK(1:1000)), imag(rx_pixels_QPSK(1:1000)), 'LineWidth', 2);
    hold on; grid on; box on;
    xlabel('I','FontSize',18,'FontName', 'Times');
    ylabel('Q','FontSize',18,'FontName', 'Times');
    title(title_str,'FontSize',18,'FontName', 'Times')
    set(gca,'fontsize',18);
    ylim([-3 3]);
    xlim([-3 3]);
end