function f = nxmakegaussian(N, mean, var)
%MAKEGAUSSIAN Summary of this function goes here
%   Detailed explanation goes here

f = zeros(1, N);

if var == 0
    var = 0.001;
end

for i=1:N
    f(i) = normpdf(i, mean, sqrt(var));
end

f = f / sum(f);

end

