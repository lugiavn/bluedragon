function rs = rs_add_upsampleprobtransform( rs )
%RS_ADD_UPSAMPLEPROBTRANSFORMMATRIX Summary of this function goes here
%   Detailed explanation goes here

    T = zeros(rs.T, rs.T0);
    for i=1:rs.T
        T(i, rs.start(i):rs.end(i)) = 1 / rs.csize(i); 
    end

    rs.upsample_prob_transform = T;
end

