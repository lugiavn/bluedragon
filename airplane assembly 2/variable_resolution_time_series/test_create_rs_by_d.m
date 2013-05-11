clear;
clc

d   = nxmakegaussian(1000, 500, 500) / 3 + nxmakegaussian(1000, 300, 3000)/3 + nxmakegaussian(1000, 900, 10) / 3;
d   = zeros(1, 1000);
d(1:100) = 1;
d(end-200:end) = 1;
d(500:600) = 2;
d = d / sum(d);

f   = [-ones(1,5) ones(1,5)];
var = conv(d, f, 'same');
var = abs(var);
var(var > 0.01) = 0.01;
var = var / sum(abs(var));

uni = ones(1, 1000) / 1000;
ddd = (d .^ 0.5) / sum(d .^ 0.5);

rsd = 0.3 * var + 0.6 * ddd + 0.1 * uni;

%%
rs  = create_resolution_structure_by_distribution(rsd, 20);
d2  = vrts_downsample_probability(d, rs);
d3  = vrts_upsample_probability(d2, rs);
close all; hold on; plot(d); plot(d3, 'r');

figure(2); plot(rsd);