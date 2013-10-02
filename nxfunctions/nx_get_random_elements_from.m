function v = nx_get_random_elements_from( x )
%NX_GET_RANDOM_ELEMENTS_FROM Summary of this function goes here
%   Detailed explanation goes here

    v = x(randi([1, length(x)]));

end

