function IMS = FiberLengths(IMS,settings)

numFibs = length(IMS.Fibers);
FLD = zeros(numFibs,1);

for i = 1:length(IMS.Fibers)
    FLD(i) = (size(IMS.Fibers(i).xy,2)-1)* settings.fiberStep * IMS.nmPix;
    IMS.Fibers(i).Length = FLD(i);
end

IMS.FLD = FLD;

end
