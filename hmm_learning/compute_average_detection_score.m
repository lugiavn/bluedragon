
results = {};
m.params.T = 300;
for i=data.training_ids
    results{end+1} = compute_raw_detection_score(data.examples(i), m, 1);
end

%%
for k=1:length(m.vdetectors)

    values = [];
    
    for i=1:length(results)
        values = [values; results{i}{k}(results{i}{k} > 0)];
    end
    
    m.vdetectors(k).mean_score = mean(values);
    m.vdetectors(k).mean_score = exp(mean(log(values)));
end
