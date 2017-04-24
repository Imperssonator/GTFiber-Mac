% Script to produce a figure of the angle legend that accompanies the
% orientation maps

h = 370;
wl = -425; wr = 370;

[X Y] = meshgrid((wl:wr),(h:-1:0));
R = sqrt((X.^2+Y.^2));
H = atan2d(Y,X)*2/360;
S = ones(size(X));
V = ones(size(X));

rr = 220;
Black = R>rr;
Color = R<=rr;

V(Black) = 0;
V(Color) = 0.84;

HSV = cat(3,H,S,V);

rgb = hsv2rgb(HSV);

rgbt1 = insertText(rgb,[0 250],['180', char(176)],'BoxColor','black','TextColor','white','FontSize',80,'BoxOpacity',0);
rgbt2 = insertText(rgbt1,[640 250],['0', char(176)],'BoxColor','black','TextColor','white','FontSize',80,'BoxOpacity',0);
rgbt3 = insertText(rgbt2,[350 30],['90', char(176)],'BoxColor','black','TextColor','white','FontSize',80,'BoxOpacity',0);

figure; imshow(rgbt3)