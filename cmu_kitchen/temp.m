

parfor i=9:10
    
    training_ids    = 1:length(dataset.examples);
    training_ids(i) = [];
    detectors       = cmu_kitchen_train_detectors(dataset.examples(training_ids));
    detections      = cmu_kitchen_run_detectors(detectors, dataset.examples(i));

    save_detection(i, detections);
    
end