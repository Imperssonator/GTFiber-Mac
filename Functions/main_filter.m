function ims = main_filter(ims,settings)

Options = settings.Options;

% Run coherence filter
hwait = waitbar(0,'Diffusion Filter...');
[ims.CEDgray, ims.v1x, ims.v1y] ...
    = CoherenceFilter(ims.gray,Options);
ims.CEDgray = mat2gray(ims.CEDgray);

if settings.CEDFig
    figure; imshow(ims.CEDgray)
%     imtool(ims.CEDgray)
end

% Run Top Hat Filter
waitbar(0.5,hwait,'Top Hat Filter...');
ims.CEDtophat = imadjust(imtophat(ims.CEDgray,strel('disk',settings.thpix)));
if settings.topHatFig
    figure; imshow(ims.CEDtophat)
end

% Threshold and Clean
waitbar(0.7,hwait,'Threshold and Clean...');
if strcmp(settings.threshMethod,'Adaptive Threshold Surface')
    ims.CEDbw = YBSimpleSeg(ims.CEDtophat);
else
    ims.CEDbw = im2bw(ims.CEDtophat,settings.globalThresh);
end
if settings.threshFig
    figure; imshow(ims.CEDbw)
end

ims.CEDclean = bwareaopen(ims.CEDbw,settings.noisepix);
if settings.noiseRemFig
    figure; imshow(ims.CEDclean)
end

% Skeletonize
waitbar(0.8,hwait,'Skeletonization...');
ims.skel = bwmorph(ims.CEDclean,'skel',Inf);
if settings.skelFig
    figure; imshow(ims.skel)
end

ims.skelTrim = cleanSkel(ims.skel,settings.maxBranchSize);
% ims.skelTrim = bwareaopen(ims.skelTrim,settings.maxStubLen);
if settings.skelTrimFig
    figure; imshow(ims.skelTrim)
end

% Generate Angle Map by getting new angles from CED
waitbar(0.9,hwait,'Recovering Orientations...');
Options.T = 1;
[~, ims.v1xn, ims.v1yn] = CoherenceFilter(ims.CEDclean,Options);
ims.AngMap = atand(ims.v1xn./-ims.v1yn);

close(hwait)

end
