for i987576=1:length(m.vdetectors)
    m.vdetectors(i987576).mean_score = log(m.vdetectors(i987576).mean_score) / m.vdetectors(i987576).lamda;
    m.vdetectors(i987576).lamda = m.vdetectors(i987576).lamda + gd_learning_rate * m.vdetectors(i987576).derivative;
    m.vdetectors(i987576).lamda = max(1, m.vdetectors(i987576).lamda);
    m.vdetectors(i987576).derivative = 0;
    m.vdetectors(i987576).mean_score = exp(m.vdetectors(i987576).mean_score * m.vdetectors(i987576).lamda);
    
    
    % lamda2;
    m.vdetectors(i987576).lamda2 = m.vdetectors(i987576).lamda2 + gd_learning_rate * m.vdetectors(i987576).derivative2;
    m.vdetectors(i987576).derivative2 = 0;
end