function v = nx_linear_scale_to_range( v, min1, max1, min2, max2 )
%NX_LINEAR_SCALE_TO_RANGE Summary of this function goes here
%   Detailed explanation goes here

    assert(v >= min1 & v <= max1);

    % map to 0-1
    v = v - min1;
    v = v / (max1 - min1);
    
    % map to min2-max2
    v = v * (max2 - min2);
    v = v + min2;
end

