    data.train_update_ids = [i_901];
    do_train_vx;
    
    % run classifier
    s = data.examples(i_901);
    s = load_i_hist(s, data);
    compute_raw_svm_score(s, m);