function ims = pix_settings(ims)

ims.nmWid = ims.settings.nmWid;
ims.pixWid = size(ims.img,2);
ims.nmPix = ims.nmWid/ims.pixWid;

% Get pixel values for filter options
ims.settings.thpix = ceil(ims.settings.thnm/ims.nmPix);
ims.settings.noisepix = ceil(ims.settings.noisenm/ims.nmPix^2);
ims.settings.maxBranchSize = ceil(ims.settings.maxBranchSizenm/ims.nmPix);
% ims.settings.maxStubLen = ceil(ims.settings.maxStubLennm/ims.nmPix);
ims.settings.Options.sigma = ims.settings.gaussnm/ims.nmPix;
ims.settings.Options.rho = ims.settings.rhonm/ims.nmPix;
% ims.settings.frameStep = ceil(ims.settings.frameStepnmWide/ims.nmPix/2);
% ims.settings.gridStep = ceil(ims.settings.gridStepnm/ims.nmPix);

% Match Search settings
ims.settings.fiberStep_nm = ims.settings.fiberStep * ims.nmPix;
ims.settings.searchLat = 0.02 * ims.nmWid;
ims.settings.searchLong = ims.settings.stitchGap;


end