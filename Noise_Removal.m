function Clean = Noise_Removal(BW,gray)

lab = bwlabel(BW);
rp = regionprops(BW,'all');
Areas = [rp(:).Area]';
acut = mean(Areas);

gray_vec = gray(:);
max_lab = max(max(lab));
disp(max_lab)
Ratios = zeros(max_lab,1);
for i = 1:max_lab
%     disp(i)
    lab_im = lab==i;
    lab_dil = imdilate(lab_im,strel('disk',2));
    lab_bg = lab_dil~=lab_im;
    lab_gray = mean(gray_vec(lab_im(:)));
    bg_gray = mean(gray_vec(lab_bg(:)));
    Ratios(i) = lab_gray/bg_gray;
end

rcut = mean(Ratios)-0.5*std(Ratios);
Labels = (1:max_lab);
Noise = Labels( Ratios<rcut & Areas<acut );
BG = arrayfun(@(x) ismember(x,Noise)||x==0,lab);
% figure; imshow(~BG)

Clean = ~BG;

end