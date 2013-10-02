function m = create_m( weizmann )
%CREATE_M Summary of this function goes here
%   Detailed explanation goes here

% setup grammar
model = struct;
model.grammar = struct;
model.grammar.starting = 1;

model.grammar.symbols(1).name           = 'S';
model.grammar.symbols(1).is_terminal    = 0;
model.grammar.symbols(1).rule_id        = 1;

model.grammar.rules(1).id      = 1;
model.grammar.rules(1).left    = 1;
model.grammar.rules(1).right   = [2 2 2 2 2, 2 2 2 2 2, 2 2 2 2 2, 2 2 2 2 2, 2 2 2 2 2, 2 2 2 2 2];
model.grammar.rules(1).or_rule = 0;
model.grammar.rules(1).or_prob = [];

model.grammar.symbols(2).name           = 'A';
model.grammar.symbols(2).is_terminal    = 0;
model.grammar.symbols(2).rule_id        = 2;

model.grammar.rules(2).id      = 2;
model.grammar.rules(2).left    = 2;
model.grammar.rules(2).right   = [];
model.grammar.rules(2).or_rule = 1;
model.grammar.rules(2).or_prob = ones(10,1) / 10;
model.grammar.rules(2).or_prob = ones(11,1) / 11;

for i=unique(weizmann.test.sequence_framelabels)
    
    model.grammar.symbols(end+1).name      = 'N/A';
    model.grammar.symbols(end).name        = num2str(i);
    model.grammar.symbols(end).is_terminal = 1;
    model.grammar.symbols(end).detector_id = i;
    
    model.grammar.symbols(end).learntparams.duration_mean = mean(weizmann.durations{i});
    model.grammar.symbols(end).learntparams.duration_var  = var(weizmann.durations{i}) ;
    
    model.grammar.rules(2).right(end+1) = length(model.grammar.symbols);
end

% empty 
    model.grammar.symbols(end+1).name      = 'N/A';
    model.grammar.symbols(end).name        = 'empty';
    model.grammar.symbols(end).is_terminal = 1;
    model.grammar.symbols(end).detector_id = 99;
    
    model.grammar.symbols(end).learntparams.duration_mean = 0;
    model.grammar.symbols(end).learntparams.duration_var  = 0;
    
    model.grammar.rules(2).right(end+1) = length(model.grammar.symbols);
    
    
% gen inference structure
T  = weizmann.test.T;
Tx = T + 300;
m  = gen_inference_net(model, Tx, 1, 1, Tx);

m.g(m.s).end_likelihood(:) = 0;
m.g(m.s).end_likelihood(T) = 1;



end

