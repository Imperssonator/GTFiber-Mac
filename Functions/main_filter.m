function ims = main_filter(ims,settings)

Options = settings.Options;

% Run coherence filter
hwait = waitbar(0,'Diffusion Filter...');

switch settings.invert
    case 0
        [ims.CEDgray, ims.v1x, ims.v1y] ...
            = CoherenceFilter(ims.gray,Options);
        ims.CEDgray = mat2gray(ims.CEDgray);
    case 1
        [ims.CEDgray, ims.v1x, ims.v1y] ...
            = CoherenceFilter(imcomplement(ims.gray),Options);
        ims.CEDgray = mat2gray(ims.CEDgray);
end

if settings.CEDFig
    figure; imshow(ims.CEDgray)
%     imtool(ims.CEDgray)
end

% Run Top Hat Filter
waitbar(0.5,hwait,'Top Hat Filter...');
ims.CEDtophat = imadjust(imtophat(ims.CEDgray,strel('disk',settings.thpix)));
if settings.topHatFig
    figure; imshow(ims.CEDtophat)
%     figure; imtool(ims.CEDtophat)
end

% Threshold and Clean
waitbar(0.7,hwait,'Threshold and Clean...');
switch settings.threshMethod
    case 1
        ims.CEDbw = YBSimpleSeg(ims.CEDtophat);
        disp('used adaptive')
    case 2
        ims.CEDbw = im2bw(ims.CEDtophat,settings.globalThresh);
end
if settings.threshFig
    figure; imshow(ims.CEDbw)
%     figure; imtool(ims.CEDbw)
end

ims.CEDclean = bwareaopen(ims.CEDbw,settings.noisepix);
if settings.noiseRemFig
    figure; imshow(ims.CEDclean)
%     figure; imtool(ims.CEDclean)
end

% Skeletonize
waitbar(0.8,hwait,'Skeletonization...');
ims.skel = bwmorph(ims.CEDclean,'skel',Inf);
if settings.skelFig
    figure; imshow(ims.skel)
%     figure; imtool(ims.skel)
end

ims.skelTrim = cleanSkel(ims.skel,settings.maxBranchSize);
% ims.skelTrim = bwareaopen(ims.skelTrim,settings.maxStubLen);
if settings.skelTrimFig
    figure; imshow(ims.skelTrim)
%     figure; imtool(ims.skelTrim)
end

% Generate Angle Map by getting new angles from CED
waitbar(0.9,hwait,'Recovering Orientations...');
Options.T = 1;
[~, ims.v1xn, ims.v1yn] = CoherenceFilter(ims.skelTrim,Options);
ims.AngMap = atand(ims.v1xn./-ims.v1yn);

% save('filter_debug','ims')

close(hwait)

end
