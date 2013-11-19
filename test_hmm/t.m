
%% generate HMM stuff
clc;

TRANS = [.9 .1   0   0; 
         0  .9   0.1 0;
         0   0   0.9 0.1;
         0   0   0   1];

EMIS = [1/6, 1/6, 1/6, 1/6, 1/6, 1/6;
        7/12, 1/12, 1/12, 1/12, 1/12, 1/12];
    
EMIS = rand(4, 6);
for i=1:size(EMIS,1)
    EMIS(i,:) = EMIS(i,:) / sum(EMIS(i,:));
end

[seq,states] = hmmgenerate(50,TRANS,EMIS);

likelystates = hmmviterbi(seq, TRANS, EMIS);

[p l] = hmmdecode(seq,TRANS,EMIS);

subplot(4,1,1);
imagesc(states);
subplot(4,1,2);
imagesc(seq);
subplot(4,1,3);
imagesc(likelystates);

%% grammar stuff

m.grammar        = load_grammar('grammar.txt');
downsamplingrate = 1;
T                = 1250;


m.grammar.symbols(2).learntparams.duration_mean = 0;
m.grammar.symbols(2).learntparams.duration_var  = 10e20;
m.grammar.symbols(3).learntparams.duration_mean = 0;
m.grammar.symbols(3).learntparams.duration_var  = 10e20;
m.grammar.symbols(4).learntparams.duration_mean = 0;
m.grammar.symbols(4).learntparams.duration_var  = 10e20;
m.grammar.symbols(5).learntparams.duration_mean = 0;
m.grammar.symbols(5).learntparams.duration_var  = 10e20;


m = gen_inference_net(m, T, downsamplingrate , 1, 1);

m.g(m.s).start_distribution(:) = 0;
m.g(m.s).start_distribution(1) = 1;
m.g(m.s).end_likelihood(:)  = 0;
m.g(m.s).end_likelihood(50) = 1;



%%


% compute detection score
for i=1:length(m.detection.result)
    
    m.detection.result{i}(:) = 0;
    
    for t1=1:50
        for t2=t1+1:50
            
            t3 = t2-1;
            
            v = 1;
            
            if i > 1
                v = v * TRANS(i-1,i);
            end
            
            v = v * TRANS(i,i) ^ (t3-t1);
            v = v * prod(EMIS(i,seq(t1:t3)));
                
            m.detection.result{i}(t1,t2) = v;
            
        end
    end
    
end

%% perform inference
m = m_inference_v3(m);
m = m_compute_frame_prob(m);
subplot(4,1,4);
m_plot_distributions(m, {'a', 'b', 'c', 'd'}, {'S'});


disp(l);
disp(m.g(1).i_forward.log_pZ);
xlim([1 50]);
ylim([0 1]);






















    