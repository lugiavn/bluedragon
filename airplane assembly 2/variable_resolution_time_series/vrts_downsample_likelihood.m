function vr = vrts_downsample_likelihood( v, rs )
%UP_SAMPLE_VRTS Summary of this function goes here
%   Detailed explanation goes here
    
    vr = zeros(1, rs.T);
    
    for i=1:rs.T
        vr(i) = mean(v(rs.start(i):rs.end(i)));
    end

end

