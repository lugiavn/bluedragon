function v = nx_randomswap( v )
%NX_RANDOMSWAP Summary of this function goes here
%   Detailed explanation goes here

    s = size(v);
    v = v(randperm(prod(s)));

end

