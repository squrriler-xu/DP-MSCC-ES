function [new_pop] = initialization_1(pop, lb, ub, dim, rep_point, rep_num, init_popsize, liquidity, inflow_count, epsilon_lb, epsilon_ub, t, cell_len)

popsize = size(pop, 1);
new_pop = [];

Cd = (pi^(dim/2))/(gamma(dim/2 + 1));
R = (((1/(popsize+init_popsize))*prod([ub - lb]))/Cd)^(1/dim);

h = R;
k = 30;

if popsize == 0
    new_pop(1, :) = lb + (ub - lb) .* rand(1, dim);
else
    probe_pos = lb + (ub - lb) .* rand(k ,dim);
    dist = pdist2(probe_pos, rep_point);
    rho = (1/popsize) * sum(exp(-dist.^2 ./ (2 * h^2)) .* rep_num, 2);
    [~, selected_idx] = min(rho);
    new_pop(1, :) = probe_pos(selected_idx, :);
end
init_popsize = init_popsize - 1;


is_empty = rep_num == 0;
rep_point(is_empty, :) = [];
rep_num(is_empty) = [];

i = 1;
while i <= init_popsize
    probe_pos = lb + (ub - lb) .* rand(k ,dim);
    
    shift_probe_pos = probe_pos - lb;
    cell_coo_pos = fix(shift_probe_pos./cell_len);
    cell_coo_pos(cell_coo_pos == t) =  t-1;
    cell_idx_pos = sum(cell_coo_pos .* power(t, (0 : (dim-1))), 2) + 1;
    
    probe_pos((liquidity(cell_idx_pos) > epsilon_ub | liquidity(cell_idx_pos) < epsilon_lb) & inflow_count(cell_idx_pos) >= 5, :) = [];
    
    if isempty(probe_pos)
        init_popsize = init_popsize - 1;
        continue;
    end
    
    if popsize ~= 0
        dist_1 = pdist2(probe_pos, rep_point);
        temp_rho_1 = exp(-dist_1.^2 ./ (2 * h^2)) .* rep_num;
    else
        temp_rho_1 = 0;
    end
    
    dist_2 = pdist2(probe_pos, new_pop);
    temp_rho_2 = exp(-dist_2.^2 ./ (2 * h^2));
    rho = (1/(popsize+i)) * (sum(temp_rho_1, 2) + sum(temp_rho_2, 2));

    [~, selected_idx] = min(rho);
    new_pop(i + 1, :) = probe_pos(selected_idx, :);
    
    i = i + 1;
end

end



