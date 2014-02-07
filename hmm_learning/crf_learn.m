
delete('./cache/*.mat');

m.final_training = 0;

collect_action_hists;
clearvars -except m data;

save d2;

%%
for i_901=data.training_ids
    
    data.train_update_ids = [i_901];
    do_train_vx;
    
    % run classifier
    s = data.examples(i_901);
    s = load_i_hist(s, data);
    compute_raw_svm_score(s, m);

end


%% average
m.final_training = 1;
data.train_update_ids = [];
do_train_vx;
data.K = 0;
compute_average_detection_score

clearvars -except m data;
save d2;

%% learn lamda

if 1
    for gd_learning_rate=[1 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1 0.09]
    for i_352=nx_randomswap(data.training_ids)
        
        disp(['Inference on sequence ' num2str(i_352) ', class ' num2str(data.examples(i_352).class)]);
        [s newm correct_classification] = perform_inf_n_update_timing(data.examples(i_352), m, 0.8);
        gd_compute_derivative;
%         if ~correct_classification
            gd_update_params;
%         end;

        %
        nx_figure(99);
        imagesc(reshape([m.vdetectors().lamda], [length(m.classes) length(m.vdetectors) / length(m.classes)])); colorbar;
        nx_figure(199);
        imagesc(reshape([m.vdetectors().lamda2], [length(m.classes) length(m.vdetectors) / length(m.classes)])); colorbar;
        nx_figure(1);
        m_plot_distributions(newm, fields(newm.grammar.name2id)', {'S'});
        xlim([0 newm.params.T*2]);
        ylim([0 1]);
        pause(0.1);
        
        
        
    end
    end
end



%% learn timing
if 1
    for i_901=data.training_ids
        [data.examples(i_901) newm] = perform_inf_n_update_timing(data.examples(i_901), m);
    end
end


























