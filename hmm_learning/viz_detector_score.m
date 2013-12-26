x = [];

for i=1:length(detector_scores)
    if ~isempty(detector_scores{i})
        x(end+1,:) = detector_scores{i};
    end;
end;

figure(3);
imagesc(x);
colorbar;

hold on;
row = 1;
for i=1:length(detector_scores)
    if ~isempty(detector_scores{i})
        for j=m.grammar.symbols(m.grammar.name2id.(['A' num2str(data.examples(i).class)])).prule.right
            plot(m.grammar.symbols(j).detector_id, row, '*w');
        end
        row = row + 1;
    end
end
hold off;




