
function [] = m_plot_distributions(m, start_symbols, end_symbols, scale_max, actions)

    if ~exist('scale_max')
        scale_max = 1;
    end

    timepoints = (1:m.params.T) * m.params.downsample_ratio;
    timepoints = 1:m.params.T;
    
    cla
    hold on;
    linestyle = 1;
    for action = start_symbols
        id = actionname2symbolid(action{1}, m.grammar);
        d = m.grammar.symbols(id).start_distribution;
        
        if scale_max
            d = d / max(d) * sum(d);
        end
        
        linestyle = mod(sum(action{1}), 4);
        
        if linestyle == 1 | linestyle == 2
            plot(timepoints, d, 'color', nxtocolor(id), 'LineWidth', 1)
        elseif linestyle == 0
            plot(timepoints, d, 'color', nxtocolor(id), 'LineWidth',2, 'LineStyle', '--')
        else
            plot(timepoints, d, 'color', nxtocolor(id), 'LineWidth',2, 'LineStyle', '-.')
        end
        
        linestyle = mod(linestyle+1,2);
    end
    for action = end_symbols
        id = actionname2symbolid(action{1}, m.grammar);
        d = m.grammar.symbols(id).end_distribution;
        if scale_max
            d = d / max(d) * sum(d);
        end
        plot(timepoints, d, '--', 'color', nxtocolor(sum(action{1})));
    end
    
    
    % for cvpr exp
    if exist('actions')
        hold on;
        for a=actions
        if ismember(a.name, start_symbols)
            id = m.grammar.name2id.(a.name);
            plot(a.start / 9, 0.1, 'color', nxtocolor(sum(a.name)), 'MarkerFaceColor', nxtocolor(id), 'Marker', 'v', 'MarkerSize', 10);
        end
        end
        hold off;
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