function m = m_plot_frame_label_distribution( m, actions )
%M_PLOT_FRAME_LABEL_DISTRIBUTION Summary of this function goes here
%   Detailed explanation goes here

dshow = [];

for i=1:length(actions)
    
    dshow(end+1,:) = m.frame_symbol_prob(:, m.grammar.name2id.(actions{i}))';
    
end

imagesc(dshow);

hold on;
for i=1:length(actions)
    
    text(-5,i, actions{i}, 'Interpreter', 'none', 'HorizontalAlignment', 'right');

    plot([0 1000], [0.5 0.5] + i, 'white');
end
hold off;
set(gca,'YTick',[]);

end

