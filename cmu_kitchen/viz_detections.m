
% clear;
% load d3;


action_id = 30;
    
for i=1:12
    
    load(['cache/detections' num2str(i) '.mat']);
    
    subplot(3, 4, i);
    imagesc(detections{action_id} .^ 50); colormap gray; colorbar;
    hold on;
    for l=dataset.examples(i).labels
        if l.id == action_id
            plot(l.end_map, l.start_map, '*r');
        end
    end
    hold off;

end


