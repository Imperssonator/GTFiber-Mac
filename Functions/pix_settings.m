function [settings, ims] = pix_settings(settings,ims)

ims.nmWid = settings.nmWid;
ims.pixWid = size(ims.img,2);
ims.nmPix = ims.nmWid/ims.pixWid;

% Get pixel values for filter options
settings.thpix = ceil(settings.thnm/ims.nmPix);
settings.noisepix = ceil(settings.noisenm/ims.nmPix^2);
settings.maxBranchSize = ceil(settings.maxBranchSizenm/ims.nmPix);
% settings.maxStubLen = ceil(settings.maxStubLennm/ims.nmPix);
settings.Options.sigma = settings.gaussnm/ims.nmPix;
settings.Options.rho = settings.rhonm/ims.nmPix;
settings.frameStep = ceil(settings.frameStepnmWide/ims.nmPix/2);
settings.gridStep = ceil(settings.gridStepnm/ims.nmPix);

% Match Search Settings
settings.searchLat = 0.02 * ims.nmWid;
settings.searchLong = 0.06 * ims.nmWid;


end