function Fres = FiberVecPlot_stitch(IMS)

% Given imageData filepath, plot the fibers.
f1 = figure;
hold on

XY = {IMS.Fibers(:).xy};
w = size(IMS.img,2);
h = size(IMS.img,1);

for i = 1:length(XY)
XYi = XY{i};
plot(XYi(1,:),XYi(2,:),'Color',rand(1,3),'LineWidth',1)
end
axis equal
set(gca,'Ydir','reverse')
ax = gca;
ax.Visible = 'off';
ax.XLim = [0 w];
ax.YLim = [0 h];
ax.PlotBoxAspectRatio = [1 1 1];
f1.Position = [1 1 1+w 1+h];
f1.Color = [1 1 1];
ax.Position = [0 0 1 1];

F = getframe(f1);
Fim = F.cdata;
Fres = imresize(Fim,[w, h]);

end
