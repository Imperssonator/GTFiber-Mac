function hf = FWD_hist(ims)

hf=figure;
ax=gca;
histogram(ims.FWD,30);
ax.FontSize=20;
xlabel('Fiber Width (nm)');
ylabel('Number of Fibers');

flfont=16;
flpos=[0.55, 0.87];
edgedark = 0;
edgewidth = 0.75;

htex = text('Units', 'normalized', 'Position', flpos, ...
    'BackgroundColor', [1 1 1], ...
    'String', {['<W>= ', num2str(mean(ims.FWD)), ' nm'],...
               ['std. dev.= ', num2str(std(ims.FWD)), ' nm']}, ...
    'FontSize', flfont,...
    'EdgeColor', edgedark*[1 1 1],...
    'LineWidth', edgewidth);

end