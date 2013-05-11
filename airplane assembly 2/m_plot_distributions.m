
function [] = m_plot_distributions(m, start_symbols, end_symbols)

    cla
    hold on;
    for action = start_symbols
        d = m.grammar.symbols(actionname2symbolid(action{1}, m.grammar)).start_distribution;
        if isfield (m, 'rs')
            d = m.grammar.symbols(actionname2symbolid(action{1}, m.grammar)).start_distribution_full;
        end
        plot(d, 'color', nxtocolor(sum(action{1})));
    end
    for action = end_symbols
        d = m.grammar.symbols(actionname2symbolid(action{1}, m.grammar)).end_distribution;
        if isfield (m, 'rs')
            d = m.grammar.symbols(actionname2symbolid(action{1}, m.grammar)).end_distribution_full;
        end
        plot(d, '--', 'color', nxtocolor(sum(action{1})));
    end
    legend([start_symbols, end_symbols]);
    %plot(nt, 0, '*black');
    hold off;

end