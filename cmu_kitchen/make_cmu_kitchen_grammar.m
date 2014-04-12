

    
    
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


grammar_str = 'S > ';

for j=dataset.training_ids
    grammar_str = [grammar_str ' sequence' num2str(j) ' or'];
end


grammar_str(end-1:end) = sprintf('\n');

for i=dataset.training_ids
    grammar_str = [grammar_str  'sequence' num2str(i) ' > '];
    for l = dataset.examples(i).labels
        grammar_str = [grammar_str ' action' num2str(l.id) ' and'];
    end
    grammar_str(end-2:end) = sprintf('\n');
end

for i=1:dataset.primitive_action_num
    try
    duration_data = dataset.training.durations{i};
    grammar_str = [grammar_str  '  action' num2str(i) ' '  num2str(i) ' ' ...
        num2str(1 * mean(duration_data)) ' ' ...
        num2str(1 * max(5000, var(duration_data)))];
    grammar_str(end+1) = sprintf('\n');
    catch
    end
end


fileID = fopen('grammar.txt', 'wt');
fprintf(fileID, grammar_str);
fclose(fileID);
