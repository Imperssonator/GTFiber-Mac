function [him, hs, hax, hf, hc] = curv_plot(img,xy,curv,lims)

if exist('lims')~=1
    lims = [min(curv),max(curv)];
end

buff = 10;
zoom = 5;
bbox = [min(xy(1,:))-buff,...
        max(xy(1,:))+buff,...
        min(xy(2,:))-buff,...
        max(xy(2,:))+buff];


m=64;
cmap=colormap([gray(255);parula(m)]);

him=imshow(img,cmap);

hold on
hs=scatter(xy(1,:),xy(2,:),100,'LineWidth',3);
hs(2)=scatter([1 1],[1 1],1,[256,256+m-1]);
hold off

hs(1).MarkerFaceColor = 'flat';
him.AlphaData = 0.4;

cmin = lims(1); cmax = lims(2);
curv_color = min(m,round((m-1)*(curv-cmin)/(cmax-cmin))+1);
hs(1).CData=curv_color+255;

hc=colorbar();
hc.Limits=[256, 256+m-1];
hc.Ticks = linspace(256,255+m,5);
hc.TickLabels = ...
    cellfun(@(x) num2str(x,2),...
            mat2cell(linspace(cmin,cmax,5)',...
                     ones(size(linspace(cmin,cmax,5)',1),1),...
                     1),...
            'UniformOutput',false);
hc.FontSize=16;

hf=gcf;
hax=gca;


% hax.XLim = bbox(1:2);
% hax.YLim = bbox(3:4);
% hax.Position = [0 0 1 1];
% hf.Position(3:4) = [(bbox(2)-bbox(1))*zoom,...
%                     (bbox(4)-bbox(3))*zoom];

end