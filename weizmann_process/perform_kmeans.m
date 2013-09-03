function weizmann = perform_kmeans( weizmann, K, training_ids )
%PERFORM_KMEANS Summary of this function goes here
%   Detailed explanation goes here


feature_vectors = [];

for i=training_ids
    for j=1:size(weizmann.samples(i).distance_transform,3)
        f = weizmann.samples(i).distance_transform(:,:,j);
        feature_vectors(:,end+1) = f(:);
    end
end


feature_vectors = uint8(feature_vectors / 100 * 255);
[weizmann.C A] = vl_ikmeans(feature_vectors(:,1:10:end), K);

%% k means classify
for i=1:length(weizmann.samples)
    
    weizmann.samples(i).frameclusterings = [];
    
    for t=1:size(weizmann.samples(i).distance_transform,3)
        f  = weizmann.samples(i).distance_transform(:,:,t);
        f  = f(:);
        f  = uint8(f / 100 * 255);
        weizmann.samples(i).frameclusterings(t) = vl_ikmeanspush(f, weizmann.C);
    end
end



end

