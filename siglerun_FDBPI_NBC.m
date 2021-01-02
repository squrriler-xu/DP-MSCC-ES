function siglerun_FDBPI_NBC(func, runs)

global initial_flag;
initial_flag = 0;

s = RandStream('mt19937ar','Seed',runs);
RandStream.setGlobalStream(s);

dim = get_dimension(func);
MaxFes = get_maxfes(func);
lb = get_lb(func);
ub = get_ub(func);

init_popsize_FDBPI = 0.1 * MaxFes;

filename = sprintf('./IDBPI_pop/init_pop_dim%d_runs%d.mat', dim, runs);
load(filename);
init_pop_IDBPI = lb + init_pop_IDBPI .* (ub - lb);
init_val_IDBPI = fast_niching_func(init_pop_IDBPI, func);

init_pop_FDBPI = FDBPI(lb, ub, init_pop_IDBPI, init_val_IDBPI, init_popsize_FDBPI, dim, func, runs);

filename = sprintf('./FDBPI_pop/init_pop_func%d_runs%d.mat', func, runs);
save(filename, 'init_pop_FDBPI');

init_val_FDBPI = fast_niching_func(init_pop_FDBPI, func);

init_pop = [init_pop_IDBPI; init_pop_FDBPI];
init_val = [init_val_IDBPI; init_val_FDBPI];

[init_val, sort_index] = sort(init_val, 'descend');
init_pop = init_pop(sort_index, :);
nbc = NBC_large_population(init_pop, func, runs);

filename = sprintf('./nbc/nbc_F%d_runs%d.mat', func, runs);
save(filename, 'nbc');

end