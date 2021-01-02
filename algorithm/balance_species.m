function nums = balance_species(nums, lambda)
% nums: species' size
% fai: the weight

    % find the species whose size are over and under the thresholds
    mean_num = mean(nums);
    lambda_num = round(lambda * mean(nums));
    large_size = find(nums > lambda_num);
    small_size = find(nums < mean_num);
    
    % the size which are over the threshold should be decreased 
    rest = sum(nums(large_size) - lambda_num);
    if rest == 0 % there is no specie whose size is more than the threshold
        return;
    end
    nums(large_size) = lambda_num;
    
    % the size which are under the threshold should be increased uniformly
    nums(small_size) = nums(small_size) + floor(rest / length(small_size));
    nums(small_size(1:rem(rest, length(small_size)))) = nums(small_size(1:rem(rest, length(small_size)))) + 1;
end