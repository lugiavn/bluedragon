

m.grammar        = load_grammar('grammar.txt');
downsamplingrate = 1;
T                = 150;


m.grammar.symbols(2).learntparams.duration_mean = 50;
m.grammar.symbols(2).learntparams.duration_var  = 100;
m.grammar.symbols(3).learntparams.duration_mean = 50;
m.grammar.symbols(3).learntparams.duration_var  = 100;
m.grammar.symbols(4).learntparams.duration_mean = 50;
m.grammar.symbols(4).learntparams.duration_var  = 100;
m.grammar.symbols(5).learntparams.duration_mean = 50;
m.grammar.symbols(5).learntparams.duration_var  = 100;

m = gen_inference_net(m, T, downsamplingrate , 1, 1);


m.g(m.s).start_distribution(:) = 0;
m.g(m.s).start_distribution(1) = 1;
m.g(m.s).end_likelihood(:)  = 0;
m.g(m.s).end_likelihood(50) = 1;




figure(1);
m = m_inference_v3(m);
m = m_compute_frame_prob(m);
m_plot_distributions(m, {'a', 'b', 'c', 'd'}, {'S'});


figure(2);
for i=1:length(m.g)
    
    subplot(3, length(m.g), i);
    plot(m.g(i).i_forward.start_distribution);
    subplot(3, length(m.g), i + 5);
    plot(m.g(i).i_backward.start_likelihood);
    subplot(3, length(m.g), i + 10);
    plot(m.g(i).i_final.start_distribution);
    
    
end





