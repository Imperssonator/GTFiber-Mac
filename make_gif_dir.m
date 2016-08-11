function gif_file = make_gif_dir(fileName,delay)

% FileName is string
% delay is delay of each frame in seconds

% Get folder and save file name
folderPath = uigetdir;
if isequal(folderPath, 0); return; end % Cancel button pressed
if ispc
    separator = '\';
else
    separator = '/';
end

folderPath = [folderPath, separator];

d = CompileImgs(folderPath);

gif_file = [folderPath, separator, fileName, '.gif'];

img1 = imread(d(1).path);
img1 = imresize(img1,[512 512]);

% Write initial gray image
[curFrame,c_map] = rgb2ind(img1,256);
whos
imwrite(curFrame,c_map,gif_file,'gif','LoopCount',100,'DelayTime',delay);

for i = 2:length(d)
    disp(i)
    [curFrame, c_map] = rgb2ind(imresize(imread(d(i).path),[512 512]),256);
    imwrite(curFrame,c_map,gif_file,'gif','WriteMode','append','DelayTime',delay);
end

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