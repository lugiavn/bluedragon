clc

[a b c] = svmpredict(y(19)', [[1:1]' K(randi([1 50]),:)], m.svm.model, '');

disp(a);

cT = nan(6);
i=0;
for a=1:6
    cT(a,a) = 0;
    for b=a+1:6
        cT(a,b) = c(i+1);
        cT(b,a) = -cT(a,b);
        i = i + 1;
    end;
end;

sum(cT,2)