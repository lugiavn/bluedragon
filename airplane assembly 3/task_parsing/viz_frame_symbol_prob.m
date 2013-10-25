
img = [];
labels = {};

for i=1:size(m.frame_symbol_prob, 2)
    if m.grammar.symbols(i).is_terminal
        img(end+1,:) = m.frame_symbol_prob(:,i)';
        labels{end+1} = m.grammar.symbols(i).name;
    end
end


imagesc(img);
for i=1:length(labels)
    
    text(-100, i, labels{i});
end