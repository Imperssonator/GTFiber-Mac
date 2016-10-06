function ims = StitchFibers2(ims,settings)

% 1. Skeleton Cleaning
hwait = waitbar(0,'Cleaning Skeleton...');
ims = CleanSkeleton(ims,settings);

% 2. Label segments and Make EndLib
waitbar(0.1,hwait,'Building Endpoint Library...');
ims = BuildEndLib(ims,settings);

% 3. Vectorize Segments - once we are here, we do not go back
waitbar(0.2,hwait,'Vectorizing Segments...');
ims = fitAllSegments(ims,settings);

% 4. Break high curvatures
waitbar(0.3,hwait,'Breaking High Curvatures...');
ims = BreakHighCurvSegs(ims,settings);

% 4.5 Rebuild EndLib
waitbar(0.4,hwait,'Rebuilding Endpoint Library...');
ims = BuildEndLib(ims,settings);
ims = fitAllSegments(ims,settings);

% 5. Remove Non-conforming widths (measure widths)
waitbar(0.5,hwait,'Removing Out-of-range Widths...');
ims = SegWidths(ims,settings);
ims = RemoveBadWidths(ims,settings);

% 5. Rebuild EndLib
waitbar(0.6,hwait,'Rebuilding Endpoint Library...');
ims = BuildEndLib(ims,settings);
ims = fitAllSegments(ims,settings);

% 6. Match Search, Ranking/Pairing, Percolation
waitbar(0.7,hwait,'Segment Matching and Percolation...');
ims = SegMatch(ims,settings);

% 7. Vectorize Fibers
waitbar(0.8,hwait,'Vectorizing Final Fibers...');
ims = fitAllFibers(ims,settings);

save('sf2debug','ims')
close(hwait)

end