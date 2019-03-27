function convertdicom_par(numworkers, subj_ids)
% Script: script for converting DICOM files
% Author: Todd Hare
%       Based on scripts from Antonio Rangel
%          Based on SPM5 scripts from Signe Bray


% %%%%%%%%%%%%%%%%%%%%%%%%
% % LIST OF SUBJECTS AND PRELIMINARY PARAMETERS
% %%%%%%%%%%%%%%%%%%%%%%%%%%
% 

if nargin < 1
    numworkers = 1;
end

pathtofile = mfilename('fullpath');

studyid = char(regexprep(regexp(pathtofile,'/[A-Z]{3}\d?/','match'),'/',''));

homepath = pathtofile(1:(regexp(pathtofile,studyid)-1));

%subjects done: 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN BODY
%%%%%%%%%%%%%%%%%%%%%%%%%%

for subj=labindex:numworkers:length(subj_ids)     %this loops over subjects
	
	subject_id=subj_ids{subj};
    cd([homepath studyid '/']) % goes to the directory where DICOM files are located
    eval(['cd ' subject_id])    %go to the subject's directory
    
    disp(['Working on subject ' subject_id])
    mkdir raw
%     %May need to change directory names here

    movefile([homepath studyid '/' subject_id '/ep2d*/*/*dcm'], [homepath studyid '/' subject_id '/']);

    movefile('T1_Structural*/*/*dcm', [homepath studyid '/' subject_id '/']);
                      	
	
	% get array of files in this directory
	files = dir('*dcm'); 			
	
	for j=1:length(files)
		filenames(j,:)=files(j).name;
	end
	
	hdrs = spm_dicom_headers(filenames);
    spm_dicom_convert(hdrs);
    
%     % move the created files into the right directory
%    
    mkdir('anatomical');
    mkdir('functional');
    mkdir([homepath studyid filesep 'onsets/' subject_id]);
    
    movefile('s*', [homepath studyid '/' subject_id '/anatomical']);
    movefile('fr*' ,[homepath studyid '/' subject_id '/functional']);
	movefile('*dcm', [homepath studyid '/' subject_id '/raw']);
	
% 	
%     %delete first two scans for each session
	
	cd functional

    delete frange*-000*-00001-000001-00.*
    delete frange*-000*-00002-000002-00.*

    cd ..

    rmdir('ep2d*', 's')
    rmdir('T1_Structural*', 's')

end









