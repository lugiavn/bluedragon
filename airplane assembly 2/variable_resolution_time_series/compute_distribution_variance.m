function [v] = compute_distribution_variance( d , myfilter)
%COMPUTE_DISTRIBUTION_VARIANCE Summary of this function goes here
%   Detailed explanation goes here

if ~exist('myfilter')
    myfilter = [-ones(1,20) 0 ones(1,20)];
end

v = conv(d, myfilter, 'same');
v = abs(v);
v = v / sum(v);

end

