function foodreg_m1_Preference_analyze2(subjNameList)
% function errorlog = par_analyze(modelid, numworkers)
% script to run parallel GLM in SPM on neuroecon cluster
% Project: Goal Value Regulation
% Script: script for setting up and estimating -- MODEL 2
%
% MODEL SPECIFICATION:
% Divide trials into three types (natural, decrease, increase), 4 sec + RT
% duration
% Modulate each trial type by pre-scan preference rating
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


pathtofile = mfilename('fullpath');

studyid = char(regexprep(regexp(pathtofile,'/FoodRegFMRI/','match'),'/',''));

modelid = pathtofile(regexp(pathtofile,'\d+.*_analyze'):(regexp(pathtofile,'_analyze')-1));

homepath = pathtofile(1:(regexp(pathtofile,studyid)-1));
			
%List of sessions

spm('defaults','FMRI')
%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE CONDITIONS
%%%%%%%%%%%%%%%%%%%%%%%%

% define design conditions
ons_name{1}='Natural';
ons_name{2}='DecreaseDesire';
ons_name{3}='HealthFocus';
ons_name{4}='Missed Trials';

scannames = [5,12,18];

for subj=1:length(subjNameList)     % this loops over subjects
    
    subjID = subjNameList{subj};
    
%     SubjectSession = dir([homepath studyid '/MRIData/' subjID 'nii/swa*']);
    
    files = dir(['~/Desktop/Dropbox/Experiments/FoodRegFMRI/SubjectData/', subjID '/Data*mat']); % lists all files
    files = {files(~cellfun('isempty', ... lists files that have .#.mat format
                regexp({files.name}, ['Data\.' subjID '.\d.mat']))).name};
            
    for session=1:length(files) % this loops over sessions
        
        load(fullfile('~/Desktop/Dropbox/Experiments/FoodRegFMRI/SubjectData/', subjID, files{session})) 
        
        missedTrials = strcmp(Data.Resp,'NULL');
        onsMissed = cell2mat(Data.FoodOn(missedTrials));
        
        Data.Resp = Data.Resp(~missedTrials);
        Data.ChoiceRT = Data.ChoiceRT(~missedTrials);
        Data.Instruction = Data.Instruction(~missedTrials);
        
        Natural = strcmp(Data.Instruction,'Respond Naturally');
        DecreaseDesire = strcmp(Data.Instruction,'Decrease Desire');
        HealthFocus = strcmp(Data.Instruction,'Focus on Healthiness');
        
        
        % get onsets for trial events
        ons_Natural = cell2mat(Data.FoodOn(Natural)) - 10; % might need to adjust for discarded TRs
        ons_DecreaseDesire = cell2mat(Data.FoodOn(DecreaseDesire)) - 10;
        ons_HealthFocus = cell2mat(Data.FoodOn3(HealthFocus)) - 10;
        
        
        
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
        ons_duration{4,session}= 4;
        
    	%%%%%%%%%%%%%%%%%%%%%%%%
		% define modulating parameters
		%%%%%%%%%%%%%%%%%%%%%%%%
	
		%predefine modulating parameters

        ons_modulate{1,session}{1}.name='Preference';
        
        ons_modulate{2,session}{1}.name='Preference';
        
        ons_modulate{3,session}{1}.name='Preference';
        
        %no modulator order - 
        for i = 1:size(ons_modulate,1)
            for j = 1:size(ons_modulate{i,session},2)
                ons_modulate{i,session}{j}.order=1;
            end
        end
        
        
		% define modulator values
        
        pref_Natural = cell2mat(Data.Resp(Natural));
        pref_DecreaseDesire = cell2mat(Data.Resp(DecreaseDesire));
        pref_HealthFocus = cell2mat(Data.Resp(HealthFocus));
        
        %%%%%%%%%%%%%%%%%%%%%%%%
		% load movement regressors

		clear mov_reg{session}; %carefule! do NOT clear mov_reg or will remove needed data for session>1
		path=dir(fullfile(homepath, studyid,  ...
             ['rp_afCBCMoral-' sprintf('%04.0f',scannames(session)) '*']));
        path = fullfile(homepath, studyid, path(1).name);
		mov_reg{session} = load(path);
        outliers{session} = [];
        
 	end	% this ends the loop over sessions
    
    onsetDir = [homepath studyid '/onsets/' num2str(subjID)];
	if ~exist(onsetDir,'dir')
        mkdir(onsetDir)
    end
    filename = [homepath studyid '/onsets/' num2str(subjID) '/spmonsets' modelid '.mat'];
    save(filename, 'ons*');
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%
	% make model directory & move there 
	% (so that the SPM matrix estimated below be stored there)
	%%%%%%%%%%%%%%%%%%%%%%%%
    resultsDir = fullfile(homepath, studyid, 'spmResults', modelid,...
                          'SubjectData',subjID);
	unix(['mkdir -p ' resultsDir])
    cd(resultsDir)
	
	%%%%%%%%%%%%%%%%%%%%%%%%
	% make design matrix
	%%%%%%%%%%%%%%%%%%%%%%%%
    
    %add path to the scripts directory to matlab so that it can find the (including the Desktop if programs are run from there)
    %next function:
    
    % location of functional images
    scanpath=fullfile(homepath, studyid);
	
    SPM = makeSPMdesignmatrix_wCensor(scanpath,ons,ons_name,ons_duration,ons_modulate,mov_reg,outliers);
	
	
    %%%%%%%%%%%%%%%%%%%%%%%%
    % use whole brain mask if it exists
    %%%%%%%%%%%%%%%%%%%%%%%%
	
    if exist([homepath studyid '/mask_' lower(studyid) '_avg_anat.nii'],'file')
        SPM.xM.TH = -Inf*SPM.xM.TH;
        SPM.xM.VM = spm_vol([homepath studyid '/mask_' lower(studyid) '_avg_anat.nii']);
        SPM.xM.xs.Explicit_masking = 'Yes';
        SPM.xM.xs.Implicit_masking = 'No';
        save('SPM.mat','SPM')
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%
	% evaluate
	%%%%%%%%%%%%%%%%%%%%%%%%
    
 	SPM = spm_spm(SPM);
end         %this ends the main subject loop
 

%%%%%%%%%%%%%%%%%%%%%%%%
% FINAL HOUSEKEEPING TASKS
%%%%%%%%%%%%%%%%%%%%%%%%%%


