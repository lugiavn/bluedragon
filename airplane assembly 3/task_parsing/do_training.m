
data.training = struct;

%% train the durations


for i=data.training_ids
    for a=data.examples(i).label.actions
        if a.start > 0 & a.end > a.start
            symbolid = data.grammar.name2id.(a.name);
            try
                data.training.durations{symbolid}.data(end+1) = a.end - a.start + 1;
            catch
                data.training.durations{symbolid}.data        = a.end - a.start + 1;
            end
        end
    end
end

for i=1:length(data.training.durations)
    if ~isempty(data.training.durations{i}) & ~isempty(data.training.durations{i}.data)
        data.training.durations{i}.mean = mean(data.training.durations{i}.data);
        data.training.durations{i}.var  = var(data.training.durations{i}.data);
%         disp([num2str(data.training.durations{i}.mean) '  ' num2str(data.training.durations{i}.var)]);
    end
end

%% train the detectors

for i=data.training_ids
    for a=data.examples(i).label.actions
        if a.start > 0 & a.end > a.start
            symbolid = data.grammar.name2id.(a.name);
            
            for t=a.start-8:1:a.start+8
                
                % find reaching hand position
                hands = data.examples(i).handsdetections(t,:);
                [ hands  missing_detections ] = get_reaching_hand( hands );
                if isnan(hands(1)) | hands(2) < 250
                    continue;
                end

                % save
                detector_id = data.grammar.symbols(symbolid).detector_id;
                try
                    data.training.visualdetectors{detector_id}.data(end+1,:) = hands;
                catch
                    data.training.visualdetectors{detector_id}.data          = hands;
                end
            end
        end
    end
end

for i=1:length(data.training.visualdetectors)
    
    % train
    if ~isempty(data.training.visualdetectors{i}) & ~isempty(data.training.visualdetectors{i}.data)
        data.training.visualdetectors{i}.mean = mean(data.training.visualdetectors{i}.data);
        data.training.visualdetectors{i}.var  = var(data.training.visualdetectors{i}.data) * 1;
    end
    
    % check
    v = mvnpdf(data.training.visualdetectors{i}.data, ...
        data.training.visualdetectors{i}.mean, data.training.visualdetectors{i}.var);
    
    % remove 5% worst
    [~, good_ids] = sort(v);
    good_ids = good_ids(round(length(good_ids) * 0.05):end);
    
    % retrain
    if ~isempty(data.training.visualdetectors{i}) & ~isempty(data.training.visualdetectors{i}.data)
        data.training.visualdetectors{i}.mean = mean(data.training.visualdetectors{i}.data(good_ids,:));
        data.training.visualdetectors{i}.var  = var(data.training.visualdetectors{i}.data(good_ids,:)) * 4;
    end
    
%     imagesc(zeros(480, 640));
%     hold on;
%     plot(data.training.visualdetectors{i}.data(good_ids,1), data.training.visualdetectors{i}.data(good_ids,2), '*');
%     hold off;
%     pause;
end

% calculate mean detections
for i=data.training_ids
    
    sequence_length = size(data.examples(i).handsdetections, 1);
    
    for j=1:length(data.training.visualdetectors)
        data.examples(i).test.detection.result{j} = nan(round(sequence_length / data.downsample_ratio));
    end
        
    for t=1:sequence_length
    if mod(t, data.downsample_ratio) == 1  
        % get reaching hand
        hands = data.examples(i).handsdetections(t,:);
        [ reaching_hand  missing_detections ] = get_reaching_hand( hands );
        
        % run detectors & update detection result
        detections_result = run_detectors( data.training.visualdetectors, missing_detections, reaching_hand , 1);
        
        for j=1:length(data.training.visualdetectors)
            if ~isnan(detections_result(j))
                data.examples(i).test.detection.result{j}(ceil(t / data.downsample_ratio),:) = detections_result(j);
            end
        end
    end
    end
end


for j=1:length(data.training.visualdetectors)
     
    v = [];
    
    for i=data.training_ids
        v = [v; data.examples(i).test.detection.result{j}(:)];
    end
     
    v(~(v > 0)) = 0;
    data.training.visualdetectors{j}.mean_detection_score = mean(v) / 2;
    
end

%% save to grammar

for i=1:length(data.grammar.symbols)
	if data.grammar.symbols(i).is_terminal 
        
        % duration
        if strcmp(data.grammar.symbols(i).name, 'null')
            data.grammar.symbols(i).learntparams.duration_mean = 0;
            data.grammar.symbols(i).learntparams.duration_var  = 0;
        else
            data.grammar.symbols(i).learntparams.duration_mean = data.training.durations{i}.mean;
            data.grammar.symbols(i).learntparams.duration_var  = max(300, data.training.durations{i}.var);
        end;
        
        % visual detector
        if strcmp(data.grammar.symbols(i).name, 'null')
%             data.grammar.symbols(i).detector_id = i;
        else
%             data.grammar.symbols(i).detector_id = i;
        end;
   end
end
    
    


