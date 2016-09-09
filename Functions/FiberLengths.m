function IMS = FiberLengths(IMS,settings)


%% Image Characteristics
% load(IMS)
w = IMS.nmWid;                            % width of image in nm
% S = IMS.skelTrim;                       % The skeleton segments

%% Hard Coded:

SearchLat = 0.018*w; % Now fraction of image width (was 90);
SearchLong = .04*w; % was 200;
MinLength = settings.maxBranchSizenm; % was 30;         % Any segment less than 'maxBranchSizenm' nm long will be cleaned out
ODiffTol = 50;

%% Skeleton Cleaning - BETA - should incorporate with main filter
skelClose = bwmorph(imclose(IMS.skelTrim,strel('disk',1)),'skeleton',Inf);
S = cleanSkel(skelClose,settings.maxBranchSize);
Sbranch = bwmorph(S,'branchpoints');
BigBranch = imdilate(Sbranch,ones(3));
S_segs = S&~BigBranch;      % Find branch points, dilate them, remove the dilated points to separate everything
% _________________________________

[m,n] = size(S_segs);
pixdim = IMS.nmPix;                           % size of a pixel in nm
pixarea = pixdim^2;
MinSegLen = ceil(MinLength/pixdim);
SFib = bwareaopen(S_segs,MinSegLen,8);               % Let's not worry about those shorties (<30nm) for a bit

% It has come to my attention that some skeletal segments have holes which
% cause problems. Here we remove those segments.

SFib = RemoveHoles(SFib);

%% Building up Utility Variables and Lookup functions
RP = regionprops(SFib,'Area','Orientation');    % Grab region props for all the segments
SLabel = bwlabel(SFib,8);                       % Create an image where their labels correspond to the order regionprops found them in
Ends = bwmorph(SFib,'endpoints');               % Also create a binary matrix of the segment endpoints
NumSegs = length(RP);
NumEnds = 2*NumSegs;
EndCell = cell(NumSegs,2);                      % We're going to make a cell array that has the endpoint coordinates stored for each
% Make an endpoints cell array NumSegs x 2

for i = 1:NumSegs
    IsoSeg = SLabel == i;                       % IsoSeg = an isolated segment i.e. only white pixels where this segment is
    SegEnds = IsoSeg.*Ends;                     % SegEnds = just the endpoints of this segment
    [Endi Endj] = find(SegEnds);                 % Indices of the end of Segend i
    EndCell{i,1} = [Endi(1),Endj(1)];
    EndCell{i,2} = [Endi(2),Endj(2)];
    RP(i).Label = i;
end

Sub2End = cell(m,n);                            % Reverse lookup of endpoint index given coordinates in image
for s = 1:NumSegs
    for ep = 1:2
        Coords = EndCell{s,ep};
        Sub2End{Coords(1),Coords(2)} = [s ep];
    end
end
EndLib = struct();                              % Where to store endpoint match info, a structure array

%% Make Search Kernels

% First build the search kernel, which will look out from each endpoint of
% a segment for other endpoints
% It is 90 x 200 nm, a horizontal bar

Kh = ceil(SearchLat/pixdim);                    % How far to search laterally (from the sides of the segment)
Kw = ceil(SearchLong/pixdim);                   % How far to search longitudinally (out in the direction of the segment)

Kernel = ones(Kh,Kw);                           % The search kernel
KStart = zeros(Kh,Kw);                          % The point in the search kernel that goes at the segment endpoint
KStart(floor(Kh/2),3) = 1;
KStart(floor(Kh/2+1),3) = 1;                    % Had to add this in due to pixel loss in rotation


% save('FLdebug')
%% Run The Algo
disp('Running Search...')
for j = 1:NumSegs %1155:1155
    Oj = RP(j).Orientation;                  % Orientation of the segment we're considering
    
    %% Choosing a Search Angle
    % This section of code measures two angles, the "orientation" as
    % determined by regionprops (varies from -90 to 90 off horizontal), and
    % the "endpoint angle", which creates a vector between the two skeletal
    % endpoints (from bwmorph above); this varies from -90 to +270.
    % These two angles are naturally slightly different, but we want our
    % search to be conducted away from the endpoints of the segment (not back
    % into the segment body), however the orientation is a slightly better
    % indication of what direction to search, so we need to correct the
    % orientation to point in about the same direction as the endpoint
    % vector
    
    EPs = [EndCell{j,1};...                          % The endpoints of the segment
           EndCell{j,2}];
    for ep = 1:2
        EP = EPs(ep,:);
        EndLib(j,ep).EPCoord = EP;
        EndIndex = (ep-1)*NumSegs+j;
        EndLib(j,ep).EndIndex = EndIndex;
        EndLib(j,ep).Label = SLabel(EP(1),EP(2));
        
        if ep==1
            EPVec = EPs(2,:)-EPs(1,:);
        else
            EPVec = EPs(1,:)-EPs(2,:);                  % EPVec points INTO SEGMENT from endpoint in consideration
        end
        
        EPVec = EPVec./norm(EPVec);                     % Make it a unit vector
        EPAng = ImVec2RealAng(EPVec);                   % Find the real space angle of that vector
        EndLib(j,ep).EPVec = EPVec;
        EndLib(j,ep).EPAng = EPAng;
        % EP ANG BETWEEN 0 and 360!!!  Oj BETWEEN -90 and 90!
        
        AngleDiffs = [AngleDiff(EPAng,Oj), AngleDiff(EPAng,Oj+180);...
                      Oj,                  Oj+180];     % Find which 'version' of the orientation is closer to the endpoint angle
    
        [~, Closest] = min(AngleDiffs(1,:));
        TrueAngle = AngleDiffs(2,Closest);              % The true segment orientation pointing along the segment from the current endpoint
        TrueOVec = [-sind(TrueAngle) cosd(TrueAngle)];    % The true orientation unit vector. -sin to keep it in Image Matrix space (down is positive i)
        SearchVec = -TrueOVec;                          % Search vector points in opposite direction
        SearchAngle = ImVec2RealAng(SearchVec);   %ImVec2RealAng(SearchVec);
        
        EndLib(j,ep).TrueOVec = TrueOVec;            % Orientation Vector pointing into segment from this endpoint
        EndLib(j,ep).TrueAngle = TrueAngle;
        EndLib(j,ep).SearchVec = SearchVec;
        EndLib(j,ep).SearchAngle = SearchAngle;
        
        %% Implementing Search
        
        RotKern = imrotate(Kernel,SearchAngle);         % Rotate the kernels to that angle
        RotKStart = imrotate(KStart,SearchAngle);       % Rotate the kernel start point to that angle
        
        EPMatch = KernSearch(Ends,RotKern,RotKStart,EP);
        EndLib(j,ep).MatchSubs = EPMatch;            % This is the matrix of subscript indices of endpoints that match with this endpoint

%         disp('____________')
%         disp(j)
%         disp(EPs)
%         disp(EPMatch)
        if not(isempty(EPMatch))
            EndLib(j,ep).MatchDists = CalcMatchDists(EndLib(j,ep),pixdim);
            EndLib(j,ep).MatchSegs = GetMatchSegs(EndLib(j,ep),SLabel);
            EndLib(j,ep).MatchEnds = GetMatchEnds(EPMatch,Sub2End);
        else
            EndLib(j,ep).MatchDists = [];
            EndLib(j,ep).MatchSegs = [];
            EndLib(j,ep).MatchEnds = [];
        end
    end
end

%% Ranking Matches
disp('Ranking Results...')
MatchMatrix = sparse(zeros(NumEnds));                       % EndIndex = (en-1)*NumEnds+j

for j = 1:NumSegs %1155:1155
%     disp(j)
    for en = 1:2
        if not(isempty(EndLib(j,en).MatchEnds))
            OD = CalcODiffs(EndLib,j,en);                   % Difference between the search vector and the true orientation of the match endpoints
            EndLib(j,en).ODiffs = OD;
            Candidates = OD<50;                             % If less than 50, it gets a 1, if greater, a 0.
            EndLib(j,en).Candidates = Candidates;
            TopMatch = ScoreMatches(EndLib(j,en));          % The ranking formula, Top match = [score, j, en]
            EndLib(j,en).TopMatch = TopMatch;
            if not(isempty(TopMatch))
                TopMatchIndex = (TopMatch(3)-1)*NumSegs+TopMatch(2);
                MatchMatrix(EndLib(j,en).EndIndex,TopMatchIndex) = 1;
            end
        else
            EndLib(j,en).ODiffs = [];
            EndLib(j,en).Candidates = [];
            EndLib(j,en).TopMatch = [];
        end
    end
end

%% Non-Mutual Match Elimination

MatchMatrix = MatchMatrix.*MatchMatrix'; % This enforces symmetry basically

%% Percolation
% Now we put together the fibers. Identify endpoints that are mutual
% matches and percolate through them.
disp('Stitching Fibers...')

DeadEnds = find(sum(MatchMatrix,2)==0);

F = struct();
count = 1;
SegJump = 1;
CurrEnd = DeadEnds(1);
F(count).Fiber = [CurrEnd];

% How this is going to work:
% Start with first dead end
% Add sister end to fiber
% If sister end has no match, remove ends from deadends and try the next
% dead end, increment count
% If sister has a match, switch SegJump to 0 and go to next iter
% When SegJump is 0:
% Find Match and add to fiber
% Make SegJump 1
% Continue

while not(isempty(DeadEnds))
%     disp(count)
    if SegJump
        SisterEnd = FindSister(CurrEnd,NumSegs);
        F(count).Fiber = [F(count).Fiber SisterEnd];
        SisterMatch = FindMatch(SisterEnd,MatchMatrix);
        if isempty(SisterMatch)
            DeadEnds = DeadEnds(2:end);
            DeadEnds(find(DeadEnds==SisterEnd))=[];
            if isempty(DeadEnds)
                break
            end
            count = count+1;
            F(count).Fiber = DeadEnds(1);
            CurrEnd = DeadEnds(1);
        else
            SegJump = 0;
        end
    else
        F(count).Fiber = [F(count).Fiber SisterMatch];
        CurrEnd = SisterMatch;
        SegJump = 1;
    end
end

%% Get Fiber Labels
disp('Labeling Fibers...')

for i = 1:length(F)
    Fiberi = F(i).Fiber;
    FirstEnds = Fiberi(1:2:end);
    FiberSegs = [];
%     disp(FirstEnds)
    for e = FirstEnds
        FiberSegs = [FiberSegs EndLib(e).Label];
    end
    F(i).FiberSegs = FiberSegs;
end

FiberLabels = zeros(m,n);

for i = 1:length(F)
    FiberSegsi = F(i).FiberSegs;
    NewFiber = MultiEquiv(SLabel,FiberSegsi).*i;
    FiberLabels = FiberLabels + NewFiber;
end

IMS.FiberLabels = FiberLabels;

%% Calculate Fiber Lengths
disp('Calculating Fiber Lengths...')

for i = 1:length(F)
    Fiberi = F(i).Fiber;
    TotalLen = 0;
    PrevEP = Fiberi(1);
    for e = Fiberi(2:end)
        PrevCoord = EndLib(PrevEP).EPCoord;
        CurrCoord = EndLib(e).EPCoord;
        TotalLen = TotalLen+norm(CurrCoord-PrevCoord);
        PrevEP = e;
    end
    F(i).Length = TotalLen*pixdim;
end
% 
% save('FLDebug')

IMS.EndLib = EndLib;
IMS.Fibers = F;
IMS.SFib = SFib;
IMS.SLabel = SLabel;
IMS.FLD = [IMS.Fibers(:).Length];

% save(IMS,'IMS')

end

%% Sub Functions

function SisterEnd = FindSister(CurrEnd,NumSegs)

if CurrEnd > NumSegs
    SisterEnd = CurrEnd-NumSegs;
else
    SisterEnd = CurrEnd+NumSegs;
end

end

function SisterMatch = FindMatch(SisterEnd,MatchMatrix)

SisterMatch = find(MatchMatrix(SisterEnd,:));

end

function [Fnew,IncorpNew] = FiberPerc(F,IncorpList,MatchMatrix,count,i,prev)

% Append segment i to F(count).Fiber, follow any matches that don't go
% backwards onward into recursive call. Add segment i to incorplist.

Fnew(count).Fiber = [F(count).Fiber i];
IncorpNew = [IncorpList i];
[I,Matches] = find(MatchMatrix(i,:));

for j = Matches(Matches~=prev)
    [Fadd,IncorpAdd] = FiberPerc(Fnew,IncorpNew,MatchMatrix,count,j,i);
    Fnew(count).Fiber = union(Fnew(count).Fiber,Fadd(count).Fiber);
    IncorpNew = union(IncorpNew,IncorpAdd);
end

end

function Top = ScoreMatches(ELS)

Cand = ELS.Candidates;
OD = ELS.ODiffs;
MD = ELS.MatchDists;
[m n] = size(OD);
MatchEnds = ELS.MatchEnds;
Tops = [];
count = 0;
for e = 1:m
    if Cand(e)
        count = count+1;
        Score = (OD(e)>30).*OD(e)+MD(e);
        Tops(count,:) = [Score MatchEnds(e,:)];
    end
end

if not(isempty(Tops))
    Tops = sortrows(Tops,1);            % Rank from lowest to highest score
    Top = Tops(1,:);
else
    Top = [];
end

end

function Matches = KernSearch(Ends,RotKern,RotKStart,EP)

% This function basically has to take a rotated kernel, its starting point,
% and overlay it correctly with the right portion of the image, while
% accounting for the edges of the image. I have the details written on a
% piece of paper but it would be quite difficult to document this here. It
% works.

% It returns a list of indices of points that fall within the "field of
% view" of the end of a segment

[Km,Kn] = size(RotKern);
[Im,In] = size(Ends);
[RKi RKj] = find(RotKStart,1);
EPi = EP(1); EPj = EP(2);
SearchKern = RotKern-RotKStart;

Dt = RKi-1; Db = Km-RKi;
Dl = RKj-1; Dr = Kn-RKj;

IMt = max(1,EPi-Dt);
IMb = min(Im,EPi+Db);
IMl = max(1,EPj-Dl);
IMr = min(In,EPj+Dr);

Kt = RKi-(EPi-IMt);
Kb = RKi+(IMb-EPi);
Kl = RKj-(EPj-IMl);
Kr = RKj+(IMr-EPj);

MatchPts = SearchKern(Kt:Kb,Kl:Kr).*Ends(IMt:IMb,IMl:IMr);
[Mati,Matj] = find(sparse(MatchPts));
Matchi = Mati+IMt-1;
Matchj = Matj+IMl-1;

Matches = [Matchi, Matchj];

% save('MatchesDebug')

end

function MatchDists = CalcMatchDists(ELS,pixdim)

% Given one structure from the EndLib Structure Array (ELS), calculate the
% distances to each of its potential matches!

MatchSubs = ELS.MatchSubs;
EP = ELS.EPCoord;
[m n] = size(MatchSubs);

MatchDists = zeros(m,1);

for i = 1:m
    MatchDists(i) = norm(MatchSubs(i,:)-EP)*pixdim;
end

end

function MatchSegs = GetMatchSegs(ELS,SLabel)

MatchSubs = ELS.MatchSubs;
[m n] = size(MatchSubs);

MatchSegs = zeros(m,1);

for i = 1:m
    MatchSegs(i) = SLabel(MatchSubs(i,1),MatchSubs(i,2));
end

end

function MatchEnds = GetMatchEnds(EPMatch,Sub2End)

[m n] = size(EPMatch);
MatchEnds = zeros(m,2);

for i = 1:m
%     disp('----')
%     disp(EPMatch(i,:))
    MatchEnds(i,:) = Sub2End{EPMatch(i,1),EPMatch(i,2)};
end

end

function MatchOrients = GetMatchOrients(ELS,RP)

MatchSegs = ELS.MatchSegs;
[m n] = size(MatchSegs);

MatchOrients = zeros(m,1);

for i = 1:m
    MatchOrients(i) = RP(MatchSegs(i)).Orientation;
end

end

function ODiffs = CalcODiffs(EndLib,j,en)

% Difference between the search angle and the true orientation of the match endpoints

SearchAngle = EndLib(j,en).SearchAngle;
MatchEnds = EndLib(j,en).MatchEnds;
[m n] = size(MatchEnds);

ODiffs = zeros(m,1);

for i = 1:m
    Mj = MatchEnds(i,1); Men = MatchEnds(i,2);
    ODiffs(i) = AngleDiff(EndLib(Mj,Men).TrueAngle,SearchAngle);
end

end

function out = ImVec2RealAng(V)

[out,~] = cart2pol(V(2),-V(1));     % Find that vector's angle
out = out*180/pi;                   % Convert to degrees

end

function out = AngleDiff(A1,A2)

% AngleDiff finds the absolute value of the "angular distance" between two
% angles in degrees. In this function, AngleDiff(-89, 270) = 1, for example.

Reps = [abs(A1-A2),...
        abs(A1+360-A2),...
        abs(A1-(A2+360))];
    
out = min(Reps);

end

