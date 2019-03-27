function par_analyze(subjNameList)
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

studyid = char(regexprep(regexp(pathtofile,'/[A-Z]{3}\d?/','match'),'/',''));

modelid = pathtofile(regexp(pathtofile,'\d+_analyze'):(regexp(pathtofile,'_analyze')-1));

homepath = pathtofile(1:(regexp(pathtofile,studyid)-1));

% List of subject names and corresponding numbers.
% subjNameList = {'103' ... '104' '105' '106' '107' '108' '109' ...
%                 ... '111' '112' '113' '114' '115' '116' '117' '118' '119' '120' ...
%                 ... '121' '122'... '123' '124' '125' '126' '127' '128' '129' '130' ...
%                 ...'131' '132' ...
%                 };

for i = 1:length(subjNameList)
    subjNumList{i} = num2str(i);
    subjNumericalList{i} = i;
end

				
%List of sessions


spm('defaults','FMRI')
%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE CONDITIONS
%%%%%%%%%%%%%%%%%%%%%%%%

%define design conditions
ons_name{1}='Proposal';
ons_name{2}='Outcome';

for subj=1:length(subjNameList)     %this loops over subjects
    
    if isequal(subjNameList{subj},'154') || isequal(subjNameList{subj},'162')
        SubjectSession={'scan1' ,'scan2', 'scan3'};
    else
        SubjectSession={'scan1' ,'scan2', 'scan3' 'scan4'};
    end
    
    subjID = subjNameList{subj};
    subjNum = subjNumList{subj};
    Num = subjNumericalList{subj}; 
    
    for session=1:length(SubjectSession) % this loops over sessions
    	

    	
    	
    	%%%%%%%%%%%%%%%%%%%%%%%%
    	% create vector of behavioral data
    	%%%%%%%%%%%%%%%%%%%%%%%%
        
        path=[homepath studyid filesep subjID '/Data.' subjID '.scan' num2str(session) '.mat'];
        load(path);  
        
        % delete missed response trials
%         if str2double(subjID) > 148
            nullstr = NaN;
%         else
%             nullstr = 'NULL';
%         end
        
        Data.ProposalOnset(searchcell(Data.Resp,nullstr)) = [];
        Data.OutcomeOnset(searchcell(Data.Resp,nullstr)) = [];
        Data.RT(searchcell(Data.Resp,nullstr)) = [];
        Data.SelfAmount(searchcell(Data.Resp,nullstr)) = [];
        Data.OtherAmount(searchcell(Data.Resp,nullstr)) = [];
        Data.SelfOutcome(searchcell(Data.Resp,nullstr)) = [];
        Data.OtherOutcome(searchcell(Data.Resp,nullstr)) = [];
        Data.Resp(searchcell(Data.Resp,nullstr)) = [];

        ons_Proposal     = cell2mat(Data.ProposalOnset);
        ons_Outcome    = cell2mat(Data.OutcomeOnset);       
        RT = cell2mat(Data.RT);
        
    	%%%%%%%%%%%%%%%%%%
    	% define onsets for all of the conditions
    	%%%%%%%%%%%%%%%%%%

        ons{1,session}= ons_Proposal' - 5.5;
        ons{2,session}= ons_Outcome' - 5.5;
        
        clear ons_Proposal ons_Outcome

        %%%%%%%%%%%%
        % define durations
        %%%%%%%%%%%%%
        
        %enter a column vector for the session 
        ons_duration{1,session}= RT'; %in secs
        ons_duration{2,session}= zeros(length(ons{2,session}),1); %in secs       
        
    	%%%%%%%%%%%%%%%%%%%%%%%%
		% define modulating parameters
		%%%%%%%%%%%%%%%%%%%%%%%%
	
		%predefine modulating parameters

        ons_modulate{1,session}{1}.name='SelfAmount';
        ons_modulate{1,session}{2}.name='OtherAmount';
        ons_modulate{2,session}{1}.name='SelfAmount';
        ons_modulate{2,session}{2}.name='OtherAmount';

		
        %no modulator order - 
	    ons_modulate{1,session}{1}.order=1;
	    ons_modulate{1,session}{2}.order=1;
        
        ons_modulate{2,session}{1}.order=1;
        ons_modulate{2,session}{2}.order=1;

        
		%define modulator values
        SelfProposal = cell2mat(Data.SelfAmount);
        OtherProposal = cell2mat(Data.OtherAmount);
        
        SelfOutcome = cell2mat(Data.SelfOutcome);
        OtherOutcome = cell2mat(Data.OtherOutcome);
        
        Resp = cell2mat(Data.Resp);
        
        ons_modulate{1,session}{1}.vec=SelfProposal';
        ons_modulate{1,session}{2}.vec=OtherProposal';

        ons_modulate{2,session}{1}.vec=SelfOutcome';
        ons_modulate{2,session}{2}.vec=OtherOutcome';
	
        
        %%%%%%%%%%%%%%%%%%%%%%%%
		% load movement regressors
        if isequal(subjID,'999')
            sessex = 1;
            scn = '3';
        elseif isequal(subjID,'998') 
            sessex = -1;
            scn = '3';
        else
            sessex = 0;
            scn = '3';
        end

		clear mov_reg{session}; %carefule! do NOT clear mov_reg or will remove needed data for session>1
		path=[homepath studyid filesep subjID '/scan' num2str(session) ...
			'/rp_afrange_-000' num2str(session+2+sessex) '-0000' scn '-00000' scn '-00.txt'];
		mov_reg{session} = eval(['load(path)']);
	
	
		%%%%%%%%%%%%%%%%%%%%%%%%
		% define location of functional images
		% each session is on a separate directory
		%%%%%%%%%%%%%%%%%%%%%%%%
	
		clear filestr{session}; %carefule! do NOT clear filestr or will remove needed data for session>1
		filestr{session}=[homepath studyid filesep subjID '/scan' num2str(session) '/'];
        
        
 	end	% this ends the loop over sessions
	
    filename = [homepath studyid '/onsets/' num2str(subjID) '/spmonsets' modelid '.mat'];
    save(filename, 'ons*');
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%
	% make model directory & move there 
	% (so that the SPM matrix estimated below be stored there)
	%%%%%%%%%%%%%%%%%%%%%%%%
	mkdir([homepath studyid '/results/m' modelid '/'])
	cd([homepath studyid '/results/m' modelid '/'])
	eval(['mkdir ' subjID])
    eval(['cd ' subjID])    %go to the subject's directory
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%
	% make design matrix
	%%%%%%%%%%%%%%%%%%%%%%%%
    
    %add path to the scripts directory to matlab so that it can find the (including the Desktop if programs are run from there)
    %next function:
    
	SPM = makeSPMdesignmatrix_m1(filestr,ons,ons_name,ons_duration,ons_modulate,mov_reg);
	
	
    %%%%%%%%%%%%%%%%%%%%%%%%
    % use whole brain mask if it exists
    %%%%%%%%%%%%%%%%%%%%%%%%
	

    if exist([homepath studyid '/results/amasks/' lower(studyid) 'anat_mask.nii'],'file')
        SPM.xM.TH = -Inf*SPM.xM.TH;
        SPM.xM.VM = spm_vol([homepath studyid '/results/amasks/' lower(studyid) 'anat_mask.nii']);
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


