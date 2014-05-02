
dataset = struct;
dataset.path =  'D:/myr/datasets/activity/cmu_kitchen';

%% read file name
icount = 0;
for i=1:100

    label_path = sprintf('%s/S%02d_Brownie/labels.dat', dataset.path, i);
    
    % video path
    top_video  = '';
    video_path = '';
    files = dir(sprintf('%s/S%02d_Brownie_Video/', dataset.path, i));
    if length(files) > 2
        for f=files'
            if findstr(f.name, '7150991') & findstr(f.name, '.avi')
                video_path = sprintf('%s/S%02d_Brownie_Video/%s', dataset.path, i, f.name);
            end
            if findstr(f.name, '7151020') & findstr(f.name, '.avi')
                top_video = sprintf('%s/S%02d_Brownie_Video/%s', dataset.path, i, f.name);
            end
        end
    end
    
    % ok
    if exist(label_path) & exist(video_path)
        icount = icount + 1;
        dataset.examples(icount).subject_id = i;
        dataset.examples(icount).video_path = video_path;
        dataset.examples(icount).top_video  = top_video;
        dataset.examples(icount).label_path = label_path;
        dataset.examples(icount).offset     = -1;
    end
end

%% read labels

for i=1:length(dataset.examples)
    
    file   = fopen(dataset.examples(i).label_path);
    labels = struct;
    N      = 0;

    while 1
        line = fgetl(file);
        if line < 0
            break;
        end
        N = N + 1;
        elements = textscan(line, '%d %d %s');

        labels(N).start = single(elements{1});
        labels(N).end   = single(elements{2});
        labels(N).text  = elements{3}{1};

    end

    fclose(file);
    
    dataset.examples(i).labels = labels;
end

%% offset
 
dataset.examples(find([dataset.examples.subject_id] == 7)).offset = 508;
dataset.examples(find([dataset.examples.subject_id] == 8)).offset = 300;
dataset.examples(find([dataset.examples.subject_id] == 9)).offset = 226;
% dataset.examples(find([dataset.examples.subject_id] == 10)) = 1;
% dataset.examples(find([dataset.examples.subject_id] == 11)) = 1;
dataset.examples(find([dataset.examples.subject_id] == 12)).offset = 400;
dataset.examples(find([dataset.examples.subject_id] == 13)).offset = 290;
dataset.examples(find([dataset.examples.subject_id] == 14)).offset = 386;
% dataset.examples(find([dataset.examples.subject_id] == 15)) = ;
dataset.examples(find([dataset.examples.subject_id] == 16)).offset = 168;
dataset.examples(find([dataset.examples.subject_id] == 17)).offset = 236;
dataset.examples(find([dataset.examples.subject_id] == 18)).offset = 316;
dataset.examples(find([dataset.examples.subject_id] == 19)).offset = 354;
dataset.examples(find([dataset.examples.subject_id] == 20)).offset = 212;
% dataset.examples(find([dataset.examples.subject_id] == 21)) = ;
dataset.examples(find([dataset.examples.subject_id] == 22)).offset = 262;
dataset.examples(find([dataset.examples.subject_id] == 24)).offset = 360;

% adjust label timing
for i=1:length(dataset.examples)
    for j=1:length(dataset.examples(i).labels)
       
        dataset.examples(i).labels(j).start = dataset.examples(i).labels(j).start + dataset.examples(i).offset;
        dataset.examples(i).labels(j).end   = dataset.examples(i).labels(j).end + dataset.examples(i).offset;
    end
end

%% 

% 3 (9) videos dont sync
% 5 (13) nt
% 9 (18) nt

%% read video length

for i=1:length(dataset.examples)
    vid = VideoReader(dataset.examples(i).video_path);
    dataset.examples(i).video_length = vid.NumberOfFrames;
end


%% primitive action id

dataset.pname2id = struct;

icount = 0;

for i=1:length(dataset.examples)
    for j=1:length(dataset.examples(i).labels)

        pname = strrep(dataset.examples(i).labels(j).text, '-', 'x');
        try
            dataset.examples(i).labels(j).id = dataset.pname2id.(pname);
        catch
            icount = icount + 1;
            dataset.pname2id.(pname) = icount;
            dataset.examples(i).labels(j).id = dataset.pname2id.(pname);
        end

    end
end

dataset.primitive_action_num = icount;


%% map time

for i=1:length(dataset.examples)
    e = dataset.examples(i);
    for j=1:length(e.labels)
        l = e.labels(j);
        dataset.examples(i).labels(j).start_map = round(nx_linear_scale_to_range(l.start, 1, e.video_length, 1, 1000));
        dataset.examples(i).labels(j).end_map   = round(nx_linear_scale_to_range(l.end, 1, e.video_length, 1, 1000));
    end
end











