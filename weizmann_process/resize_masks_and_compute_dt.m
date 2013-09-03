function weizmann = resize_masks_and_compute_dt( weizmann, w, h )
%RESIZE_MASKS_AND_COMPUTE_DT resize aligned masks and compute distance
%transform
%   Detailed explanation goes here

if ~exist('w')
    w = 100;
end
if ~exist('h')
    h = 150;
end

for i=1:length(weizmann.samples)
    
    for t=1:size(weizmann.samples(i).aligned_mask, 3)
        weizmann.samples(i).resized_mask(:,:,t)       = imresize(weizmann.samples(i).aligned_mask(:,:,t), [h w]);
        weizmann.samples(i).distance_transform(:,:,t) = bwdist(weizmann.samples(i).resized_mask(:,:,t));
    end
end

end

