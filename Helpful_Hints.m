%% Load an image and crop it

fn = '~/Google Drive/Chinmay/'
img = imread([fn, 'CNF_30_6.tif']);
imtool(img)
whos img
img_crop = img(1:730,:);
imtool(img_crop)
imwrite(img_crop,[fn, 'CNF_30_6_crop.tif']);

%% Generate a directory that you can iterate over to run the above^
dir(fn)

%% Load an individual fiber data file for one image and make a histogram
load('CNF_30_6_crop_FiberData.mat')
figure; histogram(FiberData(:,3),30); title('Aspect Ratio Distribution')

%% Set the number of samples taken to get a fiber's width

% Line 41 of get_settings
% settings.fibWidSamps2 = 15;   change 15 to what you want