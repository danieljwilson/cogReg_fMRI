function SPM = makeSPMdesignmatrix_wCensor(scanpath,ons,ons_name, ...
    ons_duration, ons_modulate, mov_reg, outliers, preproc_version)

% Explanation:
% - Function called by code analyze_m1.m
% - Function sits on the scripts directory of the fmri neuropolitics directory
%
% Vars:
% filenum = cell array of directories with session files
% ons: cell array with onset times for different sessions {NumVariables NumSessions}
% ons_name: cell array with strings specifying the name of the variable
% ons_modulate: cell array with modulators {NumVariables NumSessions}{NumModulators}
% rpars: cell array with movement regressors
%
%
%
%
% Project: FMRI neuropolitics
% 
% Author: Antonio Rangel
%          Based on SPM5 scripts from Signe Bray & Alan Hampton
%
% Date: 8.21.2007
%
%
% NOTE:
% - Code designed to work with SPM5 & matlab 74
% - Code run in an Intel PowerMac
%
%
%
% NOTE: The following paragraph from Karl Friston might be useful in understanding
%       the logic of this code:
%
%  		In brief, SPM2 (AND SPM5) sets up a single structure (SPM) at the beginning of
% each analysis and, as the analysis proceeds, fills in sub-fields in a
% hierarchical fashion.  This enables one to fill in early fields
% automatically and bypass the user interface prompting.  After the
% design specification fields have been filled in the design matrix is
% computed and placed in a design matrix structure.  This, along with a
% data structure and non-sphericity structure is used by SPM to compute
% the parameters and hyperparameters.  These are saved (as handles to the
% parameter and hyperparameter images) as sub-fields of SPM.
%  A contrast sub-structure is generated automatically and can be
% augmented at any stage.  This structure array can be filled in
% automatically after estimation 
% using spm_contrasts.m.  The hierarchical
% organisation of the sub-function calls and the SPM structure means
% that, after a few specification fields are set in the SPM structure, an
% entire analysis, complete with contrasts can be implemented
% automatically.  


%==========================================================
%THIS VERSION IS MODIFIED TO USE TRIAL DEPENDENT DURATIONS
%==========================================================






%===========================================================================
% START SPM AND DEFINE SOME GLOBAL PARAMETERS
%------------------------------------------------------------------------

NumSessions = size(mov_reg,2);
NumVar=length(ons_name);				

global defaults;
    
%===========================================================================
% SPECIFY DESIGN VARIABLES
%===========================================================================


	%%%%%%%%%%%%%%%%%
	% TR
	%%%%%%%%%%%%%%%%%

    TR = 2;
    SPM.xY.RT          = TR;                              % seconds
    
    
    
	%%%%%%%%%%%%%%%%%
	% basis functions and timing parameters
	%%%%%%%%%%%%%%%%%    
    %---------------------------------------------------------------------------
    % OPTIONS for first field:
    %		  'hrf'
    %         'hrf (with time derivative)'
    %         'hrf (with time and dispersion derivatives)'
    %         'Fourier set'
    %         'Fourier set (Hanning)'
    %         'Gamma functions'
    %         'Finite Impulse Response'
    %---------------------------------------------------------------------------
    
    SPM.xBF.name       = 'hrf';
    SPM.xBF.length     = 32.2;              % length in seconds
    SPM.xBF.order      = 1;                 % order of basis set				
    SPM.xBF.T          = 16;                % number of time bins per scan
    SPM.xBF.T0         = 8;			        % first time bin (see slice timing) usually either first or middle
    										% NOTE: the default in SPM in scan 1
    										% Pick SPM.xBF.T/2 (assuming exists negligible gap between slice acquisitions)
    										% to temporally realign the regressors so that they match responses in the middle slice 
    SPM.xBF.UNITS      = 'secs';            % OPTIONS: 'scans'|'secs' for onsets
    SPM.xBF.Volterra   = 1;		            % OPTIONS: 1|2 = order of convolution; 2 creates regressors by multiplying the original one
      
        
    
 	%%%%%%%%%%%%%%%%%
	% Trial specification: Onsets, duration and parameters for modulation
	%
	% NOTE:
	% - Units for durantion should be the same as in SPM.xBF.UNITS
	%
	%%%%%%%%%%%%%%%%%    
    
    for i=1:NumSessions
    
    	counter=1;
    	for j=1:NumVar
        	if ~isempty(ons{j,i})	        	
				
				%put in condition variables        	
            	SPM.Sess(i).U(counter).name = ons_name(j);
            	SPM.Sess(i).U(counter).ons = ons{j,i};
            	SPM.Sess(i).U(counter).dur = ons_duration{j,i};  
            
            	% put in modulators
            	for k=1:length(ons_modulate{j,i})
                	SPM.Sess(i).U(counter).P(k).name = ons_modulate{j,i}{k}.name;	%name of modulator
                	if ~strcmp(SPM.Sess(i).U(counter).P(k).name, 'none')
                    	SPM.Sess(i).U(counter).P(k).h = ons_modulate{j,i}{k}.order;      %polynomial order of modulating parameter
                    	SPM.Sess(i).U(counter).P(k).P = ons_modulate{j,i}{k}.vec;		%vector of modulating values
                	end
            	end
				
				counter=counter+1; %don't want to use j in case an onset is empty
				
            end
    	end
    
    end
    
    
 	%%%%%%%%%%%%%%%%%
	% specify data: matrix of filenames
	%%%%%%%%%%%%%%%%%    
    % alt file names for newer fmriprep: 
    % subs 114,115,116,131, 142:147
    
    % unsmoothed files:
    % '*choose*MNI152NLin2009cAsym_preproc.nii'
    % '*choose*MNI152NLin2009cAsym_desc-preproc_bold.nii'       % ALT
    % 8mm smoothing (names by me so single naming profile):
    % '*choose*MNI152NLin2009cAsym_preproc_8mm.nii.gz'          
    % non-aggr aroma files:
    % '*choose*MNI152NLin2009cAsym_variant-smoothAROMAnonaggr_preproc.nii.gz'
    % '...*MNI152NLin2009cAsym_desc-smoothAROMAnonaggr_bold.nii.gz'    % ALT
    
    
    if strcmp(preproc_version, 'SubjectData_MNI152_8mm')
        gzip_image = '*choose*MNI152NLin2009cAsym_preproc_8mm.nii.gz';
        nifti_image = '*choose*MNI152NLin2009cAsym_preproc_8mm.nii';
    
    end
    if  strcmp(preproc_version, 'SubjectData_icaAroma_nonAggr_6mm')
        gzip_image = '*choose*MNI152NLin2009cAsym_desc-smoothAROMAnonaggr_bold.nii.gz';
        nifti_image = '*choose*MNI152NLin2009cAsym_desc-smoothAROMAnonaggr_bold.nii';
    end
    
    %
    % first test if nifti file exists
    if isempty(dir(fullfile(scanpath, nifti_image))) == 1
         % if not unzip .gz files
         display('unzipping gz files...')
         filenames = dir(fullfile(scanpath, gzip_image)); % 'choose' is run type
         for f = 1:length(filenames)
            gunzip(fullfile(scanpath, filenames(f).name))
         end
    end
    
    % load nifti files
    filenames = dir(fullfile(scanpath, nifti_image)); % 'choose' is run type

            
    SPM.xY.P=cat(2,repmat([scanpath filesep],length(filenames),1),...
                 char({filenames(:).name}));
	
	for i=1:NumSessions
    	SPM.nscan(i) = size(mov_reg{i},1);
    end
    
    %%%%%%%%%%%%%%%%%
	% user specified covariates (e.g. movement parameters)
	%%%%%%%%%%%%%%%%%    
    
    for i=1:NumSessions
		SPM.Sess(i).C.C = [mov_reg{i} outliers{i}];		% [n x c + o double ] regressors
        if length(mov_reg{1,i}(1,:)) >6  % check if we have more than just the 6 movement regressors
            SPM.Sess(i).C.name = {'r1','r2','r3','r4','r5','r6','nss'};	% [1 x c cell] names of movement regressors + non-steady state
        else
            SPM.Sess(i).C.name = {'r1','r2','r3','r4','r5','r6'};	% [1 x c cell] names of movement regressors
        end
        
        if ~isempty(outliers{i})
            for j = 1:size(outliers{i},2)
                SPM.Sess(i).C.name{end + 1} = ['outlier' num2str(j)];
            end
        end
    end
	
    
    %%%%%%%%%%%%%%%%%
	% global normalization: OPTINS:'Scaling'|'None'
	% 
	% NOTE:
	% - If choose yes for Global Scaling then need to enter more fields
	%%%%%%%%%%%%%%%%%
  
    
    SPM.xGX.iGXcalc    = 'None';
    

	%%%%%%%%%%%%%%%%%
	% low frequency confound: high-pass cutoff (secs) [Inf = no filtering]
	%%%%%%%%%%%%%%%%%
    
    SPM.xX.K.HParam    = 128;
    
    
    %%%%%%%%%%%%%%%%%
	% intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'
	%%%%%%%%%%%%%%%%%
	
    SPM.xVi.form       = 'AR(1) + w';


        
%==========================================================================
%
% Configure design matrix
%===========================================================================

disp('configuring the design matrix ...');
SPM = spm_fmri_spm_ui(SPM);
disp('finished making the design matrix ...');
    
 