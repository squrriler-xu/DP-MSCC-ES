function record = CBCC_CMA_ES_NBC_final(func, runs, alg)
% -------------------- Initialization --------------------------------
global initial_flag;
initial_flag = 0; % should set the flag to 0 for each run, each function
s = RandStream('mt19937ar','Seed',runs);
RandStream.setGlobalStream(s);

% get the problem information
dim = get_dimension(func);
MaxFes = get_maxfes(func);
lb = get_lb(func);
ub = get_ub(func);

nopt = [2 5 1 4 2 18 36 81 216 12 6 8 6 6 8 6 8 6 8 8];

Fes = 0;

% initialize and evaluate the population
init_popsize = 0.5 * MaxFes;

min_popsize = 7 + floor(3*log(dim));

filename = sprintf('./IDBPI_pop/init_pop_dim%d_runs%d.mat', dim, runs);
load(filename);

init_pop = init_pop_IDBPI;
init_pop = lb + init_pop .* (ub - lb);

filename = sprintf('./FDBPI_pop/init_pop_func%d_runs%d.mat', func, runs);
load(filename);

init_pop = [init_pop; init_pop_FDBPI];

% init_pop = DBPI_1(lb, ub, init_popsize, dim);
% init_pop = init_pop(1:init_popsize, :);
% init_pop = lb + init_pop .* (ub - lb);
% init_val = fast_niching_func(init_pop, func);

% [new_pop] = FBPI_1(lb, ub, init_pop, init_val, init_popsize2, dim);
% new_val = fast_niching_func(new_pop, func);
% Fes = Fes + init_popsize2;
% init_pop = [init_pop; new_pop];
% init_val = [init_val; new_val];

% init_pop = init_pop(1:0.25*MaxFes, :);
% init_val = init_val(1:0.25*MaxFes, :);

init_val = fast_niching_func(init_pop, func);
Fes = Fes + init_popsize;

[init_val, sort_index] = sort(init_val, 'descend');
init_pop = init_pop(sort_index, :);
[species] = NBC_lp(init_pop, func, runs);
num_species = length(species);

groups = struct();
i = 1;
for j = 1 : num_species
    if species(j).len < min_popsize
        continue;
    end
    groups(i).idx = i;
    groups(i).OPTS.first = 1;
    groups(i).OPTS.pop = init_pop(species(j).idx(1 : min_popsize), :);
    groups(i).OPTS.val = init_val(species(j).idx(1 : min_popsize));
    groups(i).xmean = mean(groups(i).OPTS.pop)';
    x = groups(i).OPTS.pop - groups(i).xmean';
    groups(i).OPTS.sigma = sqrt((1/(min_popsize*dim))*sum(x(:).^2));
    groups(i).cc = std(groups(i).OPTS.val);
    groups(i).bestval = init_val(species(j).seed);
    groups(i).bestmem = init_pop(species(j).seed, :);
    groups(i).delta = 0;
    groups(i).iters = 0;
    i = i + 1;
end

num_groups = length(groups);

bestmem_set = [];       %  全局最优解集合
bestval_set = [];

subbestmem_set = [];    % 局部最优解集合
subbestval_set = [];

% filename = sprintf('./optima_position/F%d_optima.mat', func);
% load(filename);
% scatter(optima_result(:, 1), optima_result(:, 2), 25, 'd', 'filled', 'r');
% hold on;

clear init_pop init_val

itermax = ceil((0.25*MaxFes)/(num_groups*min_popsize));
for i = 1 : num_groups
    [new_groups, used_Fes] = CMA_ES(func, groups(i), lb, ub, itermax);
    
    groups(i) = new_groups;
    Fes = Fes + used_Fes;
end

val = [groups.bestval]; pop = cat(1, groups.bestmem);
[bestval, ibest] = max(val); bestmem = pop(ibest, :);
while Fes < MaxFes
    val = [groups.bestval]; pop = cat(1, groups.bestmem);
    [~, first_idx] = max(val);
    
    delta = [groups.delta];
    expected_gen = ceil((bestval - val)./(delta./itermax));
    expected_gen(first_idx) = Inf;
    if ~isempty(bestmem_set)
        gdis = pdist2(pop, bestmem_set);
        gdis = min(gdis, [], 2);
        temp_arr = [expected_gen', -gdis];
        [~, idx] = sortrows(temp_arr);
    else
        randnum = randperm(length(groups));
        temp_arr = [expected_gen', randnum'];
        [~, idx] = sortrows(temp_arr);
    end
    second_idx = idx(1);
    
    itermax = 20;
    
    % 演化最好的一个子群
    i = first_idx;
    [new_groups, used_Fes] = CMA_ES(func, groups(i), lb, ub, itermax);
    
    % 将参数拷贝到结构体中
    groups(i) = new_groups;
    Fes = Fes + used_Fes;
    
    if groups(i).bestval > bestval
        bestmem = groups(i).bestmem;
        bestval = groups(i).bestval;
    end
    
    % 演化潜力最大的子群
    i = second_idx;
    [new_groups, used_Fes] = CMA_ES(func, groups(i), lb, ub, itermax);
    
    % 将参数拷贝到结构体中
    groups(i) = new_groups;
    Fes = Fes + used_Fes;
    
    % 收集收敛的种群
    if groups(first_idx).cc < 1e-7
        if abs(groups(first_idx).bestval - bestval) < 1e-5
            bestmem_set = [bestmem_set; groups(first_idx).bestmem];
            bestval_set = [bestval_set; groups(first_idx).bestval];
        else
            subbestmem_set = [subbestmem_set; groups(first_idx).bestmem];
            subbestval_set = [subbestval_set; groups(first_idx).bestval];
        end
        record = zeros(1, 5);
        for i = 1:5
            record(i) = fast_count_goptima(bestmem_set, bestval_set, func, 10^(-i));
        end
        pp = Fes/MaxFes;
        fprintf('%2d.%2d| Fes: %.2f, num_find: %d, num_opt: %d\n', func, runs, pp, record(4), nopt(func));
        groups(first_idx) = [];
        if isempty(groups) || record(4) == nopt(func)
            break;
        end
        continue;
    end
    
    if ~isempty(bestmem_set)
        dis_arr = pdist2(groups(first_idx).bestmem, bestmem_set);
        if min(dis_arr) < 1e-3
            groups(first_idx) = [];
        end
    end
    if isempty(groups)
        break;
    end
    
%     bb = cat(1, groups.bestmem);
%     s = scatter(bb(:, 1), bb(:, 2), 35, 'd', 'filled', 'k');
%     delete(s);
%     if ~isempty(bestmem_set)
%         scatter(bestmem_set(:, 1), bestmem_set(:, 2), 35, 'd', 'filled', 'b');
%     end
end
% 
bestmem_set = [bestmem_set; subbestmem_set];
bestval_set = [bestval_set; subbestval_set];

record = zeros(1, 5);
for i = 1:5
    record(i) = fast_count_goptima(bestmem_set, bestval_set, func, 10^(-i));
end

end

function [groups, Fes] = CMA_ES(func, groups, lb, ub, itermax)

xmean   = groups.xmean;
bestmem = groups.bestmem;
bestval = groups.bestval;
OPTS    = groups.OPTS;

old_bestval = groups.bestval;


% 初始化系数
dim = length(xmean);
sigma = OPTS.sigma;

if OPTS.first == 1
    lambda = 7 + floor(3*log(dim));
    mu = floor(lambda/2);
    % Strategy parameter setting: Selection
    weights = log(mu+1/2)-log(1:mu)';       % muXone recombination weights
    mu = floor(mu);                         % number of parents/points for recombination
    weights = weights/sum(weights);         % normalize recombination weights array
    mueff=sum(weights)^2/sum(weights.^2);   % variance-effective size of mu
    
    % Strategy parameter setting: Adaptation
    cc = (4+mueff/dim) / (dim+4 + 2*mueff/dim);     % time constant for cumulation for C
    cs = (mueff+2)/(dim+mueff+5);                   % t-const for cumulation for sigma control
    c1 = 2 / ((dim+1.3)^2+mueff);                   % learning rate for rank-one update of C
    cmu = 2 * (mueff-2+1/mueff) / ((dim+2)^2+2*mueff/2);    % and for rank-mu update
    damps = 1 + 2*max(0, sqrt((mueff-1)/(dim+1))-1) + cs;   % damping for sigma
    
    % Initialize dynamic (internal) strategy parameters and constants
    pc = zeros(dim,1); ps = zeros(dim,1);           % evolution paths for C and sigma
    B = eye(dim);                                   % B defines the coordinate system
    D = eye(dim);                                   % diagonal matrix D defines the scaling
    C = B*D*(B*D)';                                 % covariance matrix
    chiN=dim^0.5*(1-1/(4*dim)+1/(21*dim^2));        % expectation of ||N(0,I)|| == norm(randn(N,1))
    countval = 0;
    iters = 0;
else
    lambda = OPTS.lambda;
    weights = OPTS.weights;
    mu = OPTS.mu;
    mueff = OPTS.mueff;
    cc = OPTS.cc;
    cs = OPTS.cs;
    c1 = OPTS.c1;
    cmu = OPTS.cmu;
    damps = OPTS.damps;
    pc = OPTS.pc;
    ps = OPTS.ps;
    B = OPTS.B;
    D = OPTS.D;
    C = OPTS.C;
    chiN = OPTS.chiN;
    countval = OPTS.countval;
    iters = groups.iters;
end
% -------------------- Generation Loop --------------------------------
stopiters = iters + itermax; 
Fes = 0;
while iters < stopiters
    % Generate and evaluate lambda offspring
    
    if OPTS.first == 1
        arx = OPTS.pop';
        arfitness = OPTS.val';
        for k = 1 : lambda
            arz(:, k) = pinv(D) * pinv(B) * ((arx(:, k) - xmean)/sigma);
        end
    else
        arz = randn(dim, lambda);                          % standard normally distributed vector
        for k = 1: lambda
            arx(:,k) = xmean + sigma * (B*D * arz(:,k));
            
            temp_ub = arx(:, k) > ub(1);
            temp_lb = arx(:, k) < lb(1);
            if any(temp_ub) || any(temp_lb)
                arx(temp_ub, k) = ub(1);
                arx(temp_lb, k) = lb(1)';
                arz(:, k) = pinv(D) * pinv(B) * ((arx(:, k) - xmean)/sigma);
            end
            countval = countval + 1;
        end
        arfitness = fast_niching_func(arx', func);
        Fes = Fes + lambda;
        iters = iters + 1;
    end
    
    % Sort by fitness and compute weighted mean into xmean
    [arfitness, arindex] = sort(arfitness,'descend');         % maxmization
    xmean = arx(:,arindex(1:mu))*weights;
    zmean = arz(:,arindex(1:mu))*weights;
    
    % Cumulation: Update evolution paths
    ps = (1-cs)*ps + (sqrt(cs*(2-cs)*mueff)) * (B * zmean);
    hsig = norm(ps)/sqrt(1-(1-cs)^(2*countval/lambda))/chiN < 1.4+2/(dim+1);
    pc = (1-cc)*pc + hsig * sqrt(cc*(2-cc)*mueff) * (B*D*zmean);
    
    % Adapt covariance matrix C
    C = (1-c1-cmu) * C ...
        + c1 * (pc*pc' ... % plus rank one update
        + (1-hsig) * cc*(2-cc) * C) ... % minor correction
        + cmu ... % plus rank mu update
        * (B*D*arz(:,arindex(1:mu))) ...
        * diag(weights) * (B*D*arz(:,arindex(1:mu)))';
    
    % Adapt step-size sigma
    sigma = sigma * exp((cs/damps)*(norm(ps)/chiN - 1));
    
    % Update B and D from C
    C = triu(C) + triu(C,1)';       % enforce symmetry
    [B,D] = eig(C);                 % eigen decomposition, B==normalized eigenvectors
    D = diag(sqrt(diag(abs(D))));   % D contains standard deviations now
    % Break, if fitness satisfies stop condition
    
    if OPTS.first == 1
        OPTS.first = 0;
    end
    
    if arfitness(1) > bestval
        bestmem = arx(:,arindex(1))';
        bestval = arfitness(1);
    end
    
    if std(arfitness) < 1e-7
        break;
    end
end

OPTS.pc = pc;
OPTS.ps = ps;
OPTS.B = B;
OPTS.D = D;
OPTS.C = C;
OPTS.sigma = sigma;
OPTS.lambda = lambda;
OPTS.weights = weights;
OPTS.mu = mu;
OPTS.mueff = mueff;
OPTS.cc = cc;
OPTS.cs = cs;
OPTS.c1 = c1;
OPTS.cmu = cmu;
OPTS.damps = damps;
OPTS.chiN = chiN;
OPTS.countval = countval;

groups.xmean    = xmean;
groups.bestmem  = bestmem;
groups.bestval  = bestval;
groups.OPTS     = OPTS;
groups.delta    = bestval - old_bestval;
groups.cc       = std(arfitness);
groups.iters    = iters;

end



