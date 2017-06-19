function ims = RemoveShortFibers(ims)

FibersNew = ims.Fibers(1);

count = 0;
for i = 1:length(ims.Fibers)
    if ims.Fibers(i).length > ims.settings.minFibLen
        count = count+1;
        FibersNew(count) = ims.Fibers(i);
    end
end

rmfield(ims,'Fibers')
ims.Fibers = FibersNew;

end