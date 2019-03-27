function preproc(numworkers, subj_ids)
% Project: PEI2 - dissociation of direct and indirect value
% Script: script for preprocessing data
% Author: Antonio Rangel
%          Based on SPM5 scripts from Signe Bray

% Date: 6.11.2007
%
% Revised: 2.2009 by Cendri Hutcherson
%
% NOTE:
% - Code design to work with SPM5 & matlab 7.4
% - Runs with Inter Power Mac
%
%
% NOTES:
% - Code assumes that functional images for all session are in the same directory
% - Code preprocesses all of the sessions together
%
%
%
% STEPS OF PREPROCESSING:
% 1. Slice timing
% 2. Realign
% 3. Coregister functional
% 4. Normalise functional
% 5. Smooth
% 6. Coregister anatomical
% 7. Normalise anatomical
%
%
% NOTE:
%- 
%- Assumed directory structure ...Desktop/PEI/subject/ with two subdirectories:
%  anatomical & functional
% - IMPORTANT: the functional scans for both sessions are in the same directory

% - see spm5 online help for descriptions of the usage of the spm commands
%

%%
numscans = 4;
%%

%%%%%%%%%%%%%%%%%%%%%%%%
% LIST OF SUBJECTS AND PRELIMINARY PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%

%This is the list of subject directory names:
%subj_ids = {'101'};

pathtofile = mfilename('fullpath');

studyid = char(regexprep(regexp(pathtofile,'/[A-Z]{3}\d?/','match'),'/',''));

homepath = pathtofile(1:(regexp(pathtofile,studyid)-1));

%subject to be done:    
%                      
%
%subjects done: 

%These are some SPM initialization parameters:
spm('defaults','FMRI')
global defaults

Template = [homepath 'spm5/templates/EPI.nii']; 
Template_Anatomical = [homepath 'spm5/templates/T1.nii'];


tic % This initializes a Matlab timer to keep track of the running time for the program


for subj=labindex:numworkers:length(subj_ids)     %this loops over subjects to apply the preprocessing steps below to every subject
    
    
    disp(subj)
    
    subject_id=subj_ids{subj};
    cd([homepath studyid '/' subject_id '/functional']) 	% goes to the directory where all the fmri data is located
   
%%   
    %%%%%%%%%%%%%%%%%%%%%
    % CORRECT SLICE TIMING
    % (create af*.* files)
    %%%%%%%%%%%%%%%%%%%%%
    
    % enter some parameters for slicing
    nslices = 45;
    TR = 2.750;
    TA = TR-TR/nslices;
    timing(2) = TR - TA;
    timing(1) = TA / (nslices -1);
	refslice=45;                        %May want to choose the middle slice instead
 	%Caltech Siemens ordering
	if mod(nslices,2)==1
		sliceorder=[1:2:nslices 2:2:nslices-1];
	else
		sliceorder=[2:2:nslices 1:2:nslices-1];
	end;
%%	
	
   
    %load up the necessary files:
    %note that images for ALL sessions are in this directory
    clear P;
 
	file_info = dir('f*.img');
	for i = 1:length(file_info)
	   	P(i,:) = file_info(i).name;
    end
    	
    	
    %run the slicing:
    % NOTES: 
    % - command format: spm_slice_timing(P, Seq, refslice, timing)
   spm_slice_timing(P, sliceorder , refslice, timing);
    

    %%%%%%%%%%%%%%%%%%%%%
    % REALIGN AND RESLICE
    % (create mean functional image)
    % (create rp_*.txt file with estimated motion parameters
    %%%%%%%%%%%%%%%%%%%%%
    
    %load up the necessary files:
    clear P;
    
        subjID = subject_id;
%%
        if isequal(subjID,'999')  
            sessex = 1;
        elseif isequal(subjID,'998')
            sessex = -1;
        else
            sessex = 0;
        end
%%    
    for session=1:numscans
	    file_info = dir(['afrange_-000' num2str(session+2+sessex) '-*.img']); %add for preceding sequences (localizer, MPRAGE)
	    for i = 1:length(file_info)
	   	     P{session}(i,:) = file_info(i).name;
    	end
    end
    
    
    %realign estimate with mostly default parameters:
   spm_realign(P);
    
    %parameters for reslicing:
    % (mask, write all images and mean)
   FlagsB = struct('mask', 1, 'which', 0, 'mean', 1);
    
    %reslice:
   spm_reslice(P, FlagsB);

    
    %%%%%%%%%%%%%%%%%%%%%
    % COREGISTER MEAN REALIGNED `
    % IMAGE TO EPI TEMPLATE
    % output is a transformed header for the functional files
    %%%%%%%%%%%%%%%%%%%%%
    
    
    %load up the necessary files:
    clear P;	
  	count=0;			
    for session = 1:numscans
        file_info = dir(['afrange_-000' num2str(session+2+sessex) '-*.img']); % for each session
        for i = 1:length(file_info)
            P(i+count,:) = file_info(i).name;
        end
        count = count + length(file_info);
    end 
    
    % define some parameters:
    params = defaults.coreg.estimate;
    params.cost_fun = 'ncc';            %use normalized cross correlation when coregistering images of the same type (fnal in this case)
    
    % run the coregistration:
      meanFile_name = ['meanafrange_-000' num2str(3+sessex) '-00003-000003-00.img']; 					
    VF = spm_vol(meanFile_name);
    VG = spm_vol(Template);
    
    
    % NOTE:
    % - below VG is the referencence (or stationalry image) and (VF) is the
    %   source (or moving image)
    x  = spm_coreg(VG,VF,params);
    
    M  = inv(spm_matrix(x));
    MM = zeros(4,4,size(P,1));
    for j=1:size(P,1),
        MM(:,:,j) = spm_get_space(deblank(P(j,:)));
    end;
    for j=1:size(P,1),
        spm_get_space(deblank(P(j,:)), M*MM(:,:,j));
    end;
    MMM = spm_get_space(deblank(meanFile_name));
    spm_get_space(deblank(meanFile_name), M*MMM);
      
    
    %%%%%%%%%%%%%%%%%%%%%
    % NORMALISE FUNCTIONALS:
    % output:
    %  wraf*.* files
    % ***_seg.sn.mat file containing the normalization parameters
    %%%%%%%%%%%%%%%%%%%%%
    
    %set up some normalization parameters:
    defs = defaults.normalise;
    defs.write.vox = [3 3 3];       % This is the acquisition voxel size for the funcational scans
    defs.write.interp=4;
    
    %load up the necessary files:
    clear P;
    clear PP;
    mean_info = dir(meanFile_name); 				
    P = mean_info.name;
    file_info = dir('afrange_*.img'); 	%all sessions and images
    for i = 1:length(file_info)
        PP(i,:) = file_info(i).name;
    end
    
    %name of matrix to store the normalisation parameters
    matname = ['s_1_norm_defs_sn.mat'];    
    
    %estimate the normalization:
    spm_normalise(Template, P, matname, defs.estimate.weight, '',defs.estimate);
 
    %write the normalised images
    spm_write_sn(PP, matname, defs.write);
    
      
    %%%%%%%%%%%%%%%%%%%%%
    % SMOOTH FUNCTIONALS
    % (create swarf*.*)
    %%%%%%%%%%%%%%%%%%%%%
    
    %define some smoothing parameters:
    SmoothWidth = 8; %mm            % This is the FWDH parameter for the smoothing step
    
    %load up the necessary files:
    clear P;
    clear PP;
    
    count=0;
    for session=1:numscans
    	file_info = dir(['wafrange_-000' num2str(session+2+sessex) '-*.img']);
    	for i = 1:length(file_info)
        	P(i+count,:) = file_info(i).name;
    	end
    	count = count + length(file_info);
    end
    
    %smooth:
    n     = size(P,1);
    for i = 1:n
        Q = deblank(P(i,:));
        [pth,nm,xt,vr] = fileparts(deblank(Q));
        U = fullfile(pth,['s' nm xt vr]);
        spm_smooth(Q,U,SmoothWidth);
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%
    % DELETE SOME OF THE UNNECESSARY FUNCTIONAL FILES
    %%%%%%%%%%%%%%%%%%%%%
    
    delete af*.*
    delete waf*.*
        
    %go back to subject directory
    cd ..
   
 

	%%%%%%%%%%%%%%%%%%%%
	% MOVE THE FUNCTIONALS AND THE MOVEMENT REGRESSORS TO THE RIGHT DIRECTORIES
	%%%%%%%%%%%%%%%%%%%%

	cd([homepath studyid]) %go to study dir
   
    eval(['cd ' subject_id]) %go to subject dir
    
    for i = 1:numscans
        eval(['mkdir scan' num2str(i)])
    end
    
    cd functional
    
    for i = 1:numscans
        movefile(['swafrange_-000' num2str(i+2+sessex) '-*'], [homepath studyid '/' subject_id '/scan' num2str(i)]);
    end

    for i = 1:numscans
        movefile(['rp_afrange_-000' num2str(i+2+sessex) '*.txt'], [homepath studyid '/' subject_id '/scan' num2str(i)]);
    end

    
 end         %this ends the main subject loop

%%%%%%%%%%%%%%%%%%%%%%%%
% FINAL HOUSEKEEPING TASKS
%%%%%%%%%%%%%%%%%%%%%%%%%%

toc % This stops and reads the Matlab timer
