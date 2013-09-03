function play_distance_transform(weizmann)
%PLAY_DISTANCE_TRANSFORM Summary of this function goes here
%   Detailed explanation goes here

    for i=1:length(weizmann.samples)
        for t=1:size(weizmann.samples(i).distance_transform,3)
            imagesc(weizmann.samples(i).distance_transform(:,:,t));
            pause(0.01);
        end
    end

end

