function f = nxmakegaussian(N, mean, var)
%MAKEGAUSSIAN Summary of this function goes here
%   Detailed explanation goes here

f = zeros(1, N);

if var == 0
    f(mean) = 1;
    return;
end

for i=1:N
    f(i) = normpdf(i, mean, sqrt(var));
end

f = f / sum(f);

end

