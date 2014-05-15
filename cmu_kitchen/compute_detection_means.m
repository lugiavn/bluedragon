% for j=1:dataset.primitive_action_num
%     
%     v = [];
%     w = [];
%     
%     for i=1:length(dataset.examples)
% 
%         load(['./cache/detections' num2str(i) '.mat']);
% 
%         dtotal = zeros(1000); 
%         for j31 = 1:dataset.primitive_action_num
%             dtotal = dtotal + detections{j31} .^ dataset.params.n_power;
%         end
%             
%         d = (detections{j} .^ dataset.params.n_power) ./ dtotal;
%         
%         for t=1:1000,
%             v = [v d(t,t:end)];
%         end
%     end
%     
%     dataset.training.detection_means(j) = mean(v);
% end

durations = {};
for e=dataset.examples
    for l=e.labels
        try
            durations{l.id}(end+1) = l.end - l.start + 1;
        catch
            durations{l.id} = single([l.end - l.start + 1]);
        end
    end
end

v = {}; w = {};

for j=1:dataset.primitive_action_num
    v{j} = [];
    w{j} = [];
end

for i=1:length(dataset.examples)
    load(['./cache/detections' num2str(i) '.mat']);
    
    dtotal = zeros(1000); 
    for j31 = 1:dataset.primitive_action_num
        dtotal = dtotal + detections{j31} .^ dataset.params.n_power;
    end
    dtotal(dtotal == 0) = 10e-100;
 
    
    for j=1:dataset.primitive_action_num
        
        d = (detections{j} .^ dataset.params.n_power) ./ dtotal;
        downsamplingrate = dataset.examples(i).video_length / 1000;
        [~, duration_mat] = make_duration_mat(mean(durations{j})/downsamplingrate, max(100,var(durations{j}))/downsamplingrate^2, 1000);
        
        v{j} = [v{j}; d(:)];
        w{j} = [w{j}; duration_mat(:)];
    end
end


for j=1:dataset.primitive_action_num
%     w{j}(:) = 1;
    dataset.training.detection_means(j) = sum(v{j} .* w{j}) / sum(w{j});
end











