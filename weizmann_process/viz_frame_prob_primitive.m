weizmann.label_str2id = struct;
weizmann.label_str2id.bend  = 1;
weizmann.label_str2id.jack  = 2;
weizmann.label_str2id.jump  = 3;
weizmann.label_str2id.pjump = 4;
weizmann.label_str2id.run   = 5;
%weizmann.label_str2id.run1  = 5;
%weizmann.label_str2id.run2  = 5;
weizmann.label_str2id.side  = 6;
weizmann.label_str2id.skip  = 7;
%weizmann.label_str2id.skip1 = 7;
%weizmann.label_str2id.skip2 = 7;
weizmann.label_str2id.walk  = 8;
%weizmann.label_str2id.walk1 = 8;
%weizmann.label_str2id.walk2 = 8;
weizmann.label_str2id.wave1 = 9;
weizmann.label_str2id.wave2 = 10;


actions = fieldnames(weizmann.label_str2id);
image = [];
for i=1:length(actions)
    for j=1:length(m.grammar.symbols)
        if weizmann.label_str2id.(actions{i}) == str2num(m.grammar.symbols(j).name)
            image(end+1,:) = m.frame_symbol_prob(:, j)';
            image(end+1,:) = 0;
        end
    end
end
image = image(:,1:length(weizmann.test.sequence_framelabels));
subplot(2,1,1);
imagesc(image);
colormap gray;
axis off
hold on;
for i=1:length(actions)
    text(-70, i, actions{i}, 'FontSize', 15);
end
hold off;
colorbar;
colors = [[100:-1:1]'  [100:-1:1]'  [100:-1:1]'] ./ 100;

% subplot(2,1,2);
% imagesc([ segmentation ; weizmann.test.sequence_framelabels]);
% axis off
colormap(colors);
