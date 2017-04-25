function ims = FiberLengths(ims,figSwitch)

numFibs = length(ims.Fibers);
FLD = zeros(numFibs,1);

for i = 1:length(ims.Fibers)
    FLD(i) = (size(ims.Fibers(i).xy,2)-1)* ims.settings.fiberStep * ims.nmPix;
    ims.Fibers(i).Length = FLD(i);
end

ims.FLD = FLD;

if figSwitch
    figure;
    ax=gca;
    histogram(FLD,30);
    ax.FontSize=20;
    xlabel('Fiber Length (nm)');
    ylabel('Number of Fibers');
end


end
