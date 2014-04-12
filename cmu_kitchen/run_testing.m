
e                = dataset.examples(testing_id);

% gen gt segmentation
sequence_start  = round(nx_linear_scale_to_range(e.labels(1).start, 1, e.video_length, 1, 1000));
sequence_end    = round(nx_linear_scale_to_range(e.labels(end).end, 1, e.video_length, 1, 1000));
segmentation_gt = -ones(1, 1000);

for l=e.labels
    start = round(nx_linear_scale_to_range(l.start, 1, e.video_length, 1, 1000));
    send  = round(nx_linear_scale_to_range(l.end, 1, e.video_length, 1, 1000));
    segmentation_gt(start:send) = l.id;
end

%
m                = struct;
m.grammar        = load_grammar('grammar.txt');
downsamplingrate = e.video_length / 1000;
T                = 1000;
m                = gen_inference_net(m, T, downsamplingrate , 1, 1);

m.g(m.s).start_distribution(:)              = 0;
m.g(m.s).start_distribution(sequence_start) = 1;
m.g(m.s).end_likelihood(:)                  = 0;
m.g(m.s).end_likelihood(sequence_end)       = 1;

% detection
load(['./cache/detections' num2str(testing_id) '.mat']);
for i=1:dataset.primitive_action_num
    m.detection.result{i} = detections{i} .^ 40 / dataset.training.detection_means(i);
    m.detection.result{i}(m.detection.result{i} < 10e-10) = 10e-10;
end
% m.detection.result{4}(:)  = 1;

% perform inference
m = m_inference_v3(m);

% segmentation
m = m_compute_frame_prob(m);

%
% frame_symbol_prob = m.frame_symbol_prob(1:T,:)';
% for i5523=1:length(m.grammar.symbols)
%     if ~m.grammar.symbols(i5523).is_terminal
%         frame_symbol_prob(i5523,:) = 0;
%     end
% end
% [~, segmentation] = max(frame_symbol_prob);
% for t=sequence_start:sequence_end
%     segmentation(t) = m.grammar.symbols(segmentation(t)).detector_id;
% end
% 
% 
% figure(1);
% imagesc(m.frame_symbol_prob(1:T,:)');
% figure(2);
% imagesc([segmentation; segmentation_gt])
% 
% acc1 = sum(segmentation(sequence_start:sequence_end) == segmentation_gt(sequence_start:sequence_end)) / (1 + sequence_end - sequence_start)
% 
% segmentation(:) = 4;
% acc2 = sum(segmentation(sequence_start:sequence_end) == segmentation_gt(sequence_start:sequence_end)) / (1 + sequence_end - sequence_start)


