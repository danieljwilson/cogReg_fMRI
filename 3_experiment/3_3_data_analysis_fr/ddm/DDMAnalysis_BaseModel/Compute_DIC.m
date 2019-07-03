function [DIC, p_mean] = Compute_DIC(param_chain,LL,Subject_data,MCMC_params,Model_Details)

% This file computers the DIC for an individual participant. As such, the
% file needs to read in the parameter chain information, the stored
% log-likelihood computed for each chain entry, and that subject's data.
% This code should detect the number of subject level parameters and loop
% over them, then directly call the requisite likelihood function. So it
% should not require any user editing (I THINK).
burnin=MCMC_params.burnin;

LL_handle=Model_Details.LL_handle;

np    = size(param_chain,2); % # params
% nc    = size(param_chain,3); % # chains, not used
% nstep = size(param_chain,1); % # chain iterations, not used

%% Reshape the LL data

LL_use = LL(burnin:end,:);
LL_use = LL_use(:);

LL_use(isinf(LL_use))=min(LL_use(~isinf(LL_use))); % Replace any infinities.


%% Extract chain data and compute the mean parameter set
for i = 1:np
    ptemp=param_chain(burnin:end,i,:);
    ptemp=ptemp(:);
    ptemp_mean=nanmean(ptemp);
    eval(['p_mean(' num2str(i) ')=ptemp_mean;'])
    clear ptemp_mean ptemp  
end


%% Compute LL for the mean parameter set
% C.H. - function converts a vector of parameters into the structure accepted by LL_handle (computeLL_NormApprox.m)
params = constructParamsStruct(p_mean); 
% C.H. - function computeLL_NormApprox.m computes likelihood of data
LL_mean = LL_handle(params, Subject_data);  

%% Use chain LL data and the new mean LL value to compute DIC
Dbar=-2*mean(LL_use);
Dthetabar=-2*LL_mean;
pD=Dbar - Dthetabar;
% Dthetabar_full=-2*LL_full_mean;

DIC=Dbar+pD;