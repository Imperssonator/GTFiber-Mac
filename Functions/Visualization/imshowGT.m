function handles = imshowGT(img,handles,ax_tag)

% hax is the name of a field of handles that may or may not exist that
% references a set of axes which may or may not exist. Check if it exists,
% if not, create it, then put the image on it.

if isfield(handles,ax_tag)
    if isvalid(handles.(ax_tag))
        fp = handles.(ax_tag).Parent;
        delete(fp.Children);
        figure(fp);
        handles.(ax_tag) = axes();
        imshow(img,'parent',handles.(ax_tag))
        axis equal
        handles.(ax_tag).Position = [0 0 1 1];
    else
        figure;
        handles.(ax_tag) = axes();
        imshow(img,'parent',handles.(ax_tag))
        axis equal
        handles.(ax_tag).Position = [0 0 1 1];
    end
else
    figure;
    handles.(ax_tag) = axes();
    imshow(img,'parent',handles.(ax_tag))
    axis equal
    handles.(ax_tag).Position = [0 0 1 1];
end

end