function [ reaching_hand  missing_detections ] = get_reaching_hand( hands )
%GET_REACHING_HAND Summary of this function goes here
%   Detailed explanation goes here

% check if both hands are detected
missing_detections = 0;
if isnan(hands(1)) | isnan(hands(3))
    missing_detections = 1;
end


% find reaching hand
reaching_threshold = -1;
reaching_hand = [NaN NaN];
if hands(2) > reaching_threshold 
    reaching_hand = hands([1 2]);
end
if hands(4) > reaching_threshold
    if isnan(reaching_hand(1)) | hands(4) > reaching_hand(2)
        reaching_hand = hands([3 4]);
    end
end
    
    
end

