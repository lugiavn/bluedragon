

%% set up inference structure
downsample_ratio          = 9;
T                         = round(6000 / downsample_ratio);
m                         = struct;
m.grammar                 = data.grammar;
m                         = gen_inference_net(m, T, downsample_ratio, 100);

% structure for detection result
m.detection = struct;
for i=1:length(data.grammar.symbols)
    s = data.grammar.symbols(i);
    if s.is_terminal
        m.detection.result{s.detector_id} = ones(T);
    end
end

%% process

for t=1:99999999
    
    if mod(t, downsample_ratio) ~= floor(downsample_ratio/2)
        continue;
    end
    timestep =  ceil(t / downsample_ratio);
    if timestep > T || t > test.length + 300
        break;
    end
    
    if t <= test.length
        
        % get reaching hand
        hands = test.handsdetections(t,:);
        [ reaching_hand  missing_detections ] = get_reaching_hand( hands );
        
        % run detectors & update detection result
        detections_result = run_detectors( data.training.visualdetectors, missing_detections, reaching_hand );
        
        % save detections
        for i=1:length(data.training.visualdetectors)
            if ~isnan(detections_result(i))
                m.detection.result{i}(timestep,:) = detections_result(i);
            end
        end
    end
    
end



%% new inference

Tx = round(test.length/data.downsample_ratio);
    
for i=1:length(m.detection.result)
    m.detection.result{i}(Tx:end,Tx:end) = 0;
end

m = m_inference_v3(m);
m = m_compute_frame_prob(m);
imagesc(m.frame_symbol_prob');

[~, segmentation] = max(m.frame_symbol_prob(1:Tx,:)');
for t=1:length(segmentation)
    if m.frame_symbol_prob(t, segmentation(t)) < 1 - sum(m.frame_symbol_prob(t, :))
        segmentation(t) = nan;
    end
end

segmentation = imresize(segmentation, [1 test.length], 'nearest');
imagesc([segmentation; test.gt_segmentation])
colormap(rand(1000,3));

% compute accuracy
x = segmentation;
y = test.gt_segmentation;
x(isnan(x)) = -1;
y(isnan(y)) = -1;
segmentation_acc = sum(x == y) / test.length;
disp(['Segmentation accuracy: ' num2str(segmentation_acc)]);













