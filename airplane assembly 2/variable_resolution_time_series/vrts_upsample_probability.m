function [ v ] = vrts_upsample_probability( vr, rs )
%VRTS_UPSAMPLE_PROBABILITY Summary of this function goes here
%   Detailed explanation goes here

    %v = vr * rs.upsample_prob_transform;
    %return;
    
    % manually
    v = zeros(1, rs.T0);
    for i=1:rs.T
        v(rs.start(i):rs.end(i)) = vr(i) / rs.csize(i);
    end
    
end

