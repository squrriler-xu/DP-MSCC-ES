function seeds = get_seeds(pop, fai)
    
    matdis = pdist2(pop, pop);
    
    NP = size(matdis, 1);
    nbc = zeros(NP, 3);
    nbc(1, :) = [1 -1 0]; % the best individual do not have the nearest better neighbour
    for i = 2:NP
        nbc(i, 1) = i;
        [nbc(i, 3), nbc(i, 2)] = min(matdis(i, 1:i-1));
    end
    
    meandis = fai * mean(nbc(2:NP, 3));
    seeds = [1; nbc(nbc(:, 3) > meandis, 1)];
end