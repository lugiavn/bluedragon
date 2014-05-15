
e                = dataset.examples(testing_id);

% gen gt segmentation
sequence_start  = round(nx_linear_scale_to_range(e.labels(1).start, 1, e.video_length, 1, 1000));
sequence_end    = round(nx_linear_scale_to_range(e.labels(end).end, 1, e.video_length, 1, 1000));


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
    dtotal = zeros(1000); 
    for j31 = 1:dataset.primitive_action_num
        dtotal = dtotal + detections{j31} .^ dataset.params.n_power;
    end
    dtotal(dtotal == 0) = 10e-100;

    
for i=1:dataset.primitive_action_num
    m.detection.result{i} = (detections{i} .^ dataset.params.n_power) ./ dtotal / dataset.training.detection_means(i);
%     m.detection.result{i}(m.detection.result{i} < 1*10e-3) = 1*10e-3;
%     m.detection.result{i}(m.detection.result{i} > 1*10e1) = 1*10e1;
%     if max(m.detection.result{i}(:)) > 1000
%        m.detection.result{i} = m.detection.result{i} / max(m.detection.result{i}(:)) * 1000;
%     end
    
%     m.detection.result{i}(:) = 1;


    if length(dataset.training.durations{i}) == 0
        m.detection.result{i}(:) = 1;
    end
end
% m.detection.result{4}(:)  = 1;

% perform inference
disp('Perform inference');
m = m_inference_v4(m);

% segmentation
disp('Perform segmentation');
m = m_compute_frame_prob(m);


