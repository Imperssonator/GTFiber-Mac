function handles = imshowGT(img,handles,ax_tag)

% hax is the name of a field of handles that may or may not exist that
% references a set of axes which may or may not exist. Check if it exists,
% if not, create it, then put the image on it.

if isfield(handles,ax_tag)
    if isvalid(handles.(ax_tag))
        imshow(img,'parent',handles.(ax_tag))
    else
        figure;
        handles.(ax_tag) = axes();
        imshow(img,'parent',handles.(ax_tag))
    end
else
    figure;
    handles.(ax_tag) = axes();
    imshow(img,'parent',handles.(ax_tag))
end

end