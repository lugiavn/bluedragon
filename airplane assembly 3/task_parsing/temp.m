
actionnames = {'body1', 'nose_ab1', 'wing_a1', 'tail_a1', 'sticker'};

close all;

nx_figure(1);
hold on;
grid on;

nx_figure(2);
hold on;
grid on;

for actionname = actionnames
    
    actionname = actionname{1};
    lerrors    = nan(1, m.params.T);
    evars      = nan(1, m.params.T);
    
    real_timing = nan;
    for a=test.label.actions
        if strcmp(a.name, actionname)
            real_timing = a.start / data.downsample_ratio;
        end
    end
    
    for t=1:length(ms)

        d = ms{t}.grammar.symbols(m.grammar.name2id.(actionname)).start_distribution;
        d = d / sum(d);
        estimated_timing = sum([1:m.params.T] .* d);
%         [~, estimated_timing] = max(d);
        
        lerror = estimated_timing - real_timing;

        lerrors(t) = lerror;
        evars(t)   = var(d .* ([1:m.params.T] - mean(estimated_timing)).^2);
        evars(t)   = sum(d .* log(d));
        if evars(t) > 400
            gogo = 1;
        end
    end

    nx_figure(1);
    if rand > 0.5
        plot((1:m.params.T) * data.downsample_ratio / 30, lerrors * data.downsample_ratio / 30, 'color', nxtocolor(sum(actionname)));
    else
        plot((1:m.params.T) * data.downsample_ratio / 30, lerrors * data.downsample_ratio / 30, 'color', nxtocolor(sum(actionname)), 'LineWidth',2, 'LineStyle', '--')
    end;
    
    
    nx_figure(2);
    plot(evars, 'color', nxtocolor(sum(actionname)));
    
end;

nx_figure(1);
legend(actionnames);
ylabel('Localization error (s)')
xlabel('Time (s)')


for actionname = actionnames
    actionname = actionname{1};
    for a=test.label.actions
        if strcmp(a.name, actionname)
            plot(a.start / 30, 0,  'MarkerFaceColor', nxtocolor(sum(actionname)), 'Marker', 'v', 'MarkerSize', 10);
        end
    end
end


