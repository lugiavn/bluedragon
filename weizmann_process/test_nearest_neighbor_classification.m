function test_nearest_neighbor_classification( weizmann )
%TEST_NEAREST_NEIGHBOR_CLASSIFICATION Summary of this function goes here
%   Detailed explanation goes here

clc;

for i=weizmann.testing_ids

    class        = 'N/A';
    bestDistance = inf;
    nearestID    = nan;
    distances1    = [];
    distances2    = [];
    distances3    = [];
    distances    = [];

    for k=weizmann.training_ids

        d1 = norm(weizmann.samples(i).hist - weizmann.samples(k).hist);
        d2 = histogram_intersection(weizmann.samples(i).hist,weizmann.samples(k).hist);
        d3 = chi_square_statistics(weizmann.samples(i).hist,weizmann.samples(k).hist);
        d  = d3;
        
        distances1(end+1) = d1;
        distances2(end+1) = d2;
        distances3(end+1) = d3;
        distances(end+1)  = d;

        if d < bestDistance
            class = weizmann.samples(k).class;
            bestDistance = d;
            nearestID = k;
        end
    end

    disp(['Classify ' num2str(i) ' ' weizmann.samples(i).class ' >>> ' class ', best distance ' num2str(bestDistance) ' with sample ' num2str(nearestID)]);
    
    % plot
    [~, sort_ids] = sort(distances);
    cla
    hold on;
    plot(distances1(sort_ids),'*-r');
    plot(distances2(sort_ids),'*-g');
    plot(distances3(sort_ids) / 2,'*-b');
    for j=1:length(sort_ids)
        class = weizmann.samples(weizmann.training_ids(sort_ids(j))).class;
        if weizmann.label_str2id.(class) == weizmann.label_str2id.(weizmann.samples(i).class)
            plot([j j], [0 2]);
        end
    end
    hold off;
    xlabel(weizmann.samples(i).class);
    legend({'L2 norm', 'Intersection', 'Chi squared'});
    pause;
end

end

