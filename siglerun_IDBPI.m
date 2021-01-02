function siglerun_IDBPI(dim, runs)

if dim == 1
    init_popsize = 5e4;
elseif dim == 2
    init_popsize = 2e5;
else
    init_popsize = 4e5;
end

s = RandStream('mt19937ar','Seed',runs);
RandStream.setGlobalStream(s);

init_pop_IDBPI = IDBPI(0, 1, init_popsize * 0.4, dim, runs);
filename = sprintf('./IDBPI_pop/init_pop_dim%d_runs%d.mat', dim, runs);
save(filename, 'init_pop_IDBPI');

end