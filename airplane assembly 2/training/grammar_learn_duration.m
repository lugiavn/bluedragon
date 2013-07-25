
function grammar = grammar_learn_duration(grammar, segment_label_sequences)

% single sequence
if ~iscell(segment_label_sequences)
    segment_label_sequences = {segment_label_sequences};
end


grammar.symbols(1).duration_data = [];

for i=1:length(segment_label_sequences)
for j=1:length(segment_label_sequences{i})
    
    l = segment_label_sequences{i}(j);
    
    if strcmp(l.name, 'start') || strcmp(l.name, 'end')
        continue;
    end

    symbolid = actionname2symbolid(l.name, grammar);
    
    grammar.symbols(symbolid).duration_data(:,end+1) = l.end - l.start + 1;

end
end

for i=1:length(grammar.symbols)
    if ~isempty(grammar.symbols(i).duration_data)
        
        grammar.symbols(i).learntparams.duration_mean = mean(grammar.symbols(i).duration_data);
        grammar.symbols(i).learntparams.duration_var  = var(grammar.symbols(i).duration_data);
        
        disp(['Train duration for action ' grammar.symbols(i).name]);
        disp data
        disp(grammar.symbols(i).duration_data);
        disp mean
        disp(grammar.symbols(i).learntparams.duration_mean);
        disp var
        disp(grammar.symbols(i).learntparams.duration_var);
    end
end