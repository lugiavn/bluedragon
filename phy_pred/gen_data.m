

%% training data

data.examples = struct;

data.training_ids = 1:40;
data.testing_ids  = 41:50;

for i=1:50
    
    length = round(100 + randn * 10);
    
    s      = 5;
    point1 = [100 + randn * s, 100];
    point2 = [100 + randn * s, 120];
    point3 = [100 + randn * s, 140];
    
    point4 = [80, 150 + randn * s];
    point5 = [50, 160 + randn * s];
    point6 = [20, 150 + randn * s];
    point7 = [10, 140 + randn * s];
    
    class  = 1;
    if rand > 0.5
        point4 = [120, 150 + randn * s];
        point5 = [150, 160 + randn * s];
        point6 = [180, 150 + randn * s];
        point7 = [190, 140 + randn * s];
        class  = 2;
    end
    
    p      = [point1' point2' point3' point4' point5' point6' point7'] + randn(2, 7);
%     p      = [point1' point4' point6'] + randn(2, 3);
%     p      = [point1' point6'] + randn(2, 2);
    p      = [imresize(p(1,:), [1 length+19], 'bilinear'); imresize(p(2,:), [1 length+19], 'bilinear')];
    p      = p(:,10:end-10);
    
    if 0
        p = (50 + randn * s):(150 + randn * s);
        p = [p; p/2 + randn];
        length = size(p, 2);
    end
    
    
    v      = p - p(:, [1 1:end-1]);
    v(:,1) = v(:,2);
    
    data.examples(i).positions   = p;
    data.examples(i).velocity    = v;
    data.examples(i).class       = class;
    data.examples(i).detector_id = class;
    data.examples(i).length      = length;
    
    if 0
        plot(p(1,:), p(2,:));
        hold on;
        plot(p(1,:), p(2,:), 'r*');
        hold off;
        pause(0.1);
    end;
end

clearvars -except data















