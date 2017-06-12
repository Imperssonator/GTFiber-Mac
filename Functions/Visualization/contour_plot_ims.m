function [him, hax, hf] = contour_plot_ims(ims)

hf=figure;
him=imshow(ims.gray);
hax=gca;
hold on

for s = 1:length(ims.fibSegs)
    xy=ims.fibSegs(s).xy_seek;
    plot(xy(1,:),xy(2,:),'-b');
end

end