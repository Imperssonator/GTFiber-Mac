function [] = FiberColors(ims)

% Given imageData filepath, plot the fibers.

figure;
him = imshow(ims.gray);
him.AlphaData = 0.6;
ax = gca;
hold on

for i = 1:length(ims.FibersNew)
    color = rand(1,3);
    plot(ax,ims.FibersNew(i).xy(1,:),ims.FibersNew(i).xy(2,:),'Color',color,'LineWidth',2);
end

ax.Position = [0 0 1 1];


end
