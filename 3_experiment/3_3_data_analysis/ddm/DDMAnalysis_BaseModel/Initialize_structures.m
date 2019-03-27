function Chain_data  = Initialize_structures(Nchain,Nstep,n_subj)

Nparam=5;


%% Initialize lower parameters
for ns=1:n_subj
    
    % Dimension chains
    Chain_data(ns).param_chain=NaN(Nstep,Nparam,Nchain);
    
    % Dimension old and new priors
    Chain_data(ns).prior_old=zeros(1,Nchain);
    Chain_data(ns).LL=zeros(Nstep,Nchain);
    
    for nc=1:Nchain
        Chain_data(ns).param_old(1,nc) = .1 + .05*randn;        % taste weight
        Chain_data(ns).param_old(2,nc) = .1 + .05*randn;        % health weight
        Chain_data(ns).param_old(3,nc) = .05 + rand*.15;        % barrier
        Chain_Data(ns).param_old(4,nc) = 0 + .3*randn;          % starting-point bias
        Chain_data(ns).param_old(5,nc) = .3 + .4*rand;          % ndt

    end

    
    % Dimension chains
    Chain_data(ns).param_chain=NaN(Nstep,Nparam,Nchain);
    
    for np=1:Nparam
        % Populate first value of the chain with initial guess
        Chain_data(ns).param_chain(1,np,:)=Chain_data(ns).param_old(np,:);

    end

end



