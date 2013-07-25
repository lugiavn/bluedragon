function [is_good error] = rs_is_good_for( rs, d )
%RS_IS_GOOD_FOR Summary of this function goes here
%   Detailed explanation goes here

    d       = vrts_upsample_probability(d, rs);
    energy  = d * 10 + compute_distribution_variance(d) * 10 + 0.01;
    energy(energy > 1) = 1;
    
    energy = vrts_downsample_probability(energy, rs);
    error  = sum(abs(1 - energy));
    
    is_good = error < 10;
end

