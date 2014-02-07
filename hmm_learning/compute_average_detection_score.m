
vnum = zeros(1, length(m.vdetectors));
for k=1:length(m.vdetectors)
    m.vdetectors(k).mean_score = 0
end;

for i=data.training_ids
    result = compute_raw_detection_score(data.examples(i), m, 1);
    
    for k=1:length(m.vdetectors)
        m.vdetectors(k).mean_score = m.vdetectors(k).mean_score + sum(log(result{k}(result{k} > 0)));
        vnum(k) = vnum(k) + length(result{k}(result{k} > 0));
    end
end

%%
for k=1:length(m.vdetectors)

    m.vdetectors(k).mean_score = exp(m.vdetectors(k).mean_score / vnum(k));
    
    assert(m.vdetectors(k).mean_score > 0);
    assert(m.vdetectors(k).mean_score < Inf);
end

clear vnum result;