


% true position
p = [1:100; (1:100) * 0.5];

% observation
o = p + randn(2,100);

plot(o(1,:), o(2,:), '*');


% ok do kalman
initialEstimateError  = 1E5 * ones(1, 3);
motionNoise           = [25, 10, 1];
measurementNoise      = 25;




















