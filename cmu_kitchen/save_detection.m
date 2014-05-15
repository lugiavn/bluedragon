function [] = save_detection( i, detections )
%SAVE_DETECTION Summary of this function goes here
%   Detailed explanation goes here

    save(['./cache/detections' num2str(i) '.mat'], 'detections');
    
end

