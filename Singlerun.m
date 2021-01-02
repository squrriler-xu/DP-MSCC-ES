
dis = zeros(20, 5);
no_c = zeros(20, 5);
epsilon = zeros(20, 5);
for alg = 1 : 3
    for func = 1 : 20
        [dis(func, alg), no_c(func, alg)] = get_distance(func, alg);
    end
end

filename = sprintf('./result_2/dist.csv');
csvwrite(filename, dis);

filename = sprintf('./result_2/no_c.csv');
csvwrite(filename, no_c);