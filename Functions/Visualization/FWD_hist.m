function hf = FWD_hist(ims)

hf=figure;
ax=gca;
histogram(ims.FWD,30);
ax.FontSize=20;
xlabel('Fiber Width (nm)');
ylabel('Number of Fibers');
