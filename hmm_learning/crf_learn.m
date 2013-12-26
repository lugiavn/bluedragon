

m.final_training = 0;

delete('./cache/*.mat')

m.params.T = 300;

for i_901=data.training_ids
    
    data.train_update_ids = [i_901];
    
    % train svm
    do_train_vx;
    
    % run classifier
    compute_raw_svm_score(data.examples(i_901), m);

end

%% average
m.final_training = 1;
data.train_update_ids = [];
do_train_vx;
compute_average_detection_score

%% learn lamda
if 1
    for gd_learning_rate=[1 1 1 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1 0.1]
%     for gd_learning_rate=ones(1, 10) * 0.01;
%     for gd_learning_rate=[0.1 0.1 0.1 0.1 0.1 0.1]
    for i_352=nx_randomswap(data.training_ids)
        disp(['Inference on sequence ' num2str(i_352) ', class ' num2str(data.examples(i_352).class)]);
        [s newm correct_classification] = perform_inf_n_update_timing(data.examples(i_352), m);
        temp;
        if ~correct_classification
            gd_update_params;
        end;

        %
        figure(99);
        imagesc(reshape([m.vdetectors().lamda], [6 9])); colorbar;
        figure(199);
        imagesc(reshape([m.vdetectors().lamda2], [6 9])); colorbar;
        pause(1);
        figure(1);
    end
    end
end



%% learn timing
if 1
    for i_901=data.training_ids
        [data.examples(i_901) newm] = perform_inf_n_update_timing(data.examples(i_901), m);
    end
end


























