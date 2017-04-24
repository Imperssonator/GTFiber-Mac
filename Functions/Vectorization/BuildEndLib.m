function ims = BuildEndLib(ims,settings)

% Label Segments
SegLabels = bwlabel(ims.segsInit,8);                % Create an image where their labels correspond to the order regionprops found them in
NumSegs = max(max(SegLabels));
[m,n] = size(SegLabels);

% Generate Endpoints
EndsImg = bwmorph(ims.segsInit,'endpoints');        % Also create a binary matrix of the segment endpoints

% Remove Perfect Rings
SegLabels_NoRings = SegLabels;
for i = 1:NumSegs;
    EndUnion_i = (SegLabels==i) & EndsImg;
    if ~any(EndUnion_i(:))
        SegLabels_NoRings(SegLabels==i)=0;
    end
end
ims.segsInit = ~~SegLabels_NoRings;

% Relabel Segments
SegLabels = bwlabel(ims.segsInit,8);                % Create an image where their labels correspond to the order regionprops found them in
NumSegs = max(max(SegLabels));
[m,n] = size(SegLabels);

% Generate Lookup Tables
End2Sub = cell(NumSegs,2);                          % Cell array that converts segment number into subscript indices of its endpoints in image
Sub2End = cell(m,n);                                % Reverse lookup that converts subscript indices into [segNum, endpoint 1 or 2]
EndLib = struct();                                  % Structure Array that will store lots of info on endpoints, will be numSegs x 2

for i = 1:NumSegs
    IsoSeg = SegLabels == i;                        % IsoSeg = an isolated segment i.e. only white pixels where this segment is
    SegEnds = IsoSeg.*EndsImg;                      % SegEnds = just the endpoints of this segment
    [Endi, Endj] = find(SegEnds);                   % Indices of the end of Segend i
    End2Sub{i,1} = [Endi(1),Endj(1)];
    End2Sub{i,2} = [Endi(2),Endj(2)];
end

for s = 1:NumSegs
    for ep = 1:2
        Coords = End2Sub{s,ep};
        EndLib(s,ep).EPCoord = End2Sub{s,ep};
        EndIndex = (ep-1)*NumSegs+s;
        EndLib(s,ep).EndIndex = EndIndex;           % Sometimes linear indices are useful for finding endpoints
        EndLib(s,ep).Label = s;
        Sub2End{Coords(1),Coords(2)} = [s ep];
    end
end

% Store things in IMS
ims.SegLabels = SegLabels;
ims.EndsImg = EndsImg;
ims.EndLib = EndLib;
ims.End2Sub = End2Sub;
ims.Sub2End = Sub2End;

end