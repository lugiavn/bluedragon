

[weizmann.validation.training_ids, weizmann.validation.validation_ids] = choose_random_test_sequences(weizmann, weizmann.training_ids);

% %% k means
% disp 'Validation: perform k-means'
% weizmann = perform_kmeans(weizmann, weizmann.K, weizmann.validation.training_ids);


%% compute histogram

disp 'Validation: compute histograms'

for i=1:length(weizmann.samples)

    weizmann.samples(i).hist = zeros(1, weizmann.K);
    
    for j=weizmann.samples(i).frameclusterings
        
        weizmann.samples(i).hist(j) = weizmann.samples(i).hist(j) + 1;
    
    end

    weizmann.samples(i).hist = weizmann.samples(i).hist / norm(weizmann.samples(i).hist);
end


%% create long validation sequence

disp 'Validation: create sequence'
weizmann.validation.v_sequence = create_test_sequence( weizmann, weizmann.validation.validation_ids);
 

%% compute observation likelihood for test sequence

disp 'Validation: perform detections'
weizmann.validation.v_sequence = perform_detections( weizmann, weizmann.validation.v_sequence);

%% compute mean score

disp 'Validation: compute mean score'

for i=1:10
    
    disp(['-----------']);
    weizmann.validation.means(i).l2_distances = mean(weizmann.validation.v_sequence.l2_distances{i}(:));
    weizmann.validation.means(i).hi_distances = mean(weizmann.validation.v_sequence.hi_distances{i}(:));
    weizmann.validation.means(i).x2_distances = mean(weizmann.validation.v_sequence.x2_distances{i}(:));
    

end






