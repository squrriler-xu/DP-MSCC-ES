init_popsize = 2e5;
dim = 20;

for runs = 1 : 50
    s = RandStream('mt19937ar','Seed',runs);
    RandStream.setGlobalStream(s);
    init_pop = DBPI_1(0, 1, init_popsize, dim);
    filename = sprintf('./init_pop/init_pop_runs_%d.mat', runs);
    save(filename, 'init_pop');
end