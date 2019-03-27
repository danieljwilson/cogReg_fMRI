function prior = DDM_Prior_fun(params)
% This function computes the prior for the given parameter set. The prior
% for each parameter here is just a uniform distribution for simplicity.

wTaste = params(1);
wHealth = params(2);
barrier = params(3);
startbias = params(4);
ndt = params(5);


%%
if barrier<0 || barrier>10
    pbarrier=0;
else
    pbarrier=1/10;
end

%%


%%
if wTaste<-5 || wTaste>5
    pTaste=0;
else
    pTaste=1/10;
end

%%
if wHealth<-5 || wHealth>5
    pHealth=0;
else
    pHealth=1/10;
end

%%

if startbias < -1 || startbias > 1
    pSB = 0;
else
    pSB = 1/2;
end


%%
if ndt<0 || ndt>4
    pndt=0;
else
    pndt=1/4;
end


%% 
prior=pTaste*pHealth*pbarrier*pSB*pndt;