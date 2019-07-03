function param_old = Chain_reset_fun(param_old)
% Reset any chain more than one standard deviation from the mean of the
% chains back to the mean of the chains.
% C.H. note: unclear why this is only done for non-decision time, early
% drift, and starting point bias...


[num_param, num_chain]=size(param_old);

t_nd_std=std(param_old(5,:));
t_nd_mean=mean(param_old(5,:));

muv1_std=std(param_old(1,:));
muv1_mean=mean(param_old(1,:));

muv2_std=std(param_old(2,:));
muv2_mean=mean(param_old(2,:));

% muv2_std=std(param_old(2,:));
% muv2_mean=mean(param_old(2,:));

% A_std=std(param_old(2,:));
% A_mean=mean(param_old(2,:));


for nn=1:num_chain
    if abs(param_old(5,nn) - t_nd_mean) > t_nd_std || ...
            abs(param_old(1,nn)-muv1_mean) > muv1_std || ...
            abs(param_old(2,nn)-muv2_mean) > muv2_std;        
        temp_param_mat=param_old;
        temp_param_mat(:,nn)=[];
        %             log_lik_old(1,nn)=log_lik_new(nn);
        for ij=1:num_param
            temp_vec=temp_param_mat(ij,:);
            replacement=mean(temp_vec);
            param_old(ij,nn)=replacement;
            
            clear temp_vec;
        end
        
    end
end