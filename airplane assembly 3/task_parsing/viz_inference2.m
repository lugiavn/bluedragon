
nx_figure(2); subplot(1,1,1); cla;

% plot action label
text(1+100, -200, 'Groundtruth Label:', 'FontSize', 16, 'BackgroundColor',[1 0.5 0.5]);
text(1+100, 600-750, 'Current true action: ');
text(1+100, 650-750, 'Possible next action: ');
action_id = find (([test.label.actions.start] <= t) .* ([test.label.actions.end] >= t));
if length(action_id) == 1

    sid1 = data.grammar.name2id.(test.label.actions(action_id).name);
    sid2 = data.grammar.name2id.(test.label.actions(min(action_id+1, length(test.label.actions))).name);

    text(310+100, 600-750, [test.label.actions(action_id).name ' (Bin ' num2str(data.grammar.symbols(sid1).detector_id) ')'], 'Interpreter','none');
    if strcmp(test.label.actions(action_id).name, 'body4')
        text(310+100, 650-750, 'wheel1 (Bin 3)', 'Interpreter','none');
        text(310+100, 650+1*30-750, 'nose_ab1 (Bin 3)', 'Interpreter','none');
        text(310+100, 650+2*30-750, 'nose_c1 (Bin 3)', 'Interpreter','none');
    elseif strcmp(test.label.actions(action_id).name, 'wheel2')
        text(310+100, 650-750, 'nose_ab1 (Bin 3)', 'Interpreter','none');
        text(310+100, 650+1*30-750, 'nose_c1 (Bin 3)', 'Interpreter','none');
    elseif strcmp(test.label.actions(action_id).name, 'nose_ab4')
        text(310+100, 650-750, 'wing_a1 (Bin 3)', 'Interpreter','none');
        text(310+100, 650+1*30-750, 'wing_b1 (Bin 3)', 'Interpreter','none');
        text(310+100, 650+2*30-750, 'tail_a1 (Bin 3)', 'Interpreter','none');
        text(310+100, 650+3*30-750, 'tail_b1 (Bin 3)', 'Interpreter','none');
    elseif strcmp(test.label.actions(action_id).name, 'nose_c3')
        text(310+100, 650-750, 'wing_c1 (Bin 3)', 'Interpreter','none');
        text(310+100, 650+1*30-750, 'tail_c1 (Bin 3)', 'Interpreter','none');
    else
        text(310+100, 650-750, [data.grammar.symbols(sid2).name ' (Bin ' num2str(data.grammar.symbols(sid2).detector_id) ')'], 'Interpreter','none');
    end
else
    text(310+100, 600-750, 'N/A', 'Interpreter','none');
    text(310+100, 650-750, 'N/A', 'Interpreter','none');
end

hold off;




% plot raw detections
subplot(6, 3, [2 3]);
cla;
hold on;
for i=1:5
    plot(m.detection.result{i}(:,1), 'color', nxtocolor(i));
end
hold off;
%     hold on; plot([timestep timestep], [0 200]); hold off;
%     ylim([0 100]);
legend('Bin 1 reaching raw detection', 'Bin 2 reaching raw detection', 'Bin 3 reaching raw detection', 'Bin 4 reaching raw detection', 'Bin 5 reaching raw detection');

hold on;
text(20, 110, 'Raw detection of reachings', 'FontSize', 16, 'BackgroundColor',[1 0.5 0.5]);
hold off;

ylim([0 100]);

% plot distributions
subplot(5, 3, [5 6 8 9]);
m_plot_distributions(m, {'body1', 'body4', 'wheel1', 'nose_ab1', 'nose_ab4', 'wing_b1', 'wing_b4', 'tail_b1', 'tail_b4', 'sticker'}, {}, 1, test.label.actions);
hold on; plot([timestep timestep], [0 2]); text(timestep, 1.1, ' Current time'); hold off;
ylim([0 1.1]);


% subplot(5, 3, [8 9]);
% %m_plot_distributions(m, {'body1', 'body2', 'body3', 'body4', 'wheel1', 'wheel2', 'nose_ab1', 'nose_ab2', 'nose_ab3', 'nose_ab4', 'wing_a1', 'tail_a1', 'tail_a2', 'tail_a3'}, {});
% m_plot_distributions(m, { 'nose_ab1', 'wing_a1', 'tail_a1'}, {}, 1, test.label.actions);
% hold on; plot([timestep timestep], [0 2]); text(timestep, 1, ' Current time'); hold off;
% ylim([0 1.1]);

subplot(5, 3, [11 12 14 15]);
m = m_compute_frame_prob(m);
actions = {'S', 'Body', 'Wheel', 'Nose_AB', 'Nose_C', 'Wing_A', 'Tail_A', 'Wing_B', 'Tail_B', 'Wing_C', 'Tail_C', 'sticker'};
m_plot_frame_label_distribution(m, actions);
xlim([0 700]);

hold on;
plot([timestep timestep], [-100 100], 'white');
hold off;

hold on;
text(100, 15, 'Output: distributions of every time-steps'' label', 'FontSize', 16, 'BackgroundColor',[1 0.5 0.5]);
hold off;


% image
if t <= vid.NumberOfFrames
    subplot(4, 3, [1 4]);
    imshow(f);
    hold on;
    text(5, 20, num2str(t), 'BackgroundColor',[.7 .9 .7]);;
    if ~isnan(hands(1))
        circle2(hands(1), hands(2), 50, [1 1 1]);
    end
    if ~isnan(hands(3))
        circle2(hands(3), hands(4), 50, [1 1 1]);
    end
    if ~isnan(reaching_hand(1))
        circle2(reaching_hand(1), reaching_hand(2), 50, [1 1 1]);
    end
    text(50, 450, 'Bin 1', 'BackgroundColor',[.7 .9 .7]);
    text(50+120, 450, 'Bin 2', 'BackgroundColor',[.7 .9 .7]);
    text(50+120*2, 450, 'Bin 3', 'BackgroundColor',[.7 .9 .7]);
    text(50+120*3, 450, 'Bin 4', 'BackgroundColor',[.7 .9 .7]);
    text(50+120*4, 450, 'Bin 5', 'BackgroundColor',[.7 .9 .7]);


    text(-30, -30, 'Input frame & Hand detections', 'FontSize', 16, 'BackgroundColor',[1 0.5 0.5]);

    hold off;
end


%% temp
% subplot(1, 1, 1);
% cla;
% m_plot_distributions(m, {'body1', 'wheel1', 'nose_ab1', 'nose_c1', 'wing_a1', 'tail_a1', 'wing_b1', 'tail_b1', 'wing_c1', 'tail_c1'}, {});
% % m_plot_distributions(m, {'body1', 'body2', 'body3', 'body4', 'wheel1', 'wheel2', 'nose_ab1',  'nose_ab2',  'nose_ab3',  'nose_ab4', 'tail_a1', 'tail_a2', 'tail_a3', 'wing_a1', 'wing_a2', 'wing_a3'}, {});
% %m_plot_distributions(m, {'nose_ab1', 'nose_ab2', 'nose_ab3', 'nose_ab4', 'wing_a1', 'wing_a2', 'wing_a3', 'tail_a1', 'tail_a2', 'tail_a3'}, {}, 1, test.label.actions);
% hold on; plot([timestep timestep], [0 2], 'LineWidth', 3); text(timestep, 1.1, [' Current time = ' num2str(timestep)]); hold off;
% ylim([0 1.1]);
