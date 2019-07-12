function cnum = rfx_par(modelid,conname,subj_ids,preproc_version)
%%%%%%%%%%%%%%
%
% This script implements the second level analysis for the contrasts in Model 1
%						fmri BDM food partner
% Antonio Rangel
% Sep 3, 2007
%
% NOTE: 1. It requires the use of template.m created in matlab and stored in my ref_professional folder
%       2. Need to create directory ...results/model_x/_rfx by hand
%
%
%
%
%
%
%%%%%%%%%%%%%%%%

%try
%%%%%%%%
%preliminaries
%%%%%%%%
pathtofile = mfilename('fullpath');

studyid = 'food_reg_fmri_01';

homepath = pathtofile(1:(regexp(pathtofile,studyid)-1));


% 'Subject_Data'
% SubjectData_icaAroma_nonAggr_6mm
% SubjectData_MNI152_8mm
analysis_folder = preproc_version;     % specifies the input folder

output_folder = subj_ids.name;     % specifies the output folder

%--- Strict movement thresholds ---%
% subj_ids = { '103' '109' '110'   ... '101' '102' '104' '105'       '107' '108'
%            '111' '112' '113'  '118' '119' '120'...'114'             '117'
%           '121' '122' '123' '124' '125'  ...  '126'             '129' '130'
%             '131' '132' '133' '134'       '136' '137' '138' '139' '140' ... 
%             '141' '142' '143' '144' '145' '146' '147' '148' '149' '150' ... 
%             '151' '152' '153' '154'       '156' ... '157' '158' '159' '160' ...
%             '216' '234'
%            };
% Excluded subjects:
% 106,125,127,115,116,134,135,155 - head motion
% 128 - said NO to every offer
% 148 - sad NO to 92% of offers


load(fullfile(homepath, studyid, 'analysis','SPM', modelid, analysis_folder,['m' modelid '_cons.mat']))
%it contains the cnames used below

%specify the # of second level contrasts to be run
ncons=length(conname);
cnametotal = cname;
spm('defaults','fmri')
spm_jobman('initcfg')

for con=1:ncons
        cnum = searchcell(cnametotal,conname{con});
        load(fullfile(homepath, studyid, 'code', 'spm', 'template8.mat'))
        
        %build the cell with the images
        temp={};
        for subjno = 1:length(subj_ids.subjects)
            load(fullfile(homepath, studyid, 'analysis', 'SPM', modelid, analysis_folder, ...
                subj_ids.subjects{subjno}, ['m' modelid '_cons.mat']))
            conNum = searchcell(cname,cnametotal{cnum});
            
            if ~isempty(conNum)
                conNum = sprintf('%04.0f',conNum);           
                temp{length(temp)+1,1}=fullfile(homepath, studyid,...
                    'analysis','SPM', modelid, analysis_folder,...
                    subj_ids.subjects{subjno}, [ 'con_' conNum '.img']);
            end
        end

        %load the images into the jobs structure that is loaded w/ template
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans=temp;

        %create the directory were the template is stored
        conDir = fullfile(homepath, studyid, 'analysis','SPM', modelid, 'groupResults', analysis_folder, output_folder);
        mkdir(conDir)
        cd(conDir)
        
        if exist(cnametotal{cnum},'dir')
            rmdir([cnametotal{cnum}],'s')
        end
        
        mkdir(cnametotal{cnum})

        temp2=fullfile(conDir, cnametotal{cnum});

        matlabbatch{1}.spm.stats.factorial_design.dir={temp2};
        save([temp2 '/batchfile.mat'],'matlabbatch')


        %run the contrast
        spm_jobman('run', matlabbatch);

        %Estimate the contrast
        clear SPM
        cd(temp2)
        load SPM.mat;
        SPM=spm_spm(SPM);
        SPM.xCon = spm_FcUtil('Set', cnametotal{cnum}, 'T', 'c', [1]', SPM.xX.xKXs);
        
        spm_contrasts(SPM)

end




%--- MALE VS. FEMALE SUBJECTS ---%

% subj_ids1 = {'101' '105' '107' '108' '109' '110'  '114'  '117'  ...'111' '115'
%              '120' '123' '124' '126' '129' '130' '131' '133' '137'  '139' '140' ... 
%              '141' '144' '145' '146'                  '149' ...'150' ... 
%             ...'151' '152' '153'              '157' '158' '159' '160' ...'154'
%             ...'161'   ... '163' '162'
%             }; % Male
%         
% subj_ids2 = {'102' '103' '104' '112' '113' '118' '119' '121' '122' '132' ...
%              '136' '138' '142' '143' '145' '147' '148' '150'... '149' '150' ... 
%             ...'151' '152' '153'              '157' '158' '159' '160' ...'154'
%             ...'161'   ... '163' '162'
%             }; % Female
%         
% % Excluded subjects:
% % 106,125,127, - head motion
% % 128 - said NO to every offer
% % 111, 115, 116, 134,135 - doubtful head motion? some scans excluded
% 
% % BETWEEN GROUPS T-TEST. Male vs. Female
% for con=1:ncons
%         cnum = searchcell(cnametotal,conname{con});
%         load([homepath studyid '/scripts/template8_2sample.mat'])
%         
%         %build the cell with the images
%         temp={};
%         for subjno = 1:length(subj_ids1)
%             load([homepath studyid '/spmResults/' modelid '/SubjectData/' ...
%                 subj_ids1{subjno} '/' modelid '_cons.mat'])
%             conNum = searchcell(cname,cnametotal{cnum});
%             
%             if ~isempty(conNum)
%                 conNum = sprintf('%04.0f',conNum);           
%                 temp{length(temp)+1,1}=[homepath studyid '/spmResults/' modelid ...
%                     '/SubjectData/' subj_ids1{subjno} '/con_' conNum '.img'];
%             end
%         end
% 
%         %load the images into the jobs structure that is loaded w/ template
%         matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1=temp;
%         
%         temp={};
%         for subjno = 1:length(subj_ids2)
%             load([homepath studyid '/spmResults/' modelid '/SubjectData/' ...
%                 subj_ids2{subjno} '/' modelid '_cons.mat'])
%             conNum = searchcell(cname,cnametotal{cnum});
%             
%             if ~isempty(conNum)
%                 conNum = sprintf('%04.0f',conNum);           
%                 temp{length(temp)+1,1}=[homepath studyid '/spmResults/' modelid ...
%                     '/SubjectData/' subj_ids2{subjno} '/con_' conNum '.img'];
%             end
%         end
% 
%         %load the images into the jobs structure that is loaded w/ template
%         matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2=temp;
%         
% 
%         %create the directory were the template is stored
%         mkdir([homepath studyid '/spmResults/' modelid '/rfx_MvF'])
%         cd([homepath studyid '/spmResults/' modelid '/rfx_MvF'])
%         
%         if exist(cnametotal{cnum},'dir')
%             rmdir([cnametotal{cnum}],'s')
%         end
%         
%         mkdir(cnametotal{cnum})
% 
%         temp2=[homepath studyid '/spmResults/' modelid '/rfx_MvF/' cnametotal{cnum}];
% 
%         matlabbatch{1}.spm.stats.factorial_design.dir={temp2};
%         save([temp2 '/batchfile.mat'],'matlabbatch')
% 
% 
%         %run the contrast
%         spm_jobman('run', matlabbatch);
% 
%         %Estimate the contrast
%         clear SPM
%         cd(temp2)
%         load SPM.mat;
%         SPM=spm_spm(SPM);
%         SPM.xCon = spm_FcUtil('Set',  cnametotal{cnum}, 'T', 'c', [1 -1]', SPM.xX.xKXs);
%         
%         spm_contrasts(SPM)
% 
% end



%--- SELFISH SUBJECTS ---%
% 
% subj_ids = {'101','102','103' '104' '106' '107' '109' '111' '118' '120' '122' '123'...
%             '124' '125' '133' '134' '136' '137' '139' '143' '144' '149' '152'...
%             '153' '158' '160' '161' ...
%             };
% 
% 
% 
% %%%%%%%%%%%
% % iterate over contrasts to create the SPM.mat files in the appropriate directories
% %%%%%%%%%%%
% 
% 
% for con=1:ncons
% 
%         cnum = searchcell(cnametotal,conname{con});
%         %load the template
%         load([homepath studyid '/scripts/template.mat'])
% 
%         %build the cell with the images
%         temp={};
%         for subjno = 1:length(subj_ids)
%             load([homepath studyid '/results/' modelid '/' subj_ids{subjno} '/' modelid '_cons.mat'])
%             conNum = searchcell(cname,cnametotal{cnum});
%             
%             if ~isempty(conNum)
%                 conNum = sprintf('%04.0f',conNum);          
%                 temp{length(temp)+1,1}=[homepath studyid '/results/' modelid '/' subj_ids{subjno} '/con_' conNum '.img'];
%             end
%         end
% 
%         %load the images into the jobs structure that is loaded w/ template
%         jobs{1}.stats{1}.factorial_design.des.t1.scans=temp;
% 
%         %create the directory were the template is stored
%         mkdir([homepath studyid '/results/' modelid '/0_rfx_Selfish'])
%         cd([homepath studyid '/results/' modelid '/0_rfx_Selfish'])
%         eval(['mkdir ' cnametotal{cnum}])
% 
%         temp2=[homepath studyid '/results/' modelid '/0_rfx_Selfish/' cnametotal{cnum}];
% 
%         jobs{1}.stats{1}.factorial_design.dir={temp2};
% 
% 
%         %run the contrast
%         spm_jobman('run', jobs);
% 
%         %Estimate the contrast
%         clear SPM
%         eval(['cd ' temp2])
%         eval(['load '  'SPM.mat']);
%         
%         SPM=spm_spm(SPM);
%         SPM.xCon = spm_FcUtil('Set', cname{con}, 'T', 'c', [1]', SPM.xX.xKXs);
% 
%         spm_contrasts(SPM)
% 
% end
% 
% %--- UNSELFISH SUBJECTS ---%
% 
% subj_ids = {'105' '108' '113' '114' '115' '116' '119' '121' '126' '128' '129' ...
%             '130' '131' '132' '135' '140' '141' '142' '145' '150' '151' ...'138'
%              '157' '159'  ...'154' '162'
%             };
% 
% 
% %%%%%%%%%%%
% % iterate over contrasts to create the SPM.mat files in the appropriate directories
% %%%%%%%%%%%
% 
% 
% for con=1:ncons
%         cnum = searchcell(cnametotal,conname{con});
%         %load the template
%         load([homepath studyid '/scripts/template.mat'])
% 
%         %build the cell with the images
%         temp={};
%         for subjno = 1:length(subj_ids)
%             load([homepath studyid '/results/' modelid '/' subj_ids{subjno} '/' modelid '_cons.mat'])
%             conNum = searchcell(cname,cnametotal{cnum});
%             
%             if ~isempty(conNum)
%                 conNum = sprintf('%04.0f',conNum);           
%                 temp{length(temp)+1,1}=[homepath studyid '/results/' modelid '/' subj_ids{subjno} '/con_' conNum '.img'];
%             end
%         end
% 
%         %load the images into the jobs structure that is loaded w/ template
%         jobs{1}.stats{1}.factorial_design.des.t1.scans=temp;
% 
%         %create the directory were the template is stored
%         mkdir([homepath studyid '/results/' modelid '/0_rfx_Unselfish'])
%         cd([homepath studyid '/results/' modelid '/0_rfx_Unselfish'])
%         eval(['mkdir ' cnametotal{cnum}])
% 
%         temp2=[homepath studyid '/results/' modelid '/0_rfx_Unselfish/' cnametotal{cnum}];
% 
%         jobs{1}.stats{1}.factorial_design.dir={temp2};
% 
% 
%         %run the contrast
%         spm_jobman('run', jobs);
% 
%         %Estimate the contrast
%         clear SPM
%         eval(['cd ' temp2])
% 
%         eval(['load '  'SPM.mat']);
%         
%         SPM=spm_spm(SPM);
%         SPM.xCon = spm_FcUtil('Set', cname{con}, 'T', 'c', [1]', SPM.xX.xKXs);
%         
%         spm_contrasts(SPM)
% end
% 
% %--- UNSELFISH VS. SELFISH SUBJECTS ---%
% 
% subj_ids1 = {'105' '108' '113' '114' '115' '116' '119' '121' '126' '128' '129' ...
%              '130' '131' '132' '135' '140' '141' '142' '145' '150' '151' ...'138'
%               '157' '159'   ... '163' '154' '162'
%             }; % Unselfish
%         
% subj_ids2 = {'103' '104' '106' '107' '109' '111' '118' '120' '122' '123'...
%              '124' '125' '133' '134' '136' '137' '139' '143' '144' '149' '152'...
%              '153' '158' '160' '161' ...
%             }; % Selfish
%         
%     
% 
% 
% %%%%%%%%%%%
% % iterate over contrasts to create the SPM.mat files in the appropriate directories
% %%%%%%%%%%%
% 
% % BETWEEN GROUPS T-TEST!!! Hi Damian!
% for con=1:ncons
%         cnum = searchcell(cnametotal,conname{con});
%         
%         %load the template
%         load([homepath studyid '/scripts/template2.mat'])
% 
% 
%         %build the cell with the images
%         temp={};
%         for subjno = 1:length(subj_ids1)
%             load([homepath studyid '/results/' modelid '/' subj_ids1{subjno} '/' modelid '_cons.mat'])
%             conNum = searchcell(cname,cnametotal{cnum});
%             
%             if ~isempty(conNum)
%                 conNum = sprintf('%04.0f',conNum);           
%                 temp{length(temp)+1,1}=[homepath studyid '/results/' modelid '/' subj_ids1{subjno} '/con_' conNum '.img'];
%             end
%             
%         end
% 
%         %load the images into the jobs structure that is loaded w/ template
%         jobs{1}.stats{1}.factorial_design.des.t2.scans1=temp;
% 
%         temp={};
%         for subjno = 1:length(subj_ids2)
%             load([homepath studyid '/results/' modelid '/' subj_ids2{subjno} '/' modelid '_cons.mat'])
%             conNum = searchcell(cname,cnametotal{cnum});
%             
%             if ~isempty(conNum)
%                 conNum = sprintf('%04.0f',conNum);           
%                 temp{length(temp)+1,1}=[homepath studyid '/results/' modelid '/' subj_ids2{subjno} '/con_' conNum '.img'];
%             end
%         end
% 
%         %load the images into the jobs structure that is loaded w/ template
%         jobs{1}.stats{1}.factorial_design.des.t2.scans2=temp;
% 
%         %create the directory were the template is stored
%         mkdir([homepath studyid '/results/' modelid '/0_rfx_UvS'])
%         cd([homepath studyid '/results/' modelid '/0_rfx_UvS'])
%         eval(['mkdir ' cnametotal{cnum}])
% 
%         temp2=[homepath studyid '/results/' modelid '/0_rfx_UvS/' cnametotal{cnum}];
% 
%         jobs{1}.stats{1}.factorial_design.dir={temp2};
% 
% 
% %         %run the contrast
%         spm_jobman('run', jobs);
% 
%         %Estimate the contrast
%         clear SPM
%         eval(['cd ' temp2])
%         eval(['load '  'SPM.mat']);
%         SPM=spm_spm(SPM);
%         SPM.xCon = spm_FcUtil('Set', cname{con}, 'T', 'c', [1 -1]', SPM.xX.xKXs);
%         
%         spm_contrasts(SPM)
% 
% end

% %--- ALL SUBJECTS ---%
% 
% subj_ids = {'101' '102' '103' '104' '105'       '107' '108' '109' '110'   ... 
%             '111' '112' '113' '114' '115' '116' '117' '118' '119' '120'...
%             '121' '122' '123' '124'       '126'             '129' '130' ...
%             '131' '132' '133' '134' '135' '136' '137' '138' '139' '140' ... 
%             '141' '142' '143' '144' '145' '146' '147'       '149' '150' ...'148' ...  ... 
%             ...'151' '152' '153'              '157' '158' '159' '160' ...'154'
%             ...'161'   ... '163' '162'
%             };
% % Excluded subjects:
% % 106,125,127, - head motion
% % 128 - said NO to every offer
% % 148 - said NO to 92% of offers
% % 111, 115, 116, 129, 134,135, 144,  - doubtful head motion? some scans excluded
% 
% 
% load([homepath studyid filesep 'spmResults/' modelid '/' modelid '_cons.mat'])
% %it contains the cnames used below
% 
% %specify the # of second level contrasts to be run
% ncons=length(conname);
% cnametotal = cname;
% spm('defaults','fmri')
% spm_jobman('initcfg')
% 
% for con=1:ncons
%         cnum = searchcell(cnametotal,conname{con});
%         load([homepath studyid '/scripts/template8.mat'])
%         
%         %build the cell with the images
%         temp={};
%         for subjno = 1:length(subj_ids)
%             load([homepath studyid '/spmResults/' modelid '/SubjectData/' ...
%                 subj_ids{subjno} '/' modelid '_cons.mat'])
%             conNum = searchcell(cname,cnametotal{cnum});
%             
%             if ~isempty(conNum)
%                 conNum = sprintf('%04.0f',conNum);           
%                 temp{length(temp)+1,1}=[homepath studyid '/spmResults/' modelid ...
%                     '/SubjectData/' subj_ids{subjno} '/con_' conNum '.img'];
%             end
%         end
% 
%         %load the images into the jobs structure that is loaded w/ template
%         matlabbatch{1}.spm.stats.factorial_design.des.t1.scans=temp;
% 
%         %create the directory were the template is stored
%         mkdir([homepath studyid '/spmResults/' modelid '/rfxAll'])
%         cd([homepath studyid '/spmResults/' modelid '/rfxAll'])
%         
%         if exist(cnametotal{cnum},'dir')
%             rmdir([cnametotal{cnum}],'s')
%         end
%         
%         mkdir(cnametotal{cnum})
% 
%         temp2=[homepath studyid '/spmResults/' modelid '/rfxAll/' cnametotal{cnum}];
% 
%         matlabbatch{1}.spm.stats.factorial_design.dir={temp2};
%         save([temp2 '/batchfile.mat'],'matlabbatch')
% 
% 
%         %run the contrast
%         spm_jobman('run', matlabbatch);
% 
%         %Estimate the contrast
%         clear SPM
%         cd(temp2)
%         load SPM.mat;
%         SPM=spm_spm(SPM);
%         SPM.xCon = spm_FcUtil('Set',  cnametotal{cnum}, 'T', 'c', [1]', SPM.xX.xKXs);
%         
%         spm_contrasts(SPM)
% 
% end