function foodreg_m3_pre_m_post_analyze2(subjNameList, preproc_version)

% preproc_version can be:
% 'SubjectData_icaAroma_nonAggr_6mm'
% 'SubjectData_MNI152_8mm'

% function errorlog = par_analyze(modelid, numworkers)
% script to run parallel GLM in SPM on neuroecon cluster
% Project: Goal Value Regulation
% Script: script for setting up and estimating -- MODEL 2
%
% MODEL SPECIFICATION:
% Divide trials into three types (natural, decrease, increase), 4 sec + RT
% duration
% Modulate each trial type by post-scan taste and health rating
%
% Author: Antonio Rangel (GLM setup)
% Author: Cendri Hutcherson (parallel setup and model specification)

% Last modified: 6.2009
%
% NOTE:
% - Code designed to work with SPM5 & matlab 74
% - Code run in an Intel PowerMac
%
%
% NOTE:
% - Script calls function makeSPMdesignmatrix that needs to be located in the 
%    directory specified below (see the appropriate lines of code at the end of
%   the program)
% - See spm5 online help for descriptions of the usage of the spm commands
%
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%
% LIST OF SUBJECT & PRELIMINARY PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%


pathtofile = mfilename('fullpath'); % ignore

studyid = 'food_reg_fmri_01';  

% char(regexprep(regexp(pathtofile,'/FoodRegFMRI/','match'),'/',''))

modelid = pathtofile(regexp(pathtofile,'_m\d+.*_analyze')+2:(regexp(pathtofile,'_analyze')-1)); %  gets model id
% gets this from the path file

homepath = pathtofile(1:(regexp(pathtofile,studyid)-1)); % will identify up to '/PILOT' as the homepath
			
%List of sessions

spm('defaults','FMRI')  % sets spm to have defaults for fmri
%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE CONDITIONS
%%%%%%%%%%%%%%%%%%%%%%%%

% define design conditions
ons_name{1}='Natural';
ons_name{2}='DecreaseDesire';
ons_name{3}='HealthFocus';
ons_name{4}='Missed Trials';

scannames = 1:9; % return to this

for subj=1:length(subjNameList)     % this loops over subjects - but can call once/subject
    % prints out which subject is being processed
    current = ['processing subject ', subjNameList{subj}, '...'];
    display(current)
    
    subjID = subjNameList{subj};    % supplied to the function (input) which subjects to work on
    
%     SubjectSession = dir([homepath studyid '/MRIData/' subjID 'nii/swa*']);
    
% gets the behavioral datafiles
% convert to TSV from Matlab
    files = dir(fullfile(homepath, studyid, 'trial_data', subjID, 'Data*mat'));  % lists all files
    files = {files(~cellfun('isempty', ... % lists files that have .#.mat format
                regexp({files.name}, ['Data\.' subjID '.\d.mat']))).name};  
    
    % Get pre liking ratings
    load(fullfile(homepath, studyid, 'trial_data', subjID, strcat('Data.', subjID, '.LikingRatings-Pre.mat')));
    pre_ratings = Data;
    % Get post scan ratings
    load(fullfile(homepath, studyid, 'trial_data', subjID, strcat('Data.', subjID, '.AttributeRatings-Post.mat')));
    post_ratings = Data;
    
    % vector with 1s where trial type matches given text
    post_liking_trials = strcmp(post_ratings.Attribute, 'Liking');
    
    % get rating and food item for taste and health
    pre_rating = cell2mat(pre_ratings.Resp);
    post_rating = cell2mat(post_ratings.Resp(post_liking_trials));
    pre_food = pre_ratings.Food;
    post_food = post_ratings.Food(post_liking_trials);
    
    for session=1:length(files) % this loops over sessions
        
        load(fullfile(homepath, studyid, 'trial_data', subjID, files{session})) 
        
        missedTrials = strcmp(Data.Resp,'NULL');
        ons_Missed = cell2mat(Data.FoodOn(missedTrials));  % onset times of missed trials
        
        Data.Resp = Data.Resp(~missedTrials);
        Data.ChoiceRT = Data.ChoiceRT(~missedTrials);
        Data.Instruction = Data.Instruction(~missedTrials);
        Data.Food = Data.Food(~missedTrials);
        Data.FoodOn = Data.FoodOn(~missedTrials);
        
        Natural = strcmp(Data.Instruction,'Respond Naturally');
        DecreaseDesire = strcmp(Data.Instruction,'Decrease Desire');
        HealthFocus = strcmp(Data.Instruction,'Focus on Healthiness');
        
        
        % get onsets for trial events
        ons_Natural = cell2mat(Data.FoodOn(Natural)); % - 10; % might need to adjust for discarded TRs
        ons_DecreaseDesire = cell2mat(Data.FoodOn(DecreaseDesire)); % - 10;
        ons_HealthFocus = cell2mat(Data.FoodOn(HealthFocus)); % - 10;
        
        
        
        RT_Natural = cell2mat(Data.ChoiceRT(Natural));
        RT_DecreaseDesire = cell2mat(Data.ChoiceRT(DecreaseDesire));
        RT_HealthFocus = cell2mat(Data.ChoiceRT(HealthFocus));
        
    	%%%%%%%%%%%%%%%%%%
    	% define onsets for all of the conditions
    	%%%%%%%%%%%%%%%%%%

        ons{1,session}= ons_Natural';
        ons{2,session}= ons_DecreaseDesire';
        ons{3,session}= ons_HealthFocus';
        ons{4,session}= ons_Missed;

        %%%%%%%%%%%%
        % define durations
        %%%%%%%%%%%%%
        
        %enter a column vector for the session 
        ons_duration{1,session}= RT_Natural'; %in secs
        ons_duration{2,session}= RT_DecreaseDesire'; %in secs
        ons_duration{3,session}= RT_HealthFocus'; %in secs
        ons_duration{4,session}= 4;  % this is for missed trials (get 4 s)
        
    	%%%%%%%%%%%%%%%%%%%%%%%%
		% define modulating parameters
		%%%%%%%%%%%%%%%%%%%%%%%%
	
		%predefine modulating parameters (taste and health ratings) for three
		%trial types
        %one modulator for each condition
        %additional modulator would be {2} (or {3}...)
        %SPM checks for correlation between regressor automatically
        %SPM will assign shared variance to the first regressor (at least
        %SPM 8). This is called orthogonalization.

        % First modulator
        ons_modulate{1,session}{1}.name='pre_m_post';   
        ons_modulate{2,session}{1}.name='pre_m_post';
        ons_modulate{3,session}{1}.name='pre_m_post';
        
                
        %no modulator order - (linear parametric modulator)
        %here we say order = 1 (linear) but could do squared or cubic,
        %etc...(2/3...) This is rare.
        for i = 1:size(ons_modulate,1)
            for j = 1:size(ons_modulate{i,session},2)
                ons_modulate{i,session}{j}.order=1;
            end
        end
        
        % Sets 4th onset vector (missed trials) as not having a modulator
        ons_modulate{4,session}{1}.name='none';

		% define modulator values - this assigns the value that the subject
		% pressed in the scanner to the modulator
        
        pre_m_post_Natural = zeros(sum(Natural),1);
        
        trial_foods = Data.Food(Natural);
        for i = 1:sum(Natural)
            trial_food_pre = strcmp(pre_food, trial_foods(i));
            trial_food_post = strcmp(post_food, trial_foods(i));
            pre_m_post_Natural(i) =  pre_rating(trial_food_pre) - post_rating(trial_food_post);
        end
        
        pre_m_post_DecreaseDesire = zeros(sum(DecreaseDesire),1);
        
        trial_foods = Data.Food(DecreaseDesire);
        for i = 1:sum(DecreaseDesire)
            trial_food_pre = strcmp(pre_food, trial_foods(i));
            trial_food_post = strcmp(post_food, trial_foods(i));
            pre_m_post_DecreaseDesire(i) = pre_rating(trial_food_pre) - post_rating(trial_food_post);
        end
        
        pre_m_post_HealthFocus = zeros(sum(HealthFocus),1);
        
        trial_foods = Data.Food(HealthFocus);
        for i = 1:sum(HealthFocus)
            trial_food_pre = strcmp(pre_food, trial_foods(i));
            trial_food_post = strcmp(post_food, trial_foods(i));
            pre_m_post_HealthFocus(i) = pre_rating(trial_food_pre) - post_rating(trial_food_post);
        end
        
        ons_modulate{1,session}{1}.vec = pre_m_post_Natural;
        ons_modulate{2,session}{1}.vec = pre_m_post_DecreaseDesire;
        ons_modulate{3,session}{1}.vec = pre_m_post_HealthFocus;
        
        %%%%%%%%%%%%%%%%%%%%%%%%
		% load movement regressors
    
		% clear(mov_reg{session}); %carefule! do NOT clear mov_reg or will remove needed data for session>1
		mov_path = fullfile(homepath, studyid, 'derivatives', 'fmriprep', ['sub-' subjID], 'func');
        mov_file=dir(fullfile(mov_path,  ...   % need to point it to the folder with subject ID in derivatives (need to convert to string)
             ['*task-choose_run-' sprintf('%02.0f',scannames(session)) '*confounds_regressors.tsv']));  % session defining the run (used to be just *confounds.tsv) 
               
        path = fullfile(mov_path, mov_file.name);
        % path = fullfile(homepath, studyid, 'derivatives', 'fmriprep', ['sub-' subjID], 'func', path(1).name);
        df = tdfread(path);
        
        % REGRESSORS
        if ismember('non_steady_state_outlier00', fieldnames(df))
            mov_reg{session} = [df.trans_x df.trans_y df.trans_z df.rot_x df.rot_y df.rot_z, df.non_steady_state_outlier00]; % add non steady state regressor
        else
            mov_reg{session} = [df.trans_x df.trans_y df.trans_z df.rot_x df.rot_y df.rot_z];  % loading in 6 motion regressors here (used to be: [df.X df.Y df.Z df.RotX df.RotY df.RotZ])
        end

        outliers{session} = [];  % this could be nonsteadystateOutlier column
        
 	end	% this ends the loop over sessions
    
    % saves onsets if we want them (not 100% necessary)
    % edit for path names where I want to save!
    % onsetDir = [homepath analysis SPM studyid '/onsets/' subjID]; % removed: num2str(subjID)
	% if ~exist(onsetDir,'dir')
%         mkdir(onsetDir)
%     end
%     filename = [homepath analysis SPM studyid '/onsets/' subjID '/spmonsets' modelid '.mat'];
%     save(filename, 'ons*');
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%
	% make model directory & move there 
	% (so that the SPM matrix estimated below be stored there)
	%%%%%%%%%%%%%%%%%%%%%%%%
    % create results directory PILOT/spmResults/modelid/SubjectData/subjID
    
    resultsDir = fullfile(homepath, studyid, 'analysis', 'SPM', modelid,...
                          preproc_version, subjID);  % SubjectData_icaAroma_nonAggr_6mm, SubjectData_MNI152_8mm
	unix(['mkdir -p ' resultsDir])  % -p flag creates superordinate directories if not extant
    cd(resultsDir)
	
	%%%%%%%%%%%%%%%%%%%%%%%%
	% make design matrix
	%%%%%%%%%%%%%%%%%%%%%%%%
    
    %add path to the scripts directory to matlab so that it can find the (including the Desktop if programs are run from there)
    %next function:
    
    % location of functional images
    scanpath=fullfile(homepath, studyid, 'derivatives', 'fmriprep', ['sub-' subjID], 'func');
	
    SPM = makeSPMdesignmatrix_wCensor(scanpath,ons,ons_name,ons_duration,ons_modulate,mov_reg,outliers, preproc_version);
	
	
    %%%%%%%%%%%%%%%%%%%%%%%%
    % use whole brain mask if it exists
    %%%%%%%%%%%%%%%%%%%%%%%%
% 	mask_file = fullfile(homepath, studyid, 'derivatives', 'fmriprep', ['sub-' subjID], 'func',  ['sub-' subjID '_task-choose_run-' session '_bold_space-MNI152NLin2009cAsym_brainmask.nii.gz']);
%     if exist(mask_file,'file')
%         SPM.xM.TH = -Inf*SPM.xM.TH;
%         SPM.xM.VM = spm_vol(mask_file);
%         SPM.xM.xs.Explicit_masking = 'Yes';
%         SPM.xM.xs.Implicit_masking = 'No';
%         save('SPM.mat','SPM')
%     end
    
    %%%%%%%%%%%%%%%%%%%%%%%%
	% evaluate
	%%%%%%%%%%%%%%%%%%%%%%%%
    
 	SPM = spm_spm(SPM);
end         %this ends the main subject loop
 

%%%%%%%%%%%%%%%%%%%%%%%%
% FINAL HOUSEKEEPING TASKS
%%%%%%%%%%%%%%%%%%%%%%%%%%


