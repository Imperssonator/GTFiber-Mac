function ims = fitAllSegments(ims,settings)

if isfield(ims,'fibSegs')
    ims = rmfield(ims,'fibSegs');
end

numSegs = max(max(ims.SegLabels));

% The first goal here is to take individual segments and turn them into a
% list of pixels where the list increases by distance from one end of the
% segment, which is quantified by the bwdistgeodesic function

high_curve = [];

for i = 1:numSegs
    
%     disp(i)
    
    coord = ims.EndLib(i,1).EPCoord;
    end_ind = sub2ind(size(ims.SegLabels),coord(1),coord(2));
    dd = bwdistgeodesic(ims.SegLabels==i,end_ind);
    seg_inds = find(ims.SegLabels==i);
    vals = dd(seg_inds);
    seg_list = [seg_inds, vals];
    sorted_seg = sortrows(seg_list,2);
    ims.fibSegs(i).sortPixInds = sorted_seg(:,1);
    ims.fibSegs(i).sortPixSubs = ind2subv(size(ims.SegLabels),sorted_seg(:,1));
    
    ims = FitSegment(ims,settings,i);
    
%     high_curve = [high_curve; sorted_seg(ims.fibSegs(i).curv>1e-03,1)];
end

% high_curve_im = zeros(size(ims.SegLabels));
% high_curve_im(high_curve) = 1;
% imtool(high_curve_im)

end

function ims = FitSegment(ims,settings,segNum)

% Basically taking the active contours algorithm from FiberApp and giving it
% an extremely good initial guess - just a list of the pixels that are the
% backbone of a fiber segment and an image that is the binary ground truth
% of the fiber segment

% FA = guidata(hObject);

% Check if there is selected fiber
% if FA.sel == 0; return; end


fibSegImg = ims.SegLabels==segNum;

[gradX, gradY] = gradient2Dx2(fibSegImg);
    
% Short names for fiber tracking parameters and data
xy_col = ims.fibSegs(segNum).sortPixSubs;    % column vector of i,j coords of pixels in order
xy = flipud(xy_col') - 0.5;
a = 0;
b = 0;
g = 20;
k1 = 20;
k2 = 10;
fiberIntensity = 1;
fiberStep = settings.fiberStep;  % Number of pixels a discrete step should take

% Apply fitting algorithm FA.iterations times
for k = 1:10
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
    int_start = interp2D(fibSegImg, xy(1,1), xy(2,1), 'cubic');
    int_end = interp2D(fibSegImg, xy(1,end), xy(2,end), 'cubic');
    
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
ims.fibSegs(segNum).angs = angs;
ims.fibSegs(segNum).xy = xy;
ims.EndLib(segNum,1).EVCoord = xy(:,1);             % These are coordinates in FiberApp xy space (x=j, y=i) of the endpoints
ims.EndLib(segNum,2).EVCoord = xy(:,end);
end

