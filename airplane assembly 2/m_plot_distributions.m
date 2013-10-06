
function [] = m_plot_distributions(m, start_symbols, end_symbols, scale_max)

    if ~exist('scale_max')
        scale_max = 1;
    end

    cla
    hold on;
    linestyle = 0;
    for action = start_symbols
        d = m.grammar.symbols(actionname2symbolid(action{1}, m.grammar)).start_distribution;
        
        if scale_max
            d = d / max(d) * sum(d);
        end
        
        if linestyle == 0
            plot(d, 'color', nxtocolor(sum(action{1})), 'LineWidth', 1)
        elseif linestyle == 1
            plot(d, 'color', nxtocolor(sum(action{1})), 'LineWidth',2, 'LineStyle', '--')
        elseif linestyle == 2
            plot(d, 'color', nxtocolor(sum(action{1})), 'LineWidth',3, 'LineStyle', ':')
        end
        
        linestyle = mod(linestyle+1,2);
    end
    for action = end_symbols
        d = m.grammar.symbols(actionname2symbolid(action{1}, m.grammar)).end_distribution;
        if scale_max
            d = d / max(d) * sum(d);
        end
        plot(d, '--', 'color', nxtocolor(sum(action{1})));
    end
    
    % modify to add bin
    disp('[toremove] modifly m_plot_distributions');
    for i=1:length(start_symbols)
        id = m.grammar.name2id.(start_symbols{i});
        if m.grammar.symbols(id).is_terminal
            start_symbols{i} = [start_symbols{i} ' start (Bin ' num2str(m.grammar.symbols(id).detector_id) ')'];
        end
    end
    
    legend([start_symbols, end_symbols], 'Interpreter', 'none');
    %plot(nt, 0, '*black');
    hold off;

end