function rfx_par(modelid, numworkers)
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


%%%%%%%%
%preliminaries
%%%%%%%%
pathtofile = mfilename('fullpath');

studyid = char(regexprep(regexp(pathtofile,'/[A-Z]{3}\d?/','match'),'/',''));

homepath = pathtofile(1:(regexp(pathtofile,studyid)-1));

%--- SELFISH SUBJECTS ---%

subj_ids = {'103' '104' '106' '107' '109' '112' '118' '120' '122' '123' '124' '125' '127' '133' '134' '136' '137' '139' '143' ...
            ...'103' '105' '108'  ...
            ...'113' '114' ...'115' '116' '117' '118' '119' '120' ...
            ...'121' '122' '123' '124' '125' '126' '127' '128' '129' '130' ...
            };

load([homepath studyid filesep 'results/m' modelid '/m' modelid '_cons.mat'])
%it contains the cnames used below

%specify the # of second level contrasts to be run
ncons=length(cname);
cnametotal = cname;
spm('defaults','FMRI')


%%%%%%%%%%%
% iterate over contrasts to create the SPM.mat files in the appropriate directories
%%%%%%%%%%%


for con=labindex:numworkers:ncons

        %load the template
        load([homepath studyid '/scripts/template.mat'])

        %create a convariable number
        %NOTE: program only works for ncons<=99
        if con<10
            conNum=['000' num2str(con)];
        end
        if con>=10
            conNum=['00' num2str(con)];
        end

        %build the cell with the images
        temp={};
        for subjno = 1:length(subj_ids)
            load([homepath studyid '/results/m' modelid '/' subj_ids{subjno} '/m' modelid '_cons.mat'])
            conNum = searchcell(cname,cnametotal{con});
            
            if ~isempty(conNum)
                conNum = sprintf('%04.0f',conNum);           
                temp{length(temp)+1,1}=[homepath studyid '/results/m' modelid '/' subj_ids{subjno} '/con_' conNum '.img'];
            end
        end

        %load the images into the jobs structure that is loaded w/ template
        jobs{1}.stats{1}.factorial_design.des.t1.scans=temp;

        %create the directory were the template is stored
        mkdir([homepath studyid '/results/m' modelid '/0_rfx_Selfish'])
        cd([homepath studyid '/results/m' modelid '/0_rfx_Selfish'])
        eval(['mkdir ' cname{con}])

        temp2=[homepath studyid '/results/m' modelid '/0_rfx_Selfish/' cname{con}];

        jobs{1}.stats{1}.factorial_design.dir={temp2};


        %run the contrast
        spm_jobman('run', jobs);

        %Estimate the contrast
        clear SPM
        eval(['cd ' temp2])
        eval(['load '  'SPM.mat']);
        SPM=spm_spm(SPM);
        SPM.xCon = spm_FcUtil('Set', cname{con}, 'T', 'c', [1]', SPM.xX.xKXs);
        spm_contrasts(SPM)


end

%--- UNSELFISH SUBJECTS ---%

subj_ids = {'105' '108' '111' '113' '114' '115' '116' '119' '121' '126' '128' '129' '130' '131' '132' '135' '138' '140' '141' '142' ...
            ...'121' '122' '123' '124' '125' '126' '127' '128' '129' '130' ...
            };

load([homepath studyid filesep 'results/m' modelid '/m' modelid '_cons.mat'])
%it contains the cnames used below

%specify the # of second level contrasts to be run
ncons=length(cname);
cnametotal = cname;
spm('defaults','FMRI')


%%%%%%%%%%%
% iterate over contrasts to create the SPM.mat files in the appropriate directories
%%%%%%%%%%%


for con=labindex:numworkers:ncons

        %load the template
        load([homepath studyid '/scripts/template.mat'])

        %create a convariable number
        %NOTE: program only works for ncons<=99
        if con<10
            conNum=['000' num2str(con)];
        end
        if con>=10
            conNum=['00' num2str(con)];
        end

        %build the cell with the images
        temp={};
        for subjno = 1:length(subj_ids)
            load([homepath studyid '/results/m' modelid '/' subj_ids{subjno} '/m' modelid '_cons.mat'])
            conNum = searchcell(cname,cnametotal{con});
            
            if ~isempty(conNum)
                conNum = sprintf('%04.0f',conNum);           
                temp{length(temp)+1,1}=[homepath studyid '/results/m' modelid '/' subj_ids{subjno} '/con_' conNum '.img'];
            end
        end

        %load the images into the jobs structure that is loaded w/ template
        jobs{1}.stats{1}.factorial_design.des.t1.scans=temp;


        %create the directory were the template is stored
        mkdir([homepath studyid '/results/m' modelid '/0_rfx_Unselfish'])
        cd([homepath studyid '/results/m' modelid '/0_rfx_Unselfish'])
        eval(['mkdir ' cname{con}])

        temp2=[homepath studyid '/results/m' modelid '/0_rfx_Unselfish/' cname{con}];

        jobs{1}.stats{1}.factorial_design.dir={temp2};


        %run the contrast
        spm_jobman('run', jobs);

        %Estimate the contrast
        clear SPM
        eval(['cd ' temp2])
        eval(['load '  'SPM.mat']);
        SPM=spm_spm(SPM);
        SPM.xCon = spm_FcUtil('Set', cname{con}, 'T', 'c', [1]', SPM.xX.xKXs);
        spm_contrasts(SPM)


end

%--- ALL SUBJECTS ---%

subj_ids = {            '103' '104' '105' '106' '107' '108' '109'   ...
            '111' '112' '113' '114' '115' '116'       '118' '119' '120' ...
            '121' '122' '123' '124' '125' '126' '127' '128' '129' '130' ...
            '131' '132' '133' '134' '135' '136' '137' '138' '139' '140' ...
            '141' '142' '143' ...
            };

load([homepath studyid filesep 'results/m' modelid '/m' modelid '_cons.mat'])
%it contains the cnames used below

%specify the # of second level contrasts to be run
ncons=length(cname);
cnametotal = cname;
spm('defaults','FMRI')


%%%%%%%%%%%
% iterate over contrasts to create the SPM.mat files in the appropriate directories
%%%%%%%%%%%


for con=labindex:numworkers:ncons

        %load the template
        load([homepath studyid '/scripts/template.mat'])

        %create a convariable number
        %NOTE: program only works for ncons<=99
        if con<10
            conNum=['000' num2str(con)];
        end
        if con>=10
            conNum=['00' num2str(con)];
        end

        %build the cell with the images
        temp={};
        for subjno = 1:length(subj_ids)
            load([homepath studyid '/results/m' modelid '/' subj_ids{subjno} '/m' modelid '_cons.mat'])
            conNum = searchcell(cname,cnametotal{con});
            
            if ~isempty(conNum)
                conNum = sprintf('%04.0f',conNum);           
                temp{length(temp)+1,1}=[homepath studyid '/results/m' modelid '/' subj_ids{subjno} '/con_' conNum '.img'];
            end
        end

        %load the images into the jobs structure that is loaded w/ template
        jobs{1}.stats{1}.factorial_design.des.t1.scans=temp;


        %create the directory were the template is stored
        mkdir([homepath studyid '/results/m' modelid '/0_rfx_All'])
        cd([homepath studyid '/results/m' modelid '/0_rfx_All'])
        eval(['mkdir ' cname{con}])

        temp2=[homepath studyid '/results/m' modelid '/0_rfx_All/' cname{con}];

        jobs{1}.stats{1}.factorial_design.dir={temp2};


        %run the contrast
        spm_jobman('run', jobs);

        %Estimate the contrast
        clear SPM
        eval(['cd ' temp2])
        eval(['load '  'SPM.mat']);
        SPM=spm_spm(SPM);
        SPM.xCon = spm_FcUtil('Set', cname{con}, 'T', 'c', [1]', SPM.xX.xKXs);
        spm_contrasts(SPM)


end

%--- UNSELFISH VS. SELFISH SUBJECTS ---%

subj_ids1 = {'103' '104' '106' '107' '109' '112'       '118' '120' '122' ...
             '123' '124' '125' '127' '133' '134' '136' '137' '139' '143' ...
            };
        
subj_ids2 = {'105' '108' '111' '113' '114' '115' '116' '119' '121' '126' ...
            '128' '129' '130' '131' '132' '135' '138' '140' '141' '142' ...
            };
        
        

load([homepath studyid filesep 'results/m' modelid '/m' modelid '_cons.mat'])
%it contains the cnames used below

%specify the # of second level contrasts to be run
ncons=length(cname);
cnametotal = cname;
spm('defaults','FMRI')


%%%%%%%%%%%
% iterate over contrasts to create the SPM.mat files in the appropriate directories
%%%%%%%%%%%


for con=labindex:numworkers:ncons

        %load the template
        load([homepath studyid '/scripts/template2.mat'])

        %create a convariable number
        %NOTE: program only works for ncons<=99
        if con<10
            conNum=['000' num2str(con)];
        end
        if con>=10
            conNum=['00' num2str(con)];
        end

        %build the cell with the images
        temp={};
        for subjno = 1:length(subj_ids1)
            load([homepath studyid '/results/m' modelid '/' subj_ids1{subjno} '/m' modelid '_cons.mat'])
            conNum = searchcell(cname,cnametotal{con});
            
            if ~isempty(conNum)
                conNum = sprintf('%04.0f',conNum);           
                temp{length(temp)+1,1}=[homepath studyid '/results/m' modelid '/' subj_ids1{subjno} '/con_' conNum '.img'];
            end
        end

        %load the images into the jobs structure that is loaded w/ template
        jobs{1}.stats{1}.factorial_design.des.t2.scans1=temp;

        temp={};
        for subjno = 1:length(subj_ids2)
            load([homepath studyid '/results/m' modelid '/' subj_ids2{subjno} '/m' modelid '_cons.mat'])
            conNum = searchcell(cname,cnametotal{con});
            
            if ~isempty(conNum)
                conNum = sprintf('%04.0f',conNum);           
                temp{length(temp)+1,1}=[homepath studyid '/results/m' modelid '/' subj_ids2{subjno} '/con_' conNum '.img'];
            end
        end

        %load the images into the jobs structure that is loaded w/ template
        jobs{1}.stats{1}.factorial_design.des.t2.scans2=temp;

        %create the directory were the template is stored
        mkdir([homepath studyid '/results/m' modelid '/0_rfx_UvS'])
        cd([homepath studyid '/results/m' modelid '/0_rfx_UvS'])
        eval(['mkdir ' cname{con}])

        temp2=[homepath studyid '/results/m' modelid '/0_rfx_UvS/' cname{con}];

        jobs{1}.stats{1}.factorial_design.dir={temp2};


%         %run the contrast
        spm_jobman('run', jobs);

        %Estimate the contrast
        clear SPM
        eval(['cd ' temp2])
        eval(['load '  'SPM.mat']);
        SPM=spm_spm(SPM);
        SPM.xCon = spm_FcUtil('Set', cname{con}, 'T', 'c', [1 -1]', SPM.xX.xKXs);
        spm_contrasts(SPM)


end