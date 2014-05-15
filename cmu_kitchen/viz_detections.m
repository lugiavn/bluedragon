
% clear;
% load d3;


action_id = 29;
   
xl = struct;

for i=4
    
    load(['cache/detections' num2str(i) '.mat']);
    
%     subplot(3, 4, i);
detections{action_id}(detections{action_id} == 0) = 2;
    imagesc((2-detections{action_id}) .^ 10); colormap gray; colorbar;
    hold on;
    for l=dataset.examples(i).labels
        if l.id == action_id
            plot(l.end_map, l.start_map, '*r');
            xl = l;
        end
    end
    hold off;

end

%% vz action scores

s = zeros(1, dataset.primitive_action_num);

for i=1:dataset.primitive_action_num
    s(i) = (2-detections{i}(xl.start_map, xl.end_map)) .^ 10;
end

s(end+1) = (2 - detections{action_id}(xl.start_map, xl.end_map)) .^ 10;

plot(s);