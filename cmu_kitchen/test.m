

l = dataset.examples(1).labels(20);
T = dataset.examples(1).video_length;

t1 = nx_linear_scale_to_range(single(l.start), 1, T, 1, 1000);
t2 = nx_linear_scale_to_range(single(l.end), 1, T, 1, 1000);

imagesc(detections{l.id}(1:1:end,1:1:end) .^ 15);
hold on;
plot(t2, t1, '*');
hold off;