clear; clc; close all

load batch_ms;
%%
total_lerrors   = nan(length(batch_data), 100);
total_entropies = nan(length(batch_data), 100);
total_model_cs  = nan(length(batch_data), 100);

for i11=1:length(batch_data)
    
    data = batch_data{i11};
    test = data{1};
    ms   = data{2};
    
    lerrors   = nan(1, length(ms));
    entropies = nan(1, length(ms));
    model_cs  = nan(1, length(ms));
    
%     for t=1:length(ms)
    for t=1:test.length / ms{1}.params.downsample_ratio
        
        m = ms{t};
        if isempty(m)
            continue;
        end
        
        lerror = 0;
        entropy = 0;
        
        for a=test.label.actions
            
            real_timing = a.start / m.params.downsample_ratio;
            
            d = m.grammar.symbols(m.grammar.name2id.(a.name)).start_distribution;
            d = d / sum(d);
            estimated_timing = sum([1:m.params.T] .* d);
            
            lerror = lerror + abs(estimated_timing - real_timing);
            entropy = entropy + sum(d(d > 0) .* (-log(d(d>0))));
        end
        
        lerror = lerror / length(test.label.actions);
        entropy = entropy / length(test.label.actions);
        
        lerrors(t)   = lerror * m.params.downsample_ratio / 30;
        entropies(t) = entropy;
        
        % model classification
        models = [sum(m.grammar.symbols(m.grammar.name2id.Wing_A).start_distribution);
                  sum(m.grammar.symbols(m.grammar.name2id.Wing_B).start_distribution);
                  sum(m.grammar.symbols(m.grammar.name2id.Wing_C).start_distribution)];
        [~, maxmodel] = max(models);
        if strcmp(test.label.actions(end-1).name(end), '3') & maxmodel == 1
            model_cs(t) = 1;
        elseif strcmp(test.label.actions(end-1).name(end), '4') & maxmodel == 2
            model_cs(t) = 1;
        elseif strcmp(test.label.actions(end-1).name(end), '6') & maxmodel == 3
            model_cs(t) = 1;
        else
            model_cs(t) = 0;
        end
    end
    
    lerrors = lerrors(lerrors >= 0);
    entropies = entropies(~isnan(entropies));
    model_cs  = model_cs(~isnan(model_cs));
    
    total_lerrors(i11,:) = imresize(lerrors, [1 100], 'nearest');
    total_entropies(i11,:) = imresize(entropies, [1 100], 'nearest');
    total_model_cs(i11,:) = imresize(model_cs, [1 100], 'nearest');
    
%     plot(lerrors);
%     pause;
%     plot(entropies);
%     pause;
end
 
subplot(1,3,1);
plot(mean(total_model_cs))
ylabel('Model classification error');
xlabel('Observation ratio (%)');

subplot(1,3,2);
plot(mean(total_lerrors));
ylabel('localization error (s)');
xlabel('Observation ratio (%)');


subplot(1,3,3);
plot(mean(total_entropies))
ylabel('Entropy');
xlabel('Observation ratio (%)');






