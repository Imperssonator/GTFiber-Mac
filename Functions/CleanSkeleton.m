function ims = CleanSkeleton(ims,settings)

% Starting from the initial skeleton, remove branches, groom, and clean it
% until it consists only of unbranched, isolated segments.

% Closing to remove small holes
skelClose = bwmorph(imclose(ims.skel,strel('disk',1)),'skeleton',Inf);

% FRemove branches up to a certain size
ims.skelTrim = RemoveBranches(skelClose,settings.maxBranchSize);

% Find branch points, dilate them, remove the dilated points to separate
% all segments
branchPts = bwmorph(ims.skelTrim,'branchpoints');
bigBranchPts = imdilate(branchPts,ones(3));
skelNoBranch = ims.skelTrim&~bigBranchPts;

% Remove segments that are shorter than the max branch size
ims.segsInit = bwareaopen(skelNoBranch,settings.maxBranchSize,8);

% Some segments may still have holes, this removes them.
% It may no longer be necessary.

% ims.segsInit = RemoveHoles(ims.segsInit);

end

function out = RemoveHoles(IM)

L = bwlabel(IM);
RP = regionprops(IM,'EulerNumber');
out = zeros(size(L));

for i = 1:length(RP)
    if RP(i).EulerNumber > 0
        out = out+double(L==i);
    end
end

out = out==1;

end