


m = m_compute_frame_prob(m);

%%
actions = {'Body', 'Wheel', 'Nose_AB', 'Nose_C', 'Wing_A', 'Tail_A', 'Wing_B', 'Tail_B', 'Wing_C', 'Tail_C', 'sticker'};

dshow = [];

for i=1:length(actions)
    
    dshow(end+1,:) = m.frame_symbol_prob(:, m.grammar.name2id.(actions{i}))';
    
end

imagesc(dshow);

hold on;
for i=1:length(actions)
    
    text(-80,i, actions{i});

end
hold off;
set(gca,'YTick',[]);