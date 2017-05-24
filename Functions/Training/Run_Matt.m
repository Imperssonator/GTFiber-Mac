img_file = '~/Downloads/0th dilution 10may17.tif';
fp_start = '~/Downloads/Matt4.mat';
start_img_num = 4;
final_img_num = 30;
nmPix = 1.82;

% First, convert from FiberApp data to my ims structure
load(fp_start)

ims=struct('nmPix',imageData.sizeX_nm/imageData.sizeX,...
    'settings',struct('fiberStep',imageData.step),...
    'Fibers',struct() ...
    );

for i = 1:length(imageData.xy);
ims.Fibers(i).xy = imageData.xy{i};
end

ims.gray = rgb2gray(imread(img_file,start_img_num));

% Start an ims to hold all the ims's
ims_all = ims;
ims_all(start_img_num) = ims;

% Grab the next image and fit it
for i = start_img_num+1:final_img_num
    disp(i)
    next_im = rgb2gray(imread(img_file,i));
    ims_all(i) = fitNextImg(ims,next_im);
end

L = [];
for i = 1:length(ims_all);
LF=[];
for j = 1:length(ims_all(i).Fibers);
xy=ims_all(i).Fibers(j).xy;
LF=[LF,length(xy) * ims_all(i).settings.fiberStep * ims_all(i).nmPix];
end
L = [L, mean(LF)];
end
figure;plot(L,'ob')
xlabel('Image Number')
ylabel('Mean Fiber Length (µm)')
plot_fits_stack(ims_all,start_img_num)
plot_fits_stack(ims_all,final_img_num)

ims_all(1).FLD=[];
for i = 1:length(ims_all);
ims_all(i) = FiberLengths(ims_all(i));
end

figure;histogram(ims_all(final_img_num).FLD);
title('Length Distribution of last image');

figure;pcolor([ims_all(:).FLD])