function ex()
%     test_case = {
%                 @FBK_DE, -1, 1.0, 2.0, 2.0, 0, 0, 0;                         % 01.FBK_DE                
%                 @FBK_DE, -1, 1.0, 2.0, 2.0, 0, 1, 0;                         % 02.FBK_DE-r
%                 @FBK_DE, -1, 1.0, 2.0, 2.0, 0, 2, 0;                         % 03.FBK_DE-k
%                 @FBK_DE, -1, 1.0, 2.0, 2.0, 0, 3, 0;                         % 04.FBK_DE-b
%                 @FBK_DE, -1, 1.0, 2.0, 2.0, 0, 4, 0;                         % 05.FBK_DE-rb
%                 @FBK_DE, -1, 1.0, 2.0, 2.0, 0, 5, 0;                         % 06.FBK_DE-n
%                 @FBK_DE, 10, 1.0, 2.0, 2.0, 0, 0, 0;                         % 07.FBK_DE-m10
%                 @FBK_DE, 15, 1.0, 2.0, 2.0, 0, 0, 0;                         % 08.FBK_DE-m15
%                 @FBK_DE, 30, 1.0, 2.0, 2.0, 0, 0, 0;                         % 09.FBK_DE-m30
%                 @FBK_DE, 60, 1.0, 2.0, 2.0, 0, 0, 0;                         % 10.FBK_DE-m60
%                 @FBK_DE, -1, 1.0, 2.0, 2.0, 0, 0, 1;                         % 11.FBK_DE-1/3
%                 @FBK_DE, -1, 1.0, 2.0, 2.0, 0, 0, 2;                         % 12.FBK_DE-1
%                 @FBK_DE, -1, 1.0, 2.0, 2.0, 0, 0, 3;                         % 13.FBK_DE-2
%                 @FBK_DE, -1, 1.0, nan, 2.0, 0, 0, 0;                         % 14.FBK_DE-nobalance
%                 @FBK_DE, -1, nan, nan, 2.0, 0, 0, 0;                         % 15.DE_NBC
%                 @FBK_DE, -1, 1.0, 1.0, 2.0, 0, 0, 0;                         % 16.FBK_DE-lambda1.0
%                 @FBK_DE, -1, 1.0, 3.0, 2.0, 0, 0, 0;                         % 17.FBK_DE-lambda3.0
%                 @FBK_DE, -1, 1.0, 4.0, 2.0, 0, 0, 0;                         % 18.FBK_DE-lambda4.0
%                 @FBK_DE, -1, 1.0, 2.0, 1.0, 0, 0, 0;                         % 19.FBK_DE-kp1.0 
%                 @FBK_DE, -1, 1.0, 2.0, 1.5, 0, 0, 0;                         % 20.FBK_DE-kp1.5 
%                 @FBK_DE, -1, 1.0, 2.0, 2.5, 0, 0, 0;                         % 21.FBK_DE-kp2.5
%         };
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
    
    % t-test
% 	for i = 15:15 %1:size(test_case, 1)
%         disp(i);
%         ttest_result = zeros(20, 3);
%         for acc = 3:5
%            x = dlmread(sprintf('./result/ALG%d/e%d', i, acc));
%            y = dlmread(sprintf('./result/ALG1/e%d', acc));
%            for pro = 1:20
%                ttest_result(pro, acc-2) = ttest2(x(pro, :), y(pro, :));
%            end
%         end
%         dlmwrite(sprintf('./result/ALG%d/et', i), ttest_result);
% 	end
end