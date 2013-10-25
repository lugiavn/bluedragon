


function grammar = load_grammar(file)



grammar.starting    = 1;
grammar.rules       = struct([]);
grammar.symbols     = struct([]);

fid = fopen(file);
assert(fid > 0);

while ~feof(fid)
    
    % read line
    s = fgetl(fid);
    if length(s) < 3, continue; end;
    disp(['read line:  ' s]);
    
    % parse
    %tokens = regexp(s, '\s', 'split');
    %tokens = strread(s,'%s','delimiter',' ');
    tokens = textscan(s, '%s');
    tokens = tokens{1};
    
    if strcmp(tokens{1}, '%')
        continue;
    end
    
    % get left
    left_id = [];
    try
        left_id = find(strcmp({grammar.symbols.name}, tokens{1}));
    end;
    if isempty(left_id)
        
        % ----- add new symbol
        left_id = length(grammar.symbols) + 1;
        
        grammar.symbols(left_id).name                        = tokens{1};
        grammar.symbols(left_id).detector_id                 = nan;
        grammar.symbols(left_id).learntparams.duration_mean = nan;
        grammar.symbols(left_id).learntparams.duration_var  = nan;
    end
    grammar.symbols(left_id).is_terminal = 0;
    
    % check for terminal info line
    if ~strcmp(tokens{2}, '>')
        grammar.symbols(left_id).is_terminal = 1;
        grammar.symbols(left_id).detector_id = str2num(tokens{2});
        
        if length(tokens) == 4
            grammar.symbols(left_id).learntparams.duration_mean = str2num(tokens{3});
            grammar.symbols(left_id).learntparams.duration_var  = str2num(tokens{4});
        end
        
        continue;
    end
    
    % get right
    right_ids   = [];
    right_probs = [];
    for k=3:2:length(tokens)
        
        or_prob = 1;
        thename = tokens{k};
        findat  = find(thename == '@');
        if length(findat) == 1
            or_prob = str2num(thename(findat+1:end));
            thename = thename(1:findat-1);
        end

        rid = find(strcmp({grammar.symbols.name}, thename));
        % ----- add new symbol
        if isempty(rid)
            rid = length(grammar.symbols) + 1;
            
            
            grammar.symbols(rid).name                        = thename;
            grammar.symbols(rid).is_terminal                 = 1;
            grammar.symbols(rid).detector_id                 = nan;
            grammar.symbols(rid).learntparams.duration_mean = nan;
            grammar.symbols(rid).learntparams.duration_var  = nan;
        end
        
        right_ids(end+1) = rid;
        right_probs(end+1) = or_prob;
        
    end
    
    % rule
    grammar.rules(end+1).id = length(grammar.rules) + 1;
    
    grammar.rules(end).left = left_id;
    grammar.rules(end).right = right_ids;
    grammar.rules(end).or_rule = 0;
    if length(tokens) >= 4 && strcmp(tokens{4}, 'or')
        n = (length(tokens) - 1) / 2;
        grammar.rules(end).or_rule = 1;
        grammar.rules(end).or_prob = right_probs / sum(right_probs);
    end
    
    grammar.symbols(left_id).rule_id = grammar.rules(end).id;
end


fclose(fid);

%% more symbol info
for i=1:length(grammar.symbols)
    if ~grammar.symbols(i).is_terminal
        grammar.symbols(i).prule = grammar.rules(grammar.symbols(i).rule_id);
    end
    
    grammar.name2id.(grammar.symbols(i).name) = i;
end


%% print grammar
disp '------------ print grammar rules'
for i=1:length(grammar.rules)
    
    r = '';
    r = [r grammar.symbols(grammar.rules(i).left).name];
    r = [r ' >>> '];
    
    for j=grammar.rules(i).right
        r = [r grammar.symbols(j).name];
        
        if grammar.rules(i).or_rule
            r = [r ' | '];
        else
            r = [r '  '];
        end
    end
    
    disp(r);
end



end







































