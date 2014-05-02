
dataset.training_ids = 1:13;

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

breaking_part = 2;

grammar_str = 'S > ';

for i=1:breaking_part
    grammar_str = [grammar_str ' part' num2str(i) ' and'];
end

grammar_str(end-2:end) = sprintf('\n');

for i=1:breaking_part
    grammar_str = [grammar_str 'part' num2str(i) ' > '];
    for j=dataset.training_ids
        grammar_str = [grammar_str ' sequence' num2str(j) 'part' num2str(i) ' or'];
    end
    grammar_str(end-1:end) = sprintf('\n');
end


for i=dataset.training_ids
    for j=1:breaking_part
        grammar_str = [grammar_str  'sequence' num2str(i) 'part' num2str(j) ' > '];
        for k = 1:length(dataset.examples(i).labels)
            if k <= length(dataset.examples(i).labels) * j / breaking_part
            if k > length(dataset.examples(i).labels) * (j-1) / breaking_part
            l = dataset.examples(i).labels(k);
            grammar_str = [grammar_str ' action' num2str(l.id) ' and'];
            end;
            end
        end
        grammar_str(end-2:end) = sprintf('\n');
    end
end

for i=1:dataset.primitive_action_num
    duration_data = dataset.training.durations{i};
    grammar_str = [grammar_str  '  action' num2str(i) ' '  num2str(i) ' ' ...
        num2str(1 * mean(duration_data)) ' ' ...
        num2str(1 * max(10, var(duration_data)))];
    grammar_str(end+1) = sprintf('\n');
end


fileID = fopen('grammar.txt', 'wt');
fprintf(fileID, grammar_str);
fclose(fileID);
