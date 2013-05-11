close all;
clear;clc;
T0 = 1000;

a = nxmakegaussian(T0, 200, 200);


M = nxmakegaussian(T0, 500, 1);
for i=2:T0
    M(end+1,:) = [0 M(end,1:end-1)];
end

b = a * M;
plot(a);
hold on;
plot(b, 'r');
hold off;

%%

T = 30;
rs1 = create_resolution_structure_by_distribution(a .^ 0.1, T);
rs2 = create_resolution_structure_by_distribution(b .^ 0.1, T);

a2 = vrts_downsample_probability(a, rs1);
M2 = vrts_downsample_mat(M, rs1, rs2, 1, 0, 0);
b2 = a2 * M2;

a3 = vrts_upsample_probability(a2, rs1);
b3 = vrts_upsample_probability(b2, rs2);

figure(2);
plot(a3);
hold on;
plot(b3, 'r');





















