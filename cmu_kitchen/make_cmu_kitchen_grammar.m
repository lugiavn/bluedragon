
%% compute duration model
durations = {};
for e=dataset.examples(dataset.training_ids)
    for l=e.labels
        try
            durations{l.id}(end+1) = l.end - l.start + 1;
        catch
            durations{l.id} = single([l.end - l.start + 1]);
        end
    end
end

dataset.training.durations = durations;


%% gen grammar

breaking_part = 16;

training_ids = dataset.training_ids;
if GROUNDTRUTH_GRAMMAR == 1
    training_ids = testing_id;
elseif GROUNDTRUTH_GRAMMAR == 2
    training_ids = [training_ids testing_id];
end

grammar_str = 'S > ';

for i=1:breaking_part
    grammar_str = [grammar_str ' part' num2str(i) ' and'];
end

grammar_str(end-2:end) = sprintf('\n');

for i=1:breaking_part
    grammar_str = [grammar_str 'part' num2str(i) ' > '];
    for j=training_ids
        grammar_str = [grammar_str ' sequence' num2str(j) 'part' num2str(i) ' or'];
    end
    grammar_str(end-1:end) = sprintf('\n');
end


for i=training_ids
    e = dataset.examples(i);
    for j=1:breaking_part
        grammar_str = [grammar_str  'sequence' num2str(i) 'part' num2str(j) ' > '];
        for k = 1:length(dataset.examples(i).labels)

           l = dataset.examples(i).labels(k);
            
            
%             timeindex = nx_linear_scale_to_range((l.start+l.end)/2, e.labels(1).start, e.labels(end).end, 0.000001, breaking_part);
%             if ceil(timeindex) == j
%                 grammar_str = [grammar_str ' action' num2str(l.id) ' and'];
%             end

            if k <= length(dataset.examples(i).labels) * j / breaking_part
            if k > length(dataset.examples(i).labels) * (j-1) / breaking_part
                
                grammar_str = [grammar_str ' action' num2str(l.id) ' and'];
            end;
            end 
            
        end
        grammar_str(end-2:end) = sprintf('\n');
    end
end

for i=1:dataset.primitive_action_num
    try
        duration_data = dataset.training.durations{i};
        assert(length(duration_data) > 0);
        grammar_str = [grammar_str  '  action' num2str(i) ' '  num2str(i) ' ' ...
            num2str(1 * mean(duration_data)) ' ' ...
            num2str(1 * max(100, var(duration_data)))];
        grammar_str(end+1) = sprintf('\n');
    catch
        disp(['No duration data for action ' num2str(i) ]);
        grammar_str = [grammar_str  '  action' num2str(i) ' '  num2str(i) ' ' ...
            num2str(20) ' ' ...
            num2str(10000)];
        grammar_str(end+1) = sprintf('\n');
        
    end
end


fileID = fopen('grammar.txt', 'wt');
fprintf(fileID, grammar_str);
fclose(fileID);
