function [] = plot_fits_stack(ims_all,stack_num)

figure;
imshow(ims_all(stack_num).gray);
ax=gca;
hold on;
xy = [ims_all(stack_num).Fibers(:).xy];
plot(xy(1,:),xy(2,:),'ob');

end