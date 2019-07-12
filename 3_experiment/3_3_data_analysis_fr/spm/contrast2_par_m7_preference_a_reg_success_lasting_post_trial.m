function [c cname] = par_contrast(subj_ids, preproc_version)
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
    
    studyid = 'food_reg_fmri_01'; %char(regexprep(regexp(pathtofile,'/FoodRegFMRI/','match'),'/',''));

    homepath = pathtofile(1:(regexp(pathtofile,studyid)-1));
    
    modelid = pathtofile((regexp(pathtofile,'par_m','once')+5):end);
    
%     subj_ids = {'103' '104' '105' '106' '107' '108' '109'  ...
%                 '111' '112' '113' '114'... '115' '116' '117' '118' '119' '120' ...
%                 ...'121' '122' '123' '124' '125' '126' '127' '128' '129' '130' ...
%                 ...'131' '132' '133' '134' '135' '136' '137' '138' '139' '140' ...
%                 };
    clear c*;

    spm('defaults','FMRI')

   

    for subjno = 1:length(subj_ids)
        current = ['processing subject ', subj_ids{subjno}, '...'];
        display(current)

        cd(fullfile(homepath, studyid, 'analysis', 'SPM', modelid, preproc_version, subj_ids{subjno} ))


        load SPM;
        clear c*;
        % now estimate contrasts

        c{1}       = zeros(1,length(SPM.xX.name));
        c{1}(searchcell(SPM.xX.name,'Natural\*','contains')) = 1;  % identifying onset indicators
        c{1} = filterSessions(SPM, c{1}, subj_ids{subjno});
        cname{1}='Natural';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'NaturalxPreference','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Natural-Preference';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'Naturalxreg_success_lasting','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Natural-reg_success_lasting';
         
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'DecreaseDesire\*','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Decrease';

        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'DecreaseDesirexPreference','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Decrease-Preference';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'DecreaseDesirexreg_success_lasting','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Decrease-reg_success_lasting';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'HealthFocus_post','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Health';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'HealthFocus_postxPreference','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Health-Preference';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'HealthFocus_postxreg_success_lasting','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Health-reg_success_lasting';

        
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Decrease')} - c{searchcell(cname,'Natural')}; 
        cname{cnum}='Decrease_v_Natural';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Decrease')} - c{searchcell(cname,'Health')};
        cname{cnum}='Decrease_v_Health';

        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Health')} - c{searchcell(cname,'Natural')};
        cname{cnum}='Health_v_Natural';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Health')} + c{searchcell(cname,'Decrease')} - 2*c{searchcell(cname,'Natural')}; 
        cname{cnum}='Reg_v_Nat';
        
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Health-Preference')} + c{searchcell(cname,'Natural-Preference')} + c{searchcell(cname,'Decrease-Preference')}; 
        cname{cnum}='All-Preference';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Health-reg_success_lasting')} + c{searchcell(cname,'Natural-reg_success_lasting')} + c{searchcell(cname,'Decrease-reg_success_lasting')}; 
        cname{cnum}='All-reg_success_lasting';
        
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Decrease-reg_success_lasting')} - c{searchcell(cname,'Natural-reg_success_lasting')}; 
        cname{cnum}='Decrease_v_Natural_reg_success_lasting';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Decrease-reg_success_lasting')} - c{searchcell(cname,'Health-reg_success_lasting')}; 
        cname{cnum}='Decrease_v_Health_reg_success_lasting';

        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Health-reg_success_lasting')} - c{searchcell(cname,'Natural-reg_success_lasting')}; 
        cname{cnum}='Health_v_Natural_reg_success_lasting';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Health-reg_success_lasting')} + c{searchcell(cname,'Decrease-reg_success_lasting')} - 2*c{searchcell(cname,'Natural-reg_success_lasting')}; 
        cname{cnum}='Reg_reg_success_lasting_v_Natural_reg_success_lasting';
        
        % additional contrasts
        
        c{1}       = zeros(1,length(SPM.xX.name));
        c{1}(searchcell(SPM.xX.name,'Natural_post\*','contains')) = 1;  % identifying onset indicators
        c{1} = filterSessions(SPM, c{1}, subj_ids{subjno});
        cname{1}='Natural_post';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'Natural_postxPreference','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Natural_post-Preference';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'Natural_postxreg_success_lasting','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Natural_post-reg_success_lasting';
         
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'DecreaseDesire_post\*','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Decrease_post';

        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'DecreaseDesire_postxPreference','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Decrease_post-Preference';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'DecreaseDesire_postxreg_success_lasting','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Decrease_post-reg_success_lasting';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'HealthFocus_post','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Health_post';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'HealthFocus_postxPreference','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Health_post-Preference';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}(searchcell(SPM.xX.name,'HealthFocus_postxreg_success_lasting','contains')) = 1;
        c{cnum} = filterSessions(SPM, c{cnum}, subj_ids{subjno});
        cname{cnum}='Health_post-reg_success_lasting';

        
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Decrease_post')} - c{searchcell(cname,'Natural_post')}; 
        cname{cnum}='Decrease_post_v_Natural_post';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Decrease_post')} - c{searchcell(cname,'Health_post')};
        cname{cnum}='Decrease_post_v_Health_post';

        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Health_post')} - c{searchcell(cname,'Natural_post')};
        cname{cnum}='Health_post_v_Natural_post';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Health_post')} + c{searchcell(cname,'Decrease_post')} - 2*c{searchcell(cname,'Natural_post')}; 
        cname{cnum}='Reg_post_v_Nat_post';
        
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Health_post-Preference')} + c{searchcell(cname,'Natural_post-Preference')} + c{searchcell(cname,'Decrease_post-Preference')}; 
        cname{cnum}='All_post-Preference';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Health_post-reg_success_lasting')} + c{searchcell(cname,'Natural_post-reg_success_lasting')} + c{searchcell(cname,'Decrease_post-reg_success_lasting')}; 
        cname{cnum}='All_post-reg_success_lasting';
        
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Decrease_post-reg_success_lasting')} - c{searchcell(cname,'Natural_post-reg_success_lasting')}; 
        cname{cnum}='Decrease_post_v_Natural_post_reg_success_lasting';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Decrease_post-reg_success_lasting')} - c{searchcell(cname,'Health_post-reg_success_lasting')}; 
        cname{cnum}='Decrease_post_v_Health_post_reg_success_lasting';

        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Health_post-reg_success_lasting')} - c{searchcell(cname,'Natural_post-reg_success_lasting')}; 
        cname{cnum}='Health_post_v_Natural_post_reg_success_lasting';
        
        cnum = length(c)+1;
        c{cnum}    = zeros(1,length(SPM.xX.name));
        c{cnum}    = c{searchcell(cname,'Health_post-reg_success_lasting')} + c{searchcell(cname,'Decrease_post-reg_success_lasting')} - 2*c{searchcell(cname,'Natural_post-reg_success_lasting')}; 
        cname{cnum}='Reg_post_reg_success_lasting_v_Natural_post_reg_success_lasting';
        
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
    
    % filter runs based on movement
    function c = filterSessions(SPM, c, subj_no)
        
        switch subj_no
            case '104'
                runsToFilter = [4,6,7];
            case '106'
                runsToFilter = [5,7,9];
            case  '107'
                runsToFilter = [7,8];
            case  '115'
                runsToFilter = [1,2,8];
            case  '116'
                runsToFilter = [3,6,7];
            case  '118'
                runsToFilter = [4,5,9];
            case  '119'
                runsToFilter = [8];
            case  '121'
                runsToFilter = [2];
            case  '123'
                runsToFilter = [7,8,9];
            case  '125'
                runsToFilter = [1,2,3];
            case  '134'
                runsToFilter = [7,8,9];
            case  '137'
                runsToFilter = [6,7];
            case  '139'
                runsToFilter = [1,3,4];
            case  '140'
                runsToFilter = [8];
            case  '142'
                runsToFilter = [5];
            case  '144'
                runsToFilter = [5,8];
            case  '145'
                runsToFilter = [5,7];
            case  '146'
                runsToFilter = [4,7,8];
            case '147'
                runsToFilter = [1,4];
            case  '150'
                runsToFilter = [2,3,4];
            case  '152'
                runsToFilter = [6,7];
            case  '153'
                runsToFilter = [5,8];
            case  '155'
                runsToFilter = [9];
            case  '156'
                runsToFilter = [4,6,8];
            case '164'
                runsToFilter = [7,9];
            otherwise
                runsToFilter = [];
        end
        
        % add a filter for trials within runs that had a pre-liking of 0
        if ~isempty(runsToFilter)
            for r = 1:length(runsToFilter)
                c(searchcell(SPM.xX.name,['Sn\(' num2str(runsToFilter(r)) '\)'], 'contains')) = 0;
            end          
        end


