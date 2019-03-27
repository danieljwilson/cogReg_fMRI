function [c cname] = par_contrast(subj_ids)
% Project: Goal value regulation
%
% Script: Generate contrasts. 
%
% Author: Cendri Hutcherson
%
% Date: 9.5.2008%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% NOTE: Some things to be careful about
% - The commands below change the SPM matrix by adding information about the contrasts
% - If want to add a second round of contrasts, after having already processed some, need to start
%   by numbering them index=#exising + 1.
% - Also, unclear if can just rerun an "enlarged" script to rewrite the old contrasts
%
%
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    pathtofile = mfilename('fullpath');
    
    studyid = char(regexprep(regexp(pathtofile,'/FoodRegFMRI/','match'),'/',''));

    homepath = pathtofile(1:(regexp(pathtofile,studyid)-1));
    
    modelid = pathtofile((regexp(pathtofile,'par_m','once')+5):end);
    
%     subj_ids = {'103' '104' '105' '106' '107' '108' '109'  ...
%                 '111' '112' '113' '114'... '115' '116' '117' '118' '119' '120' ...
%                 ...'121' '122' '123' '124' '125' '126' '127' '128' '129' '130' ...
%                 ...'131' '132' '133' '134' '135' '136' '137' '138' '139' '140' ...
%                 };
    clear c*;

    spm('defaults','FMRI')


    % 
    % DONE: '101' '102' '103' '104' '105' '106' '107' '108'
    %To be done:     

    for subjno = 1:length(subj_ids)

        cd([homepath studyid filesep 'results/m' modelid '/' subj_ids{subjno} ])


        load SPM;
        clear c*;
        % now estimate contrasts

        c{1}       = zeros(1,length(SPM.xX.name));
        c{1}(searchcell(SPM.xX.name,'Natural\*','contains')) = 1;
        cname{1}='Natural';


        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'NaturalxPreference','contains')) = 1;
        cname{cnum}='Natural-Preference';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'DecreaseDesire\*','contains')) = 1;
        cname{cnum}='Decrease';
        
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'DecreaseDesirexPreference','contains')) = 1;
        cname{cnum}='Decrease-Preference';
        
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'HealthFocus','contains')) = 1;
        cname{cnum}='Health';
        
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'HealthFocusxPreference','contains')) = 1;
        cname{cnum}='Health-Preference';


        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Decrease')} - c{searchcell(cname,'Natural')}; 
        cname{cnum}='Decrease_v_Natural';


        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Health')} - c{searchcell(cname,'Natural')}; 
        cname{cnum}='Health_v_Natural';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Health-Preference')} + c{searchcell(cname,'Natural-Preference')} + c{searchcell(cname,'Decrease-Preference')}; 
        cname{cnum}='All-Preference';


        % make contrasts
        for j=1:length(c)

            cons(j)   = spm_FcUtil('Set',cname{j},'T','c',c{j}(:),SPM.xX.xKXs);

        end;


       SPM.xCon = [cons];

        %make contrasts
        spm_contrasts(SPM);

        %save SPM for this subject
        save SPM SPM;
        save(['m' modelid '_cons.mat'],'c','cname')
        
    end

