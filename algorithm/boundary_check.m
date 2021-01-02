function x=boundary_check(x,lower_bound,upper_bound)
% ±ß½ç·´µ¯
% x=(x<lower_bound).*(2*lower_bound-x)+(x>=lower_bound).*x;
% x=(x>upper_bound).*(2*upper_bound-x)+(x<=upper_bound).*x;
NP = size(x, 1);
lower_bound = repmat(lower_bound, NP, 1);
upper_bound = repmat(upper_bound, NP, 1);

length_bound = upper_bound - lower_bound;
x=(x<lower_bound).*(lower_bound+rem((lower_bound-x), length_bound))+(x>=lower_bound).*x;
x=(x>upper_bound).*(upper_bound-rem((x-upper_bound), length_bound))+(x<=upper_bound).*x;

end

