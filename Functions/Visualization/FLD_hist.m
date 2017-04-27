function hf = FLD_hist(ims)

figure;
ax=gca;
histogram(FLD,30);
ax.FontSize=20;
xlabel('Fiber Length (nm)');
ylabel('Number of Fibers');

end