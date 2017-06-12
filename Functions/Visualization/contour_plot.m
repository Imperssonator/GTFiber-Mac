function [him, hp, hax, hf] = contour_plot(img,xy)

hf=figure;
him=imshow(img);
hax=gca;
hold on
hp = plot(xy(1,:),xy(2,:),'-b');

end