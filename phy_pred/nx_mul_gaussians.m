function [ mean3 var3 scaleout ] = mul_gaussians( mean1, var1, mean2, var2 )
%MUL_GAUSSIANS Summary of this function goes here
%   N(x; mean1, var1) * N(x; mean2, var2) = scaleout * N(x; mean3, var3)

    if 1
        assert(size(mean1,2) == 1);
        assert(size(mean2,2) == 1);
        assert(size(mean1,1) == size(mean2,1));
    end

    var3     = inv(inv(var1) + inv(var2));
    mean3    = var3 * inv(var1) * mean1 + var3 * inv(var2) * mean2;
    scaleout = det (var3) / det (var1) / det (var2) / (2 * pi) ^ (length(mean1));
    scaleout = sqrt(scaleout) * exp((-1/2) * (mean1' * inv(var1) * mean1 + mean2' * inv(var2) * mean2 - mean3' * inv(var3) * mean3));
end

