function [ v ] = vrts_upsample_likelihood( vr, rs )
%VRTS_UPSAMPLE_PROBABILITY Summary of this function goes here
%   Detailed explanation goes here

    
    v = zeros(1, rs.T0);
    for i=1:rs.T
        v(rs.start(i):rs.end(i)) = vr(i);
    end
    
end

