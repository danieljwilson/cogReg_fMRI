clear all;
curr_dir = pwd;

%-- Identify path names --%
pathtofile = mfilename('fullpath');

studyid = 'food_reg_fmri_01';

homepath = pathtofile(1:(regexp(pathtofile,studyid)-1)); % will identify up to '/PILOT' as the homepath

%--- Load template (must have been created beforehand) ---%
% load([homepath 'genericstudy' filesep 'corr_template.mat']);

%--- List models ---%
    % Get a list of all files and folders in this folder.
files = dir([homepath studyid '/analysis/SPM/' '*_*']);
    % Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
    % Extract only those that are directories.
subFolders = files(dirFlags);
    % Print folder names to command window.
fprintf('\nModel List:\n');
for k = 1 : length(subFolders)
  fprintf('%s\n', subFolders(k).name);
end
%--- Get user entered variables ---%
modelid = input('\nWhich model is the contrast from?: ','s');
% check to make sure this is an existing model
if ~exist([homepath studyid '/analysis/SPM/' modelid],'dir')
    modelid = input('That''s not a directory!! Try again: ','s');
end

% load contrasts and print to screen
load([homepath studyid '/analysis/SPM/' modelid '/SubjectData_MNI152_8mm/m' modelid '_cons.mat'])
fprintf('\n*-----------------------------------------------------*\n');
fprintf('\nThis model has the following contrasts:  \n\n'); % lists available contrasts
for x = 1:length(cname)
    fprintf('%d %s\n',x,cname{x});
end
fprintf('\n*-----------------------------------------------------*\n');
contrast_name = input('Contrast #?: '); % select contrast for DV
contrast_name = cname{contrast_name};
fprintf('\n')

% List possible x variables
fprintf([
    % DDM WEIGHTS
    'wTaste_mean    wHealth_mean    sp_bias_mean\n'...
    'constant_mean threshold_mean\n'...
    
    'wTaste_N wTaste_H wTaste_D\n'...
    'wTaste_change_HvN\t\t        wTaste_change_HvD\t\t      wTaste_change_DvN\n'...
    
    'wHealth_N wHealth_H wHealth_D\n'...
    'wHealth_change_HvN\t\t      wHealth_change_HvD\t\t      wHealth_change_DvN\n'...
    
    'sp_bias_N sp_bias_H sp_bias_D\n'...
    'sp_bias_change_HvN sp_bias_change_HvD sp_bias_change_DvN\n'...
    
    'constant_N constant_H constant_D\n'...
    'constant_change_HvN constant_change_HvD constant_change_DvN\n'...
    
    'threshold_N threshold_H threshold_D\n'...
    'threshold_change_HvN threshold_change_HvD threshold_change_DvN\n'...
    
    'pre_m_post_N pre_m_post_H pre_m_post_D\n'...
    'pre_m_post_change_HvN pre_m_post_change_HvD pre_m_post_change_DvN\n'...
   
    
    % QUESTIONNAIRES
    'bis_overall\n'...
    'bis_attentional  bis_attentional_attention bis_attentional_cog_inst\n'...
    'bis_motor bis_motor_motor bis_motor_perserverance\n'...
    'bis_nonplanning bis_nonplanning_self_control bis_nonplanning_cog_comp\n'...
    
    'threeF_uncontrolled threeF_restraint threeF_emotional\n'...
    'rfs_fruit_veg rfs_fat\n'...
    'perceived_stress\n'...
    'bmi\n'...
    '\n'...
    '\n'...
    '\n'...    
    ''
%     

%     
%     ConditionEffects[1:11] (don't use)
%     Choice Strategy[1:16] (consider using factor analysis)
%     
    
    ]);

% fprintf(selecttext);


xvar = input('Predictor variable?: ');
if isempty(xvar) || xvar < 1 || xvar > 22
    xvar = input('Incorrect input!! Try again: ');
end


fprintf('\n*-----------------------------------------------------*\n');
fprintf('0  No filter\n');
% fprintf('1  Subjects w/ > 8 Generous choices\n');
% fprintf('2  Generous subjects only\n');


use_filter = input('Which filter? (default = no filter) ');
if isempty(use_filter)
    use_filter = 0;
end

% List of subjects
subj_ids = {
    '101' '102' '103' '104'         '106' '107' '108' '109' '110' ...
    '111' '112'         '114'         '116'         '118' '119' '120' ...
    '121'         '123' '124' '125' '126'                 '129' '130' ...
    '131' '132' '133' '134' '135' '136' '137'         '139' '140' ... 
            '142' '143' '144' '145' '146' '147' '148'         '150' ... 
            '152' '153' '154' '155' '156' '157' '158'                 ... 
            '162' '163' '164'
            };
% Excluded subjects:

switch use_filter
    case 1
        filtername = 'example_subselection';
        excludedsubs = {'104' '114' '117' '118' '120' '122'};
    otherwise
        filtername = '';
        excludedsubs = {};
end

switch xvar
    case 1  % Explain in detail (e.g. health weight change estimated from DDM - link to model)
        xname = 'wHealth_change_HvN';
        varfile = 'wHealth_change_HvN.mat'; % need to create...needs to be row vector, not colum
    case 2  % Money sacrificed on Natural trials
        xname = 'NatMF';
        varfile = 'AveMF_Nat.mat';
    case 3  % % Generous Choice on Natural trials
        xname = 'NatPercG';
        varfile = 'PercG_Nat.mat';
    case 4  % Money donated on Natural trials
        xname = 'EthMD';
        varfile = 'AveMD_Eth.mat';
    case 5  % Money sacrificed on Natural trials
        xname = 'EthMF';
        varfile = 'AveMF_Eth.mat';
    case 6  % % Generous Choice on Natural trials
        xname = 'EthPercG';
        varfile = 'PercG_Eth.mat';
    case 7  % Money donated on Natural trials
        xname = 'PrtMD';
        varfile = 'AveMD_Prt.mat';
    case 8  % Money sacrificed on Natural trials
        xname = 'PrtMF';
        varfile = 'AveMF_Prt.mat';
    case 9  % % Generous Choice on Natural trials
        xname = 'PrtPercG';
        varfile = 'PercG_Prt.mat';
    case 10  % % Ave MF, Ethics - Natural
        xname = 'MD_EvN';
        varfile = 'AveMD_EthvNat.mat';
    case 11  % % Ave MF, Ethics - Natural
        xname = 'MD_PvN';
        varfile = 'AveMD_PrtvNat.mat';
    case 12  % % Ave MF, Partner - Ethics
        xname = 'MD_PvE';
        varfile = 'AveMD_PrtvEth.mat';
    case 13  % % Ave MF, Ethics - Natural
        xname = 'MF_EvN';
        varfile = 'AveMF_EthvNat.mat';
    case 14  % % Ave MF, Ethics - Natural
        xname = 'MF_PvN';
        varfile = 'AveMF_PrtvNat.mat';
    case 15  % % Ave MF, Partner - Ethics
        xname = 'MF_PvE';
        varfile = 'AveMF_PrtvEth.mat';
    case 16  % % Ave MD, Reg - Nat
        xname = 'MD_RvE';
        varfile = 'AveMD_RegvNat.mat';
    case 17  % % Social network size
        xname = 'SocNetworkSize';
        varfile = 'SocNetworkSize.mat';
    case 18  % % Social network size
        xname = 'SocNetworkDiversity';
        varfile = 'SocNetworkDiversity.mat';
    case 19  % % Loss aversion lambda
        xname = 'LossAversion';
        varfile = 'LossAversion.mat';
    case 20  % % Loss aversion lambda
        xname = 'DDMSelfNat';
        varfile = 'DDMSelf_Nat.mat';
    case 21  % % Loss aversion lambda
        xname = 'DDMOtherNat';
        varfile = 'DDMOther_Nat.mat';
end

%--- Run calculations ---%

% directory where covariate for correlation is located
load([homepath studyid '/analysis/SPM/correlation_regressors/' varfile]) % loads all .mat vectors from above ... specify filepath correctly

% Directory where the 1st level contrast images are saved - subject folders will be added within the loop
% Must have a matching entry for each subject in subj_ids!!!!  
con_dir = [homepath studyid '/analysis/SPM/' modelid '/SubjectData_MNI152_8mm/']; 

% Directory to write the 2nd level correlation results into
% the script will make this directory
out_dir = [homepath studyid '/analysis/SPM/' modelid '/correlation_results/corr_' ... $ rfxXMvmt analgous to `good_subjects`
           xname '_w_' contrast_name filtername];
% out_dir = ['~/Desktop/temp/corr_' xname '_w_' contrast_name filtername];
mkdir(out_dir)

% This name will be given to the contrast within the SPM.mat file
cnamecorr = ['corr with ' xname ];


matlabbatch{1}.spm.stats.factorial_design.dir = {out_dir};
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.c = xvar_values';
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.cname = xname;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

if ~isempty(excludedsubs)
    Xsubindex = zeros(1,length(excludedsubs));
    for n = 1:length(excludedsubs)
        Xsubindex(n) = searchcell(subj_ids,excludedsubs{n});
    end

    subj_ids(Xsubindex) = [];
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.c(Xsubindex)= [];
end

% checks to see that a given subject actually has the contrast of interest
% (i.e. non-zero variability)
count = 1;
excludemoresubs = zeros(length(matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.c),1);

for subjno=1:length(subj_ids)
	if ~isempty(dir([con_dir  subj_ids{subjno} '/*_cons.mat'])) && ~isnan(matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.c(subjno))
        load(deblank(ls([con_dir subj_ids{subjno} '/*_cons.mat'])));
        contrast = searchcell(cname,contrast_name);
        if ~isempty(contrast)
            contrast = sprintf('con_%04.0f.img',contrast);
            matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans{count,1} = char([ ...
            con_dir subj_ids{subjno} filesep contrast ',1'  ]);
            count = count + 1;
        else
            excludemoresubs(subjno) = 1;
        end
    else
        excludemoresubs(subjno) = 1;
    end
end
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.c(excludemoresubs == 1)= [];

spm fmri
%set up the contrast
cd(out_dir)
spm_jobman('run', matlabbatch);

%estimate the contrast

clear SPM
load SPM
SPM=spm_spm(SPM);
%The contrast for the correlation should be the [0; 1] because it is the second column
SPM.xCon = spm_FcUtil('Set', cnamecorr, 'T', 'c', [1; 0], SPM.xX.xKXs);
spm_contrasts(SPM);

cd(curr_dir)
% xjview([out_dir filesep 'spmT_0001.img'])