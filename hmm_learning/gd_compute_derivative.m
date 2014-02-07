
% derivative
for i987576=1:length(m.vdetectors)
    m.vdetectors(i987576).derivative = 0;
    m.vdetectors(i987576).derivative2 = 0;
end

for l=1:length(newm.g)
    if newm.g(l).is_terminal
        j     = newm.g(l).detector_id;
        
        if j < 0
            continue;
        end
        
        
        %
        joint = newm.g(l).i_forward.joint1 .* newm.g(l).i_backward.joint2;
        joint = joint / sum(sum(joint));
        svmscores = log(newm.detection.result{j}) / m.vdetectors(j).lamda;
        svmscores(isinf(svmscores)) = -99999;
        if str2num(newm.grammar.symbols(newm.g(l).id).name(2)) == data.examples(i_352).class
            E_F1 = sum(sum(joint .* svmscores));
        else
            E_F1 = 0;
        end
        E_F2 = sum(sum(joint .* svmscores)) * newm.g(l).i_final.prob_notnull;

%         assert(E_F1 > -10);
%         assert(E_F2 > -10);
        
        m.vdetectors(j).derivative = m.vdetectors(j).derivative + (E_F1 - E_F2);
        
        % lamda2
        if str2num(newm.grammar.symbols(newm.g(l).id).name(2)) == data.examples(i_352).class
            E_F1 = 0.1;
        else
            E_F1 = 0;
        end
        E_F2 = 0.1 * newm.g(l).i_final.prob_notnull;
        m.vdetectors(j).derivative2 = m.vdetectors(j).derivative2 + (E_F1 - E_F2);
    end
end

% imagesc(reshape([m.vdetectors().derivative], [6 8]));
