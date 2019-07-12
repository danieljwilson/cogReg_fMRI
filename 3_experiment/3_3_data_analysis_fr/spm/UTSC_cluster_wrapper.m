function UTSC_cluster_wrapper(varargin)
% function UTSC_cluster_wrapper([modelID],[numworkers],[startSubj])
%
% Function for submitting a single-subject GLM analysis to be run
% on the computing cluster at UTSC.
%
% If submitted with no arguments, will prompt the user for the model ID, 
% the number of nodes/workers to use, and the subject ID to start with
%
% Can also be run as a function, submitting the following optional
% arguments:
% modelID (e.g. '1_Preference'): a string identifying the name of the model
% - if calling as a function, modelID is a mandatory argument
% 'NumWorkers', followed by a number, indicating nodes to be used (default:
% 12)
% 'startSubj', followed by starting index of subject: a variable that
% allows you to skip some subjects and start later in the list

    pathtofile = mfilename('fullpath');
    homepath = pathtofile(1:(regexp(pathtofile,'derivatives')-1));

    addpath(fullfile(homepath, 'derivatives','spm','code'))
    
    % if called with arguments, use them, otherwise get them from user
    if isempty(varargin)
        model = input('Which model to run?: ', 's');
        numWorkers = input('How many workers to request?: ');
        startID = input('Which subject to start with?: ');
    else 
        model = varargin{1};
        if length(varargin) > 1
            numWorkers = varargin{2};
        else 
            numWorkers = 12;
        end
        
        if length(varargin) > 2
            startID = varargin{3};
        else
            startID = 1;
        end
    end
    
    if isempty(numWorkers)
        numWorkers = 12;
    end
    
    if isempty(startID)
        startId = 1;
    end
    
    %% get subject info and create submission info for each node
    cd(homepath)
    
%     load(fullfile('derivatives', 'spm','code','subject_list.mat')); % subject IDs for each study

    subject_list; % creates subject list variables

    numSubjects = length(good_subjects.subjects);

    %% schedule tasks
    clu=parcluster('default_jobmanager');

    pjob=createJob(clu,'RestartWorker',logical(1),'NumWorkersRange', [1,  numWorkers]);
    set(pjob,'AdditionalPaths',{...
        fullfile(homepath,'derivatives','spm','code'),...
        '/psyhome/u7/hutchers/matlabextras/', ...
        ['/psyhome/u5/wilso603/Matlab/spm8']})
    
    for s = startID:numSubjects
         eval(['createTask(pjob, @' ...
               ['foodreg_m' model '_analyze2']...
               ', 0 ,{''' all_subjects.subjects{s} '''},''MaximumRetries'',50);'])
    end
    t = get(pjob,'Tasks');
    submit(pjob)

    %% start monitoring job progress
% 
%     results = fetchOutputs(pjob);
% 
%     %% check for errors
%     nErrors = 0;
%     idError = [];
%     for i = 1:length(t)
%         if ~isempty(t(i).ErrorMessage)
%             nErrors = nErrors+1;
%             idError = [idError i];
%         end
%     end
% 
%     %% housecleaning: delete job info if no errors
%     if nErrors == 0    
%         dirname = pjob.Name;
%         pause(2)
%         unix(['rm -r ' homepath 'jobdata/' dirname '*']);
%         fprintf('\nJob successfully completed.\n\n')
%     else
%         fprintf('Errors were detected! History of first error: \n\n')
%         t(idError(1))
%     end
% 
%     finished_jobs = findJob(clu,'State','finished','Username','hutchers');
%     delete(finished_jobs);