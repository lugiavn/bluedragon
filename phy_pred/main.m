

%%
clc; clear;
gen_data;
detectors = {};


%%
for i=1:2
    ids = find([data.examples.detector_id] == i);
    ids = setdiff(ids, data.testing_ids);
    detectors{i} = m_train_detectors(data.examples(ids));
    
end

% train expected score
for i=1:2
for j=1:length(detectors{i}.segments)
    v = [];
    
    for e=data.examples
    for t=1:e.length
        v(end+1) = max(-100, log( mvnpdf([e.positions(:,t); e.velocity(:,t)]', detectors{i}.segments(j).mean, detectors{i}.segments(j).var) ));    
    end
    end
    
    detectors{i}.segments(j).expected_score = mean(v);
end
end

%% viz detector

cla
hold on;
d = detectors{1};
for i=1:length(d.segments)
    
    plot(d.segments(i).mean(1), d.segments(i).mean(2), '*r');
    plot_gaussian_ellipsoid(d.segments(i).mean(1:2), d.segments(i).var(1:2,1:2)', 3);
    
end
d = detectors{2};
for i=1:length(d.segments)
    
    plot(d.segments(i).mean(1), d.segments(i).mean(2), '*y');
    plot_gaussian_ellipsoid(d.segments(i).mean(1:2), d.segments(i).var(1:2,1:2)', 3);
    
end
hold off;

%% test classifier
disp 'Test'
for e=data.examples(data.testing_ids)
    
    class1_score = m_detector_evaluate(detectors{1}, e);
    class2_score = m_detector_evaluate(detectors{2}, e);
    
    disp(['Class ' num2str(e.class) '. Scores: ' num2str(class1_score), ', ' num2str(class2_score)]);
    
end

% test classifier 50%
disp 'Test 50'
for e=data.examples(data.testing_ids)
    
    e.positions = e.positions(:,1:round(end*0.6));
    
    class1_score = m_detector_evaluate(detectors{1}, e);
    class2_score = m_detector_evaluate(detectors{2}, e);
    
    disp(['Class ' num2str(e.class) '. Scores: ' num2str(class1_score), ', ' num2str(class2_score)]);
    
end

%% Inference
m.grammar = load_grammar('grammar.txt');

m = gen_inference_net(m, 300, 1, 100, 300);

% m = m_inference_v3(m);
% 
% m_plot_distributions(m, {'a1', 'a2'}, {'a1', 'a2'});

%% online

test = data.examples(data.testing_ids(2));

for t=3
    
    % run detection
    m.detection.result{1} = ones(m.params.T) * 1;
    m.detection.result{2} = ones(m.params.T) * 1;
    
%     for t1=1:m.params.T
%     for t2=t1:m.params.T
%         
%         segment           = test;
%         segment.positions = segment.positions(:,t1:min(t,t2));
%         segment.velocity  = segment.velocity(:,t1:min(t,t2));
%         segment.length    = t2 - t1 + 1;
%         
%         v1 = m_detector_evaluate(detectors{1}, segment);
%         v2 = m_detector_evaluate(detectors{2}, segment);
%         
%         m.detection.result{1}(t1, t2) = exp(v1/500/length(detectors{1}.segments));
%         m.detection.result{2}(t1, t2) = exp(v2/500/length(detectors{2}.segments));
%         
%     end
%     end

    % inf
    m = m_inference_v3(m);
    
    figure(1);
    imagesc(m.detection.result{1}); colorbar;
    figure(2);
    imagesc(m.detection.result{2}); colorbar;
    figure(3);
    m_plot_distributions(m, {'a1', 'a2'}, {'a1', 'a2'});
    pause(0.1);
end














