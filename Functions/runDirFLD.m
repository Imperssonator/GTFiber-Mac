function SummaryData = runDirFLD(dirPath,settings)

% varargin{1} is: 0 if just get images, 1 if get mobilities

hwaitdir = waitbar(0,'Running Directory...');

imdir = CompileImgs(dirPath);
numIms = length(imdir);

% S = zeros(length(imdir),1);

AllFiberData = [];
SummaryData = cell(numIms,6);
auto_handles = struct();

SummaryData{1,1} = 'Image Name';
SummaryData{1,2} = 'Sfull fit';
SummaryData{1,3} = 'Correlation Length (nm)';
SummaryData{1,4} = 'Mean Length';
SummaryData{1,5} = 'Mean Width';
SummaryData{1,6} = 'Length Density';

for i = 1:numIms
    waitbar(i/numIms,hwaitdir,['Processing ', imdir(i).name]);
    
    imfilei = imdir(i).path;
    addpath('Functions')
    addpath('Functions/coherencefilter_version5b')
    
    % Initialize image data structure and pixelize (convert from nm to pix) setting values
    ims = initImgData(imfilei); % initialize the image structure, which generates a grayscale and some simple thresholded stuff to start with
    [settings, ims] = pix_settings(settings,ims);
    if settings.figSave
        mkdir(ims.imNamePath);  % make the directory to save the results figures
    end
    
    % Run the filter bank at the current settings
    auto_handles.ims = ims;
    auto_handles.settings = settings;
    auto_handles = main_filter(auto_handles);
    ims = auto_handles.ims;
    
    % Stitch fiber segments and calculate length
    ims = StitchFibers2(ims,settings);
    ims = FiberLengths(ims,settings);
    
    % Sample fiber widths along each fiber
    ims = FiberWidths(ims,settings);
    FiberData = [[ims.Fibers(:).Length]', [ims.Fibers(:).Width]', [ims.Fibers(:).Length]'./[ims.Fibers(:).Width]'];
    AllFiberData = [AllFiberData; FiberData];
    
    SummaryData{i+1,1} = ims.imName;
    [Frames, Sfull, Smod, BETA] = op2d_am(ims, settings);
    SummaryData{i+1,2} = BETA(1);
    SummaryData{i+1,3} = BETA(2)*1000;
    SummaryData{i+1,4} = mean(FiberData(:,1));
    SummaryData{i+1,5} = mean(FiberData(:,2));
    SummaryData{i+1,6} = sum(FiberData(:,1)) / (size(ims.img,1)*size(ims.img,2)*(ims.nmPix)^2);
    
    save([ims.imNamePath, '_FiberData.mat'],'FiberData')

end

csvwrite([dirPath, 'all_fiber_data.csv'],AllFiberData);
cell2csv([dirPath, 'summary_stats.csv'], SummaryData, ',', 1999, '.');

close(hwaitdir)

end

function out = CompileImgs(FolderPath)
disp(FolderPath)

ad = pwd;

% First compile any images from the folderpath
cd(FolderPath)

PNG = dir('*.png');
JPG = dir('*.jpg');
JPEG = dir('*.jpeg');
TIF = dir('*.tif');
TIFF = dir('*.tiff');
BMP = dir('*.bmp');
CurIms = [PNG; JPG; JPEG; TIF; TIFF; BMP]; % Generate directory structure of images in FolderPath
cd(ad)

for p = 1:length(CurIms)
    CurIms(p).path = [FolderPath, CurIms(p).name];   % prepend the folder path to the image names
end

% Remove any ghost files with the ._ prefix
c=1;
pp=1;
while pp<=length(CurIms)
    if ~strcmp(CurIms(pp).name(1:2),'._')
        out(c) = CurIms(pp);
        c = c+1;
    end
    pp = pp+1;
end
end
