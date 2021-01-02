function [new_pop] = FDBPI(lb, ub, pop, val, init_popsize, dim, func, runs)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

Cd = (pi^(dim/2))/(gamma(dim/2 + 1));
R = (((1/(init_popsize))*prod(ub - lb))/Cd)^(1/dim);

h = R;
k = 10;

if min(val) < 0
    val = val - min(val);
end
rho = [];
ppl = [];
for i = 1 : k*100
    temp_ppl = lb + (ub - lb) .* rand(init_popsize/100, dim);      % 计划探测位置
    ppl = [ppl; temp_ppl];
    dist = pdist2(temp_ppl, pop);
    temp = (1/sum(val)) * sum(val' .* exp(-dist.^2 ./ (2 * h^2)), 2);
    rho = [rho; temp];  
    
    pro = i/1000;
    fprintf('%2d.%2d| progress: %.2f  \n', func, runs, pro);
end
[~, isort] = sort(rho, 'descend');

new_pop = ppl(isort(1 : init_popsize), :);

end

