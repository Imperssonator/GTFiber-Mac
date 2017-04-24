function opt_params = sensitive_optimization(ofun,x0,lb,ub,del)

max_iter = 10;
cur_iter = 0;
num_params = length(x0);

% Initialize parameter matrix
params = zeros(length(x0),3);
params(:,2) = x0;
params(:,1) = x0-del; params(:,3) = x0+del;
too_low = params(:,1)<lb;
too_high = params(:,3)>ub;
params(too_low)=lb(too_low);
params(too_low,1) = lb(too_low);
params(too_high,3) = ub(too_high);

while cur_iter<max_iter
    cur_iter=cur_iter+1;
    disp(cur_iter)
    if cur_iter>1
        for p = 1:num_params;
            [~,min_pt] = min(param_reg(p).reg.y);
            params_new(p,2)=params(p,min_pt);
        end
        params_new(:,1) = params_new(:,2)-del;
        params_new(:,3) = params_new(:,2)+del;
        too_low = params_new(:,1)<lb;
        too_high = params_new(:,3)>ub;
        params_new(too_low)=lb(too_low);
        params_new(too_low,1) = lb(too_low);
        params_new(too_high,3) = ub(too_high);
        params=params_new;
    end
    
    disp(params)
    param_mat = repmat(params(:,2),1,num_params*2+1);
    for i = 1:num_params; param_mat(i,i) = params(i,1); end
    for i = 1:num_params; param_mat(i,i+num_params) = params(i,3); end
    
    sens_res = struct();
    for i = 1:size(param_mat,2);
        [sens_res(i).out,sens_res(i).Fibers] = ofun(param_mat(:,i));
    end
    
    param_reg = struct();
    for i = 1:num_params;
        param_reg(i).reg = MultiPolyRegress(params(i,:)',[sens_res(i).out; sens_res(num_params*2+1).out; sens_res(i+num_params).out],1);
    end
    for i = 1:num_params;
        cv(i) = param_reg(i).reg.CVMAE;
    end
    save(['Iter_', num2str(cur_iter), '.mat'])
end

[~,best_set] = min([sens_res(:).out]);
opt_params=param_mat(:,best_set);

end
