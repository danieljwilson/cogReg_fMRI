function  DE_MCMC_fun(MCMC_params,Subject_data,Model_Details)

% This drives the whole MCMC. The most important data structure here is
% Chain_data. This structure is indexed as followed.
% Chain_data(subject #) holds the chain information for the specified
%       subject number, if there is more than one subject.
% Chain_data(_).param_chain is a pre-allocated 3D matrix that holds values
%       for all accepted parameters for each chain and iteration.
% Chain_data(_).LL is a pre-allocated 2D matrix that holds the computed LL
%       values for each chain and iteration for future use.

%% Extract model details
LL_handle=Model_Details.LL_handle;
Prior_handle=Model_Details.Prior_handle;
Chain_reset_handle=Model_Details.Chain_reset_handle;
Init_handle=Model_Details.Init_handle;

%% Extract parameter blocking information for the MCMC.
block_lower=Model_Details.block_lower;
gamma_low=Model_Details.gamma_low;

num_low_block=length(block_lower);

%% Extract MCMC parameters
Nstep=MCMC_params.Nstep;
Nchain=MCMC_params.Nchain;
noise_size=MCMC_params.noise_size;
burnin=MCMC_params.burnin;

resampling_boolean=MCMC_params.resampling;

N_subj=length(Subject_data);

%% Initialize data structures and stagnation counter
Chain_data  = Init_handle(Nchain,Nstep,N_subj); % This extracts an initial guess from the prior as well

Nparam = size(Chain_data(1).param_old,1); % Extract the number of parameters from the initialized data

%% Initialize LL and prior for the first chain instance.

% Loop over subjects and compute LL and prior for each subject
% % parfor ns=1:N_subj
for ns=1:N_subj
    for nc=1:Nchain
        params = constructParamsStruct(Chain_data(ns).param_old(:,nc)); % C.H. - function converts a vector of parameters into the structure accepted by LL_handle (computeLL_NormApprox.m)
        LL = LL_handle(params, Subject_data(ns));
        Chain_data(ns).LL(1,nc)=LL;
        
        Chain_data(ns).prior_old(1,nc) = Prior_handle(Chain_data(ns).param_old(:,nc));
    end
end

%% Initialize the acceptance counter, the reset counter, and get started
acceptance=zeros(1,N_subj);
% tic
t1=cputime;
for ii=2:Nstep
    
    
    % Just an output to track progress and periodically save chain data for
    % longer runs.
    if mod(ii,100)==0 || ii==Nstep-1
        %         TimeKeep=toc
        ['Iteration # = ' num2str(ii) ', CPUtime_elapsed=' num2str(cputime-t1)] %#ok<NOPRT>
        %         tic
        
        save(MCMC_params.savename,'MCMC_params','Subject_data','Model_Details','Chain_data','acceptance')
    end
    
    
    %% Update lower level parameters. Note that parallelization here is over
    %  subjects.
    for ns=1:N_subj
        %     for ns=1:N_subj
        
        % Extract the recorded data for this specific subject
        Subject_data_individual=Subject_data(ns);
        
        % Extract the old state data for this subject.
        param_old=Chain_data(ns).param_old;
        log_lik_old=Chain_data(ns).LL(ii-1,:);
        prior_old=Chain_data(ns).prior_old;
        
        % Loop over the number of blocks. If there are multiple blocks.
        acceptance_temp=0;
        for nb=1:num_low_block
            block_ind=block_lower{nb};
            
            % Storing and reading this structure allows the chains to be
            % updated in parallel. It allows the looping over
            % chains to be independent of order since the update of one
            % chain doesn't influence the updating of subsequent chains.
            % That is, once one chain is updated, the remaining chains
            % still look at its original state for updating purposes. This
            % is REQUIRED to parallelize over chains.
            param_old_hold=param_old; % Needed for parallelization over chains.
            prior_old_hold=prior_old; % Needed for parallelization over chains.
            
            parfor nc=1:Nchain % for running in parallel on cluster
%             for nc=1:Nchain % for running on local machine
   
                % Initialize the proposal from the previous iteration
                proposal=param_old(:,nc);
                
                rand_int=randperm(Nchain);
                rand_int(rand_int==nc)=[];
                ind1=rand_int(1);
                ind2=rand_int(2);
                
                %Generate proposal for this block and fill in.
                direction=param_old_hold(block_ind,ind1)-param_old_hold(block_ind,ind2); %#ok<PFBNS>
                gamma=gamma_low(nb); %#ok<PFBNS>
                epsilon=noise_size*(rand(size(direction))-0.5);
                proposal(block_ind)=param_old_hold(block_ind,nc)+gamma*direction+epsilon;
                
                %Compute prior
                prior_new = Prior_handle(proposal); %#ok<PFBNS>
                
                % Compute likelihood, SPECIFIC to model
                if prior_new~=0
                    % C.H. - function converts a vector of parameters into the structure accepted by LL_handle (computeLL_NormApprox.m)
                    params = constructParamsStruct(proposal); 
                    % C.H. - function computeLL_NormApprox.m computes likelihood of data
                    LL = LL_handle(params, Subject_data(ns));                    
                    log_lik_new=LL;
                else
                    log_lik_new=-inf;
                end
                
                log_acceptance=log_lik_new-log_lik_old(1,nc) + log(prior_new) - log(prior_old_hold(1,nc));
                prob=log(rand(size(log_acceptance)));
                
                % Update any chain that is accepted
                if prob<log_acceptance
                    acceptance_temp=acceptance_temp+1;
                    
                    param_old(:,nc)=proposal;
                    prior_old(:,nc)=prior_new;
                    log_lik_old(1,nc)=log_lik_new;
                    
                end
            end
        end
        
        acceptance(1,ns)=acceptance(1,ns)+acceptance_temp;
        
        % Store a few things.
        Chain_data(ns).param_old=param_old;
        Chain_data(ns).param_chain(ii,:,:)=param_old;
        Chain_data(ns).prior_old=prior_old;
        Chain_data(ns).LL(ii,:)=log_lik_old;
        
    end
    
    %% Periodically recompute each LL to unstick chains - ONLY NEEDED FOR PDA
    % C.H. note: not sure exactly what this is doing here. I think it may
    % have to do with idea that the kernel density approach doesn't yield
    % an exact probability so you might want to recompute every once in a
    % while to make sure that you haven't compute the likelihood
    % incorrectly
    if resampling_boolean==1
        if mod(ii,3)==0

            %             parfor ns=1:N_subj
            for ns=1:N_subj
                Subject_data_individual=Subject_data(ns);
                
                params_temp=Chain_data(ns).param_chain(ii,:,:);
                LL_hold=NaN(1,Nchain);
%                 for nn=1:Nchain
                parfor nn=1:Nchain
                    params=params_temp(1,:,nn);
                    
                    % C.H. - function converts a vector of parameters into the structure accepted by LL_handle (computeLL_NormApprox.m)
                    params = constructParamsStruct(params); 
                    % C.H. - function computeLL_NormApprox.m computes likelihood of data
                    LL = LL_handle(params, Subject_data(ns));  
                    LL_hold(1,nn)=LL;
                end
                Chain_data(ns).LL(ii,:)=LL_hold;
            end
            
            
        end
    end
    
    
    
    %% Reset outliers at the end of the burnin. This is only done once.
    
    if ii==ceil(burnin)
        
        for ns=1:N_subj
            Chain_data_individual=Chain_data(ns).param_old;
            param_new = Chain_reset_handle(Chain_data_individual);
            
            Chain_data(ns).param_old=param_new;
            Chain_data(ns).param_chain(ii,:,:)=param_new;
            acceptance(ns)=0;
        end
        
        
    end
    
    
end
% TimeKeep=toc

%% Initialize DIC storage vector
DIC = NaN(length(Subject_data),1);

for ns=1:length(Chain_data)
    
    [DICt, meanParams] = Compute_DIC(Chain_data(ns).param_chain,Chain_data(ns).LL,Subject_data(ns),MCMC_params,Model_Details);
    DIC(ns)=DICt;
    
end

save(MCMC_params.savename,'MCMC_params','Subject_data','Model_Details','Chain_data','acceptance','DIC','meanParams')





