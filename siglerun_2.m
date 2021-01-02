function siglerun_2(func, runs)

global initial_flag;
initial_flag = 0; % should set the flag to 0 for each run, each function

dim = get_dimension(func);
MaxFes = get_maxfes(func);
lb = get_lb(func);
ub = get_ub(func);

init_popsize = 0.5 * MaxFes;

filename = sprintf('./init_pop/init_pop_dim%d_runs%d.mat', dim, runs);
load(filename);
init_pop = init_pop(1:init_popsize, :);
init_pop = lb + init_pop .* (ub - lb);
init_val = fast_niching_func(init_pop, func);

[init_val, sort_index] = sort(init_val, 'descend');
init_pop = init_pop(sort_index, :);
nbc = NBC_large_population(init_pop, func, runs);

filename = sprintf('./nbc/nbc_F%d_runs%d.mat', func, runs);
save(filename, 'nbc');

end