max_run = 25;
for dim = [5 10]
    delete(gcp('nocreate'));
    parpool('local',max_run);
    spmd(max_run)
        siglerun_IDBPI(dim, labindex+25);
    end
end

for func = 16 : 19
    delete(gcp('nocreate'));
    parpool('local',max_run);
    spmd(max_run)
        siglerun_FDBPI_NBC(func, labindex+25);
    end
%     siglerun_FDBPI_NBC(func, 19);
end
