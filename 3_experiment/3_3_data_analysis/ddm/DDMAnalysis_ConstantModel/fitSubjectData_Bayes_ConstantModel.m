function fitSubjectData_Bayes_ConstantModel(subjID)
% This code performs parameter recovery for the standard 2 choice DDM
% model. This code and the data provided are associated with "Bayesian
% Analysis of the Piecewise Diffusion Decision Model" by Holmes and
% Trueblood.
%
% Code adapted by Cendri Hutcherson
% Dec. 2018


% Model_Details = A structure that holds a number of model specifics such as function handles and how parameter blocking is done.
% MCMC_params   = This holds a bunch of MCMC parameters such as number of MCMC iterations and number of chains
% Subject_data  = This holds all of the subject data. The only place it is really used is in the likelihood computation.
%                 This object is indexed as Subject_data(subject #).field
%                 where each instance of the structure holds the data for
%                 that participant. This is VERY IMPORTANT.

% get path to file, allows for independence across machines: C.H.
fileName = mfilename;
pathtofile = which(fileName, '-ALL');
if length(pathtofile) > 1
    pathtofile = pathtofile{2};
else
    pathtofile = pathtofile{1};
end

homePath = pathtofile(1:(regexp(pathtofile,'DDMAnalysis_ConstantModel') - 1));
if isempty(homePath) % catch bug on Dropbox where folders are lowercase
    homePath = pathToFile(1:(regexp(pathToFile,lower('DDMAnalyis_ConstantModel')) - 1));
end
%

format compact
poolJob = parpool(12); % number of cores to request on UTSC cluster: C.H.


%% Specify some function handles
Model_Details.LL_handle=@computeLL_NormApprox;          % Log likelihood computation: C.H.
Model_Details.Prior_handle=@DDM_Prior_fun;              % Prior function: edited by C.H.
Model_Details.Chain_reset_handle=@Chain_reset_fun;      % A function to detect and reset outlier chains at the end of the burnin period. edited by C.H.
Model_Details.Init_handle=@Initialize_structures;       % A function that initializes all chain data. This is where
                                                        % pre-allocation of all larger data structures occurs.: edited by C.H.

%% Handle parameter blocking for the MCMC
Model_Details.block_lower{1}=[1 2 3 4 5 6];   % These are for individual level parameters (C.H.: 6 in total for this version)

% Gamma is a DEMCMC parameter. For optimal performance, it should be tuned
% for each MCMC block. The formula is 2/sqrt(2*block_size).
for i=1:length(Model_Details.block_lower)
    gamma_low(i)=2.38/sqrt(2*length(Model_Details.block_lower{i}));  %#ok<SAGROW>
%     gamma_low(2)=2.38/sqrt(2*length(Model_Details.block_lower{2}));
end

Model_Details.gamma_low=gamma_low;

%% Specify any model parameters that are going to be fixed.
% MCMC_params.s=0.1; % This is the within trial noise parameter.

%% Some PDA specific things.
% C.H.: our DDM simulation does not use individual trials to build a
% distribution, so this is not necessary here
% Likelihood sampling parameters - Only used for PDA
% LL_NSAMPLE=10000;                    % This is the number of samples used in the PDA.
% MCMC_params.LL_NSAMPLE=LL_NSAMPLE; 

% Set  the PDA bandwidth parameter. This is only used if you are using the 
% kernel density estimator of likelihood
% MCMC_params.bandwidth=.02;   

MCMC_params.resampling = 0;          % This is used to turn likelihood resampling on / off. 0 = off, 1 = on (only needed for PDA)

T_final=4;  % This is the maximum simulation time for the DDM model.
dt=0.005;    % This is the time step size for simulation of the DDM model.
N_time_step=ceil(T_final/dt);

MCMC_params.dt=dt;
MCMC_params.N_time_step=N_time_step;

%% MCMC Parameters             

Nstep=3000;                    % Number of MCMC iterations. 
Nchain=18;                     % Number of MCMC chains. Use 3 x largest block size
noise_size=.001;               % This is a DEMCMC parameter
burnin=500;                    % Number of burnin iterations.

MCMC_params.Nstep=Nstep;
MCMC_params.Nchain=Nchain;
MCMC_params.noise_size=noise_size;
MCMC_params.burnin=burnin;

% !!!!! IMPORTANT !!!!!
% Specify where you want things saved.
DIR = fullfile(homePath,'DDMAnalysis_Bayes_ConstantModel','fittedData'); % C.H.
if ~exist(DIR, 'dir')
    mkdir(DIR)
end

%% Load subject's data and fit using DEMCMC
tic

files = dir(fullfile(homePath, 'BehavioralData', subjID, 'Data*mat'));
filesToUse = regexp({files.name},['Data\.' subjID '\.\d\.mat']);
filesToUse = find(cellfun(@(x)~isempty(x),filesToUse) == 1);

RatingData = load(fullfile(homePath,'BehavioralData',subjID,['Data.' subjID '.AttributeRatings-Post.mat']));
RatingData = RatingData.Data;

RT = [];
Resp = [];
NonResp = [];
TrialType = [];
Taste = [];
Health = [];

conds = {'Respond Naturally','Focus on Healthiness','Decrease Desire'};
for f = filesToUse
    load(fullfile(homePath, 'BehavioralData',subjID, files(f).name))
    RT = [RT cell2mat(Data.ChoiceRT)];
    NonResp = [NonResp isnan(RT)];
    Data.Resp(strcmp(Data.Resp,'NULL')) = {NaN};
    Resp = [Resp cellfun(@(x)x > 2, Data.Resp)];
    Resp(NonResp == 1) = NaN;
    
    % get Taste and Health Ratings
    for t = 1:length(Data.Food)
        tempCond(t) = find(strcmp(Data.Instruction{t},conds));
        tempTaste(t) = RatingData.Resp{strcmp(Data.Food{t},RatingData.Food) & strcmp(RatingData.Attribute,'Taste')};
        tempHealth(t) = RatingData.Resp{strcmp(Data.Food{t},RatingData.Food) & strcmp(RatingData.Attribute,'Health')};
    end
    Taste = [Taste tempTaste];
    Health = [Health tempHealth];
    TrialType = [TrialType,tempCond];
end


clear Data;
Data.Resp = Resp';
Data.RT = RT';
Data.TrialType = TrialType';
Data.Taste = Taste' - 3.5; % taste rating
Data.Health = Health' - 3.5; % health rating

conds = {'nat','health','desire'};

for c = 1:3
    selectedTrials = Data.TrialType == c;

    tempData.Resp = Data.Resp(selectedTrials);
    tempData.RT = Data.RT(selectedTrials);
    tempData.Taste = Data.Taste(selectedTrials);
    tempData.Health = Data.Health(selectedTrials);

    Subject_data = tempData;

    %% Run MCMC

    MCMC_params.savename=fullfile(DIR,['fittedResults_' num2str(subjID) '_' conds{c}]); % C.H.
    
    % check if the results have already been completed and run only if not
    doWork = 1;
    if exist(MCMC_params.savename,'file')
        MCMC_results = load(MCMC_params.savename);
        if isfield(MCMC_results,'meanParams')
            doWork = 0;
        end
    end
    
    if doWork == 1
        DE_MCMC_fun(MCMC_params,Subject_data,Model_Details);
    end
end
delete(poolJob)
toc

%exit

