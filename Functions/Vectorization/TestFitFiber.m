function Scores = getScores(ims,j,ep)

%% Cosine Scores
% cosine( searchVec1 , connVec ) * cosine( searchVec2 , connVec )

searchVec1 = ims.EndLib(j,ep).SearchVec;
MatchEnds = ims.EndLib(j,ep).MatchEnds;
[m n] = size(MatchEnds);

Scores = zeros(m,1);

for i = 1:m
    mj = MatchEnds(i,1); mep = MatchEnds(i,2);
    connVec = ims.EndLib(mj,mep).EVCoord - ims.EndLib(j,ep).EVCoord;        % connVec is in FiberApp xy space (x=j, y=i), same as search vecs
    searchVec_m = ims.EndLib(mj,mep).SearchVec;
    Scores(i,1) = dot(searchVec1,connVec)/(norm(searchVec1)*norm(connVec)) *...
                    dot(connVec,searchVec_m)/(norm(connVec)*norm(searchVec_m)) +...
                    ( (dot(searchVec1,searchVec_m)/(norm(searchVec1)*norm(searchVec_m))) > cosd(180-ims.settings.maxAngleDeg) )*1000;
end

end

function F = TestFitFiber(ims,joinEnds)

% Given the endpoint indices of two segment ends that are candidates for a
% fiber match, fit a fiber, F, to obtain a curvature score for the union

FiberSegs = ims.Fibers(fibNum).FiberSegs;                   % Labels of segments in fiber
numFibSegs = length(FiberSegs);
StartInds = ims.Fibers(fibNum).Fiber(1:2:end);              % Indices of the first endpoint of each segment in the chain
fibImg = int16(ims.gray);
sortPixInds = [];

for i = 1:length(joinEnds)
    
    if StartInds(i) <= length(ims.EndLib)                           % If the start ind is the 'first' index of that segment
        sortPixInds = [sortPixInds;                                 % Take the sorted pixel indices as they are
                       ims.fibSegs(FiberSegs(i)).sortPixInds];
    else                                                            % Otherwise, flip them upside down
        sortPixInds = [sortPixInds;
                       ims.fibSegs(FiberSegs(i)).sortPixInds(end:-1:1)];
    end
    
end

ims.Fibers(fibNum).sortPixInds = sortPixInds;
ims.Fibers(fibNum).sortPixSubs = ind2subv(size(ims.SegLabels),sortPixInds);

[gradX, gradY] = gradient2Dx2(fibImg);

fiberStep = ims.settings.fiberStep;  % Number of pixels a discrete step should take
    
% Short names for fiber tracking parameters and data
xy_col = ims.Fibers(fibNum).sortPixSubs;    % column vector of i,j coords of pixels in order
xy = flipud(xy_col');
xy = distributePoints(xy,fiberStep);
a = 0;
b = 5;
g = 10;
k1 = 20;
k2 = 10;
fiberIntensity = 255;

% Apply fitting algorithm FA.iterations times
for k = 1:20
    % Construct a matrix M for the internal energy contribution
    n = length(xy);
    
    m1 = [3   2 1:n-2         ;
          2     1:n-1         ;
          1:n           ;
          2:n   n-1     ;
          3:n   n-1 n-2];
    
    m2 = cumsum(ones(5,n), 2);
    
    col = [b; -a-4*b; 2*a+6*b+g; -a-4*b; b];
    m3 = col(:, ones(n,1));
    
    m3(:,1:2) = [b       0        ;
                 -2*b    -a-2*b   ;
                 a+2*b+g 2*a+5*b+g;
                 -a-2*b  -a-4*b   ;
                 b       b       ];
    
    m3(:,end-1:end) = [b         b      ;
                       -a-4*b    -a-2*b ;
                       2*a+5*b+g a+2*b+g;
                       -a-2*b    -2*b   ;
                       0         b     ];
    
    M = sparse(m1, m2, m3, n, n);
    
    % Vector field of external energy
    % (interp2 MATLAB function requests double input, which consume too
    % much memory for big AFM images)
    % gradX and gradY are doubled! (see gradient2Dx2)
    vfx = interp2D(gradX, xy(1,:), xy(2,:), 'cubic')/2;
    vfy = interp2D(gradY, xy(1,:), xy(2,:), 'cubic')/2;   
    vf = k1*[vfx; vfy]/fiberIntensity;
    
    % Normalized vectors of fiber ends
    v_start = xy(:,1) - xy(:,2);
    v_start = v_start/sqrt(sum(v_start.^2));
    v_end = xy(:,end) - xy(:,end-1);
    v_end = v_end/sqrt(sum(v_end.^2));
    
    % Image intensities at the ends
    int_start = interp2D(fibImg, xy(1,1), xy(2,1), 'cubic');
    int_end = interp2D(fibImg, xy(1,end), xy(2,end), 'cubic');
    
    % Full external energy
    vf(:,1) = vf(:,1) + k2*v_start*int_start/fiberIntensity;
    vf(:,end) = vf(:,end) + k2*v_end*int_end/fiberIntensity;
    
    % Next position
    xy = distributePoints((g*xy+vf)/M, fiberStep);
end

if length(xy)>3
    xy_vec = diff(xy,1,2);
    dots = sum(xy_vec(:,1:end-1).*xy_vec(:,2:end),1) ./...
           (sqrt(sum(xy_vec(:,1:end-1).^2,1)) .* sqrt(sum(xy_vec(:,2:end).^2,1)));  % This is just stupid
    dots(dots>1) = 1;
    angs = acos(dots);
else
    angs = zeros(1,size(xy,2)-1);
end

% Save fiber data
ims.Fibers(fibNum).angs = angs;
ims.Fibers(fibNum).xy = xy;

end