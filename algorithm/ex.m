function ex()
    max_run = 50;
    test_func = [1:20];
%     test_ex = [1:size(test_case, 1)];
    for alg = 2%size(test_case, 1)
%         if ~ismember(i, test_ex)
%             continue;
%         end
        disp(alg);
        if ~exist(sprintf('./result/ALG%d', alg),'dir')
            mkdir(sprintf('./result/ALG%d', alg));
        end
        PR = zeros(20, 5);
        SR = zeros(20, 5);
        e3 = zeros(20, max_run);
        e4 = zeros(20, max_run);
        e5 = zeros(20, max_run);        
        
        for func = 4:5%, 10:13, 8, 9, 14, 15]
            if ~ismember(func, test_func)
                continue;
            end  
            delete(gcp('nocreate'));
            parpool('local',max_run);
            spmd(max_run)
                result = CBCC_CMA_ES_NBC_final(func, labindex, alg);
            end
%             for labindex = 1
%                 result(labindex, :) = CBCC_CMA_ES_NBC_final(func, labindex, alg);
%                 disp(result(labindex, :));
%             end

            result = cat(1, result{1:end});
            e3(func, :) = result(:, 3)';
            e4(func, :) = result(:, 4)';
            e5(func, :) = result(:, 5)';
            pr = mean(result) / get_no_goptima(func);
            sr = sum(result == get_no_goptima(func)) / max_run;
            result = [pr; sr; result];
            PR(func, :) = pr;
            SR(func, :) = sr;
            dlmwrite(sprintf('./result/ALG%d/F%d', alg, func), result); 
        end
        dlmwrite(sprintf('./result/ALG%d/BPR', alg), PR); 
        dlmwrite(sprintf('./result/ALG%d/BSR', alg), SR); 
        dlmwrite(sprintf('./result/ALG%d/e3', alg), e3); 
        dlmwrite(sprintf('./result/ALG%d/e4', alg), e4); 
        dlmwrite(sprintf('./result/ALG%d/e5', alg), e5); 
    end
end
