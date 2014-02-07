
outputfile = 'grammar1358.txt';
statesnum  = [1 3 5 8];
classesnum = 6;

fileID = fopen(outputfile, 'wt');

fprintf(fileID, 'S > A0');
for i=1:classesnum-1
    fprintf(fileID, [' or A' num2str(i)]);
end;
fprintf(fileID, '\r\n');

for i=0:classesnum-1
    fprintf(fileID, ['A' num2str(i) ' > ']);

    for j=1:sum(statesnum)
        if j > 1
            fprintf(fileID, [' and ']);
        end
        
        fprintf(fileID, [' p' num2str(i) '_' num2str(j) ' ']);
        
        if sum(sum(integralImage([1 3 5]) == j)) > 0 & j < sum(statesnum)
            fprintf(fileID, ' and restart ');
        end
    end
    fprintf(fileID, '\r\n');
end

fprintf(fileID, 'restart -1 \r\n');
icount = 1;
for i=0:classesnum-1
    for j=1:sum(statesnum)
        fprintf(fileID, [' p' num2str(i) '_' num2str(j) ' ' num2str(icount)]);
        icount = icount + 1;
        fprintf(fileID, '\r\n');
    end
end

fclose(fileID);

















