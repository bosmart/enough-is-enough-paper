function bstrap3_multi2(fn)
    N = 100;
    A = readtable(fn);
    names = A.Properties.VariableNames;
    V = [];
    C = [];
    for i = 1:size(A,2)
        data = A{:,i};
        ix_nan = find(isnan(data));
        if ~isempty(ix_nan)
            data = data(1:ix_nan(1)-1);
        end
        v = {};
        c = {};
        for n = 1:N
            [v{n},c{n},~] = bstrap3(data);
            if n>1
                v{1} = v{1}+v{n};
                c{1} = c{1}+c{n};
            end
        end
        V(:,end+1) = v{1}/N;
        C(:,end+1) = c{1}/N; 
    end
    TC = cell2table(num2cell(C),'VariableNames',names);
    TV = cell2table(num2cell(V),'VariableNames',names);
    writetable(TC,'CI.csv');
    writetable(TV,'Val.csv');
end