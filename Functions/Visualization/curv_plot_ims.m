function [him, hs, hax, hf] = curv_plot_ims(ims,segorfib,num)

switch segorfib
    case 'seg'
        
        xy=ims.fibSegs(num).xy;
        curv=ims.fibSegs(num).curv;
        hf = figure;
        hax = gca;
        hold(hax,'on')
        
        buff = 10;
        zoom = 5;
        bbox = [min(xy(1,:))-buff,...
            max(xy(1,:))+buff,...
            min(xy(2,:))-buff,...
            max(xy(2,:))+buff];
        
        hs = scatter(hax,xy(1,:),xy(2,:),60,curv,'LineWidth',3);
        freezeColors(hax);
        him = imshow(ims.gray,'Parent',hax);
        uistack(him,'bottom')
        
        hs.MarkerFaceColor = 'flat';
        % hs.MarkerFaceAlpha = 0.5;
        him.AlphaData = 0.35;
        
        hax.XLim = bbox(1:2);
        hax.YLim = bbox(3:4);
        hax.Position = [0 0 1 1];
        hf.Position(3:4) = [(bbox(2)-bbox(1))*zoom,...
            (bbox(4)-bbox(3))*zoom];
        
    case 'fib'
        
        xy=ims.Fibers(num).xy;
        curv=ims.Fibers(num).curv;
        hf = figure;
        hax = gca;
        hold(hax,'on')
        
        buff = 10;
        zoom = 5;
        bbox = [min(xy(1,:))-buff,...
            max(xy(1,:))+buff,...
            min(xy(2,:))-buff,...
            max(xy(2,:))+buff];
        
        hs = scatter(hax,xy(1,:),xy(2,:),60,curv,'LineWidth',3);
        freezeColors(hax);
        him = imshow(ims.gray,'Parent',hax);
        uistack(him,'bottom')
        
        hs.MarkerFaceColor = 'flat';
        % hs.MarkerFaceAlpha = 0.5;
        him.AlphaData = 0.35;
        
        hax.XLim = bbox(1:2);
        hax.YLim = bbox(3:4);
        hax.Position = [0 0 1 1];
        hf.Position(3:4) = [(bbox(2)-bbox(1))*zoom,...
            (bbox(4)-bbox(3))*zoom];
        
end

end