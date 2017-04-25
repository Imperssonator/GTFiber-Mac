function ims = FiberVec_ACM(ims)

% Plot the vectorized fibers, except with each individual segment colored
% by its orientation. This is probably the ideal visualization for the
% Orientation Map, but it's incredibly slow.

XY = {ims.Fibers(:).xy};
w = size(ims.img,2);
h = size(ims.img,1);
sat = 0.92;

f1 = figure('Visible','on');
f1.Position = [1 1 1+w 1+h];
f1.Color = [0 0 0];
f1.InvertHardcopy='off';
ha = axes('parent',f1);
hold on

for i = 1:length(XY)
XYi = XY{i};
    for j = 1:size(XYi,2)-1
        xy_ij = XYi(:,j:j+1);
        xy_vec = xy_ij(:,2)-xy_ij(:,1);
        ang_ij = atan2d(-xy_vec(2),xy_vec(1));
        if ang_ij<0
            ang_ij = ang_ij+180;
        end
        plot(ha,xy_ij(1,:),xy_ij(2,:),'Color',hsv2rgb(2*ang_ij/360,1,sat),'LineWidth',4)
    end
end
% axis equal
set(ha,'Ydir','reverse')
ax = ha;
ax.XLim = [0 w];
ax.YLim = [0 h];

ax.Visible = 'off';
% ax.PlotBoxAspectRatio = [1 1 1];
ax.Position = [0 0 1 1];

F = getframe(f1);
Fim = F.cdata;
Fres = imresize(Fim,[h, w]);
% 
% close(f1)

end
