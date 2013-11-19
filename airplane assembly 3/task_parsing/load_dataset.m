
%% init
data.path = '/home/namvo/airplane assembly 3/real_dataset';
data.FPS  = 30;

%% read the grammar

data.grammar = load_grammar([data.path '/grammar.txt']);

%% read the examples & groundtruth labels

c = 0;

for file = dir(data.path)'
    
    if length(file.name) < 4 | ~strcmp(file.name(end-3:end), '.avi')
        continue;
    end
    c = c + 1;
    
    data.examples(c).filename   = file.name;
    data.examples(c).label.file = strrep(file.name, '.avi', '.txt');
    
    % read label file
    fileID = fopen([data.path '/' data.examples(c).label.file]);
    assert(fileID > 0);
    for i=1:1000
        line = fgetl(fileID);
        if ~ischar(line)
            break;
        end
        
        words = regexp(line, '\s*', 'split'); assert(length(words) >= 3);
        data.examples(c).label.actions(i).name  = words{1};
        data.examples(c).label.actions(i).start = str2num(words{2});
        data.examples(c).label.actions(i).end   = str2num(words{3});
    end
    for i=1:length(data.examples(c).label.actions)
        if data.examples(c).label.actions(i).end == 0,
            data.examples(c).label.actions(i).end = data.examples(c).label.actions(i+1).start - 1;
        end
    end
    fclose(fileID);
    
    % read hand detections
    data.examples(c).handsdetections = dlmread([data.path '/' strrep(file.name, '.avi', '.handsdetections.txt')]);
    data.examples(c).length          = size(data.examples(c).handsdetections, 1);
    
    % compute groundtruth primitive action segmentation
    data.examples(c).gt_segmentation = nan(1, data.examples(c).length);
    for a=data.examples(c).label.actions
        action_id = data.grammar.name2id.(a.name);
        data.examples(c).gt_segmentation(a.start:a.end) = action_id;
    end
    
    % model label
    data.examples(c).model = 'X';
    for a=data.examples(c).label.actions
        if strcmp(a.name, 'wing_a1')
            data.examples(c).model = 'A';
        elseif strcmp(a.name, 'wing_b1')
            data.examples(c).model = 'B';
        elseif strcmp(a.name, 'wing_c1')
            data.examples(c).model = 'C';
        end
    end
end




