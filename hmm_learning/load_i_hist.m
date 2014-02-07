function s = load_i_hist(s, data)

    if isnan(s.i_histograms{1})
    for u=1:length(data.descriptor_names)
        s.i_histograms{u} = dlmread(strrep([data.path '/' s.path], '.avi', ['.' data.descriptor_names{u} '_ihist.txt']));
    end
    end
end