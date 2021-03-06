clear all;
curr_dir = pwd;

%-- Identify path names --%
pathtofile = mfilename('fullpath'); % ignore

studyid = 'food_reg_fmri_01';  

homepath = pathtofile(1:(regexp(pathtofile,studyid)-1)); % will identify up to '/PILOT' as the homepath

%--- Load template (must have been created beforehand) ---%
% load([homepath 'genericstudy' filesep 'corr_template.mat']);

%--- Get user entered variables ---%

% List possible x variables
fprintf(['1  HealthWeightChange_HvN\t\t 2  TasteWeightChange_HvN\n' ...
            '3 BIS\t\t 4 OTHERVARIABLE\n']);
% e.g. difference in weight on health v natural (ddm)
% same for taste weight
% BIS scale - predicts responses in nat cond? (for example)

%          '16 SFG GvS Nat\t\t17 %% ahead trials \n', ...
% fprintf(selecttext);


xvar = input('Predictor variable?: ');
if isempty(xvar) || xvar < 1 || xvar > 4
    xvar = input('Incorrect input!! Try again: ');
end

use_filter = input('Which filter? (default = no filter) ');
if isempty(use_filter)
    use_filter = 0;
end

%--- List of subjects
subj_ids = {'101' '102' '103' '104' '105'       '107' '108' '109' '110'   ... 
            '111' '112' '113' '114'             '117' '118' '119' '120'...
            '121' '122' '123' '124'       '126'             '129' '130' ...
            '131' '132' '133'             '136' '137' '138' '139' '140' ... '134'
            '141' '142' '143' '144' '145' '146' '147' '148' '149' '150' ... 
            '151' '152' '153' '154'       '156' ... '157' '158' '159' '160' ...
            '216' '234'
            };
% Excluded subjects:
% 106,125,127,115,116,135 - head motion
% 128 - said NO to every offer
% 148 - sad NO to 92% of offers

switch use_filter
    case 1
        filtername = '7UChoice';
        excludedsubs = {'104' '114' '117' '118' '120' '122'};
    case 2
        filtername = 'GenerousOnly';
        excludedsubs = {'104' '118' '120' '123' '124' '137' '149' '107' '108'...
                        '109' '113' '121' '122' '125' '129' '131' '133' ...
                        '134' '136' '138' '139' '153' '157' '158' '159' '160'};
    case 3
        filtername = 'Selfish';
        excludedsubs = {'103', '105' '106' '111' '114' '115' '116' '119' '126' ...
                        '128' '130' '132' '135' '140' '141' '142' '143'...
                         '144' '145' '150' '151' '152' '154' '161' '162'};
    case 4
        filtername = 'Selfish4COnly';
        excludedsubs = {'103', '105' '106' '111' '114' '115' '116' '119' '126' ...
                        '128' '130' '132' '135' '140' '141' '142' '143'...
                         '144' '145' '150' '151' '152' '154' '161' '162' '104' ...
                         '118' '120' '123' '124' '137' '149'};
    case 5
        filtername = 'no138';
        excludedsubs = {'138'};
    otherwise
        filtername = '';
        excludedsubs = {};
end

switch xvar
    case 1  % Explain in detail (e.g. health weight change estimated from DDM - link to model)
        xname = 'HealthWeightChange_HvN';
        varfile = 'HealthWeightChange_HvN.mat'; % need to create...
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
    case 22  % % Loss aversion lambda
        xname = 'DDMThreshNat';
        varfile = 'Thresh_Nat.mat';
    case 23  % % Loss aversion lambda
        xname = 'DDMOtherPrt';
        varfile = 'DDMOther_Ptr.mat';
    case 24  % % Loss aversion lambda
        xname = 'DDMOtherPvN';
        varfile = 'DDMOther_PvN.mat';
    case 25  % % Loss aversion lambda
        xname = 'DDMSelfPrt';
        varfile = 'DDMSelf_Ptr.mat';
    case 26  % % Loss aversion lambda
        xname = 'DDMSelfPvN';
        varfile = 'DDMSelf_PvN.mat';
end

%--- Run calculations ---%

% directory where covariate for correlation is located
load([homepath studyid filesep 'scripts/CorrelationRegressors/' varfile]) % loads all .mat vectors from above ... specify filepath correctly

% Directory where the 1st level contrast images are saved - subject folders will be added within the loop
% Must have a matching entry for each subject in subj_ids!!!!  
con_dir = [homepath studyid filesep 'spmResults/' modelid '/SubjectData_MNI152_8mm/']; % correct this line

% Directory to write the 2nd level correlation results into
% the script will make this directory
out_dir = [homepath studyid filesep 'spmResults/' modelid '/rfxXMvmt/corr_' ...
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
SPM.xCon = spm_FcUtil('Set', cnamecorr, 'T', 'c', [0; 1], SPM.xX.xKXs);
spm_contrasts(SPM);

cd(curr_dir)
% xjview([out_dir filesep 'spmT_0001.img'])