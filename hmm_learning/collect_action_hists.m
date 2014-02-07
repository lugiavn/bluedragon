
h_id = 0;
H    = [];

for i=data.training_ids
    
    s = data.examples(i);
    s = load_i_hist(s, data);
    
    for j=1:length(s.train.actions)
        a = s.train.actions(j);
        if m.grammar.symbols(a.s_id).detector_id > 0
            h = s.i_histograms{4}(:,a.end) - s.i_histograms{4}(:,a.start);
            h = h + 10e-3;
            h = h / sum(h) * min(1, sum(h) / 100);

            h_id = h_id + 1;
            
            s.train.actions(j).hist = h;
            s.train.actions(j).h_id = h_id;
            
            H(:,h_id) = h;
        end
    end
    
    data.examples(i).train.actions = s.train.actions;
end


%% compute K
data.K = zeros(h_id);
for i=1:h_id
    for j=i:h_id
        data.K(i,j) = exp(-chi_square_statistics_fast(H(:,i)', H(:,j)'));
        data.K(j,i) = data.K(i,j);
    end
end








