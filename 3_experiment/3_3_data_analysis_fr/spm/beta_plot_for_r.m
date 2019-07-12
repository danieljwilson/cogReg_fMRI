%%%%%%%%%%%%%%%%%%
%
% BETA PLOT FOR ROI, GIVES PEAK VOXEL, PEAK VOXEL IN SPHERE, AND AVE OF ROI
% 
% Author: Cendri Hutcherson
% Adapted from scripts by Todd Hare
% 
%
%%%%%%%%%%%%%%%%%%%%%%

%
% BRIEF DESCRIPTION:
% - This code takes an input a list of masks for areas of interest & regressors of interest
% - For every subject, it selects the voxel with the maximum Z-score for the associated beta within the mask
% - For each area and event, then it plots the avg and se of the maximum betas
% 
% HOW TO USE:
% - Make sure to change the data on preliminaries to match your study
% - you probably want to tweak w/ the graphical parameters to optimize your graphs
% - Also, if you have more than two areas or two regressors, you need to
%   update the code where indicated below.
% - if you have multilple sessions you will first need to run a contrast to
%   add up the beta values from each session. (i.e. all 1s with rest 0s)
%
%
%

clear all;
currdir = pwd;
%%%%%%%%%
% Preliminaries and parameters
%
% !!!!!! NEED TO CHANGE FOR EVERY STUDY
%
%%%%%%%%%%
good_subjects.name = 'good_subjects';
y = [101:104, 106:112, 114, 116, 118:121, 123:126, 129:137, 139:140, 142:148, 150, 152:158, 162:164];  
good_subjects.subjects = strseq('', y);

subj_ids = good_subjects.subjects;
%list of subjects
% subj_ids = {'101' '102' '103' '104' '105'       '107' '108' '109' '110'   ... 
%             '111' '112' '113' '114'             '117' '118' '119' '120'...
%             '121' '122' '123' '124'       '126'             '129' '130' ...
%             '131' '132' '133' '134'       '136' '137' '138' '139' '140' ... 
%             '141' '142' '143' '144' '145' '146' '147' '148' '149' '150' ... 
%             '151' '152' '153' '154'       '156'...   '157' '158' '159' '160' ...'154'
%             '216' '234'
%             };
        
printresults = input('Print results to file?: 0 = no, 1 (default) = yes:  ');
if isempty(printresults)
    printresults = 1;
end

% set this to 1 if you want to graph peak instead of average, 2 if you want
% to graph sphere around peak
graphpeak = input('What type?: 0 (default) = ave, 1 = peak, 2 = peak sphere: ');

% set average from ROI as default
if isempty(graphpeak)
    graphpeak = 0;
end

% get sphere radius if using peak-sphere option
if graphpeak == 2
    VOIradius = input('Radius?: ');                                      % radius of sphere if using 
    % default sphere radius of 6mm
    if isempty(VOIradius)
        VOIradius = 6;
    end
end

pathtofile = mfilename('fullpath');

studyid = 'food_reg_fmri_01';

homepath = pathtofile(1:(regexp(pathtofile,studyid)-1));

maskname{1} = 'vmPFC_sphere_6mm_image_-4_36_12_1_Preference_All-Preference';
maskname{2} = 'L_dlPFC_sphere_6mm_image_-54_24_36_1_Preference_All-Preference';
maskname{3} = 'R_dlPFC_sphere_6mm_image_-42_36_18_1_Preference_All-Preference';
maskname{4} = 'L_TPJ_sphere_6mm_-54_-62_30';
maskname{5} = 'L_vlPFC_sphere_6--48_50_-10';
maskname{6} = 'vmPFC_MainDvN_p001';
maskname{7} = 'vmPFC_HealthHvN_p001';
maskname{8} = 'vlPFC_overlap';
maskname{9} = 'IPL_overlap';


masksToUse = [8:9]; %

count = 1;
for i = masksToUse
    if isequal(maskname{i},'MNI') % WHAT is this for?
        mask{count}=[homepath studyid filesep 'analysis/SPM/amasks/' maskname{i} '/' maskname{i} '.img'];
        else
        maskfile = dir([homepath studyid filesep 'analysis/SPM/fmasks/' maskname{i} '/' maskname{i} '*']); % change the file path to be correct
%         mask{count}=[homepath studyid filesep 'spmResults/fmasks/' maskname{i} '/' maskname{i} '.img'];
        mask{count}=[homepath studyid filesep 'analysis/SPM/fmasks/' maskname{i} '/' maskfile(1).name];
    end
%     else
%         maskfile = dir([homepath studyid filesep 'code/spm/fmasks/' maskname{i} '/' maskname{i} '*']); % change the file path to be correct
% %         mask{count}=[homepath studyid filesep 'spmResults/fmasks/' maskname{i} '/' maskname{i} '.img'];
%         mask{count}=[homepath studyid filesep 'code/spm/fmasks/' maskname{i} '/' maskfile(1).name];
%     end
    
    count = count + 1;
end

%base_dir (directory where the beta images are located for each subject


%base_dir=[homepath studyid filesep 'results/PPI' modelnum '/'];

%list of beta images for which want to compute average betas (as string)
%give contrast images if you have more than one session
% 
% modelnum = '1_Preference';
% measure = 'preference';
% beta_name = {'Natural-Preference','Decrease-Preference','Health-Preference'};

modelnum = '1_Preference';
measure = 'main';
beta_name = {'Natural','Decrease','Health'};

% modelnum = '2_taste_a_health';
% measure = 'TasteHealth';
% beta_name = {'Natural-Taste','Natural-Health','Decrease-Taste','Decrease-Health','Health-Taste','Health-Health'};

% modelnum = '4_preference_a_pre_m_post';
% measure = 'PrePostSuccess';
% beta_name = {'Natural-pre_m_post','Decrease-pre_m_post','Health-pre_m_post'};

% modelnum = '5_preference_a_reg_success_lasting';
% measure = 'PrePostSuccess';
% beta_name = {'Natural-reg_success_lasting','Decrease-reg_success_lasting','Health-reg_success_lasting'};


base_dir=[homepath studyid filesep 'analysis/SPM/' modelnum '/SubjectData_MNI152_8mm/'];

% path and contrast name used to extract the betas.  This is the one that 
% motivated the beta analysis in the original model, and will be used to
% select the peak voxel from within the ROI, if either peak option is 
% selected

path_extract=[homepath studyid filesep 'results/1_Preference/'];
con_extract_name = 'Natural-Preference';				


%path to ANY individual SPM in the study
path=[homepath studyid filesep 'analysis/SPM/' modelnum '/SubjectData_MNI152_8mm/101'];




%%%%%%%%%%%%%
%
% Construct matrix w/ the voxels included in every mask
%
%%%%%%%%%%%%%%

% load ANY SPM in the study to get list of voxels included in an image
% (any SPM from the study would do since the goal of this step is just to get a list of voxels)

eval(['cd ' path])
load SPM

VOIdef = 'sphere';

% Get list of XYZ voxel coordinates for entire image
XYZ  = SPM.xVol.XYZ;	    

for v=1:length(mask)
	
	% Get all data in the mask
	Z = spm_get_data(mask{v},XYZ);  %get all of the statistical values in the contrast image
	
	%select the list of voxels in the mask
	W{v}=XYZ(:,find(Z>0));
    %clear Z

    
end



%%%%%%%%%%%%%%
% Extract beta information for every subject @ voxel with maximum Z-score within the mask
%%%%%%%%%%%%%%

for v=1:length(mask)

  for s=1:length(subj_ids)
      

	for event=1:length(beta_name)
        
        subj_dir=[base_dir subj_ids{s} '/'];
        
        
		if graphpeak == 1
            %extract Z-contrast images
            path_extract_model = regexp(path_extract,'/spmResults/\w+\d+\w*\d*','match');  %: rename file path
            path_extract_model = path_extract_model{1}(10:end);
            load([path_extract '/' path_extract_model '_cons.mat']);
            con_extract = searchcell(cname,con_extract_name);
            con_extract = sprintf('con_%04.0f.img',con_extract);
            z_file=[path_extract subj_ids{s} '/' con_extract]; %note that this selects the same voxel for both events
            C=spm_vol(z_file);
            z_vals=spm_get_data(z_file,W{v});
            
            %if abs(max(z_vals))>abs(min(z_vals))
                voxel_coord=W{v}(:,find(z_vals==max(z_vals)));	
            %else
            %    voxel_coord=W{v}(:,find(z_vals==min(z_vals)));
            %end
            
            vcoordinates(s, 1:3) = W{v}(:,find(z_vals==max(z_vals)));
            %extract beta-value at top voxels
            load([subj_dir modelnum '_cons.mat'])
            beta_img = searchcell(cname,beta_name{event});
            beta_img = sprintf('con_%04.0f.img',beta_img);
            beta_file=[subj_dir beta_img];

            B=spm_vol(beta_file);
            vals=spm_get_data(beta_file,voxel_coord);

        elseif graphpeak ==2
            path_extract_model = regexp(path_extract,'/spmResults/\w+\d+\w*\d*','match'); % rename file path
            path_extract_model = path_extract_model{1}(10:end);
            load([path_extract '/' path_extract_model '_cons.mat']);
            con_extract = searchcell(cname,con_extract_name);
            
            if ~isempty(con_extract)
                con_extract = sprintf('con_%04.0f.img',con_extract);
                z_file=[path_extract subj_ids{s} '/' con_extract]; %note that this selects the same voxel for both events
                C=spm_vol(z_file);
                z_vals=spm_get_data(z_file,W{v});
                voxel_coord=W{v}(:,find(abs(z_vals)==max(abs(z_vals)))); 
                %voxel_coord=W{v}(:,find(z_vals==max(z_vals)));
                
                load([subj_dir modelnum '_cons.mat'])
                beta_img = searchcell(cname,beta_name{event});
                if ~isempty(beta_img)
                    beta_img = sprintf('con_%04.0f.img',beta_img);
                    beta_file=[subj_dir beta_img];


                    XYZmm = SPM.xVol.M(1:3,:)*[voxel_coord; ones(1,size(voxel_coord,2))];

                    spheremask = PeakSphere(beta_file,XYZmm,VOIradius,subj_ids{s},[homepath studyid filesep]);

                    B=spm_vol(beta_file);

                    %select the list of voxels in the mask
                    Z = spm_get_data([homepath studyid filesep subj_ids{s} '_spheretest.img'],XYZ);
                    spherecoords{v}=XYZ(:,find(Z==1));
                    %clear Z

                    subvals{s,event}        = spm_get_data(beta_file,spherecoords{v});

                    vals = mean(subvals{s,event});
                else
                    disp(['No contrast of ' beta_name{event} ' exists for subject ' subj_ids{s}])
                    vals = NaN;
                end
            else
                disp(['No contrast of ' con_extract_name ' exists for subject ' subj_ids{s}])
                vals = NaN;
            end
        else
            if exist([subj_dir 'm' modelnum '_cons.mat'],'file')
                load([subj_dir 'm' modelnum '_cons.mat'])
                beta_img = searchcell(cname,beta_name{event});
                if ~isempty(beta_img)
                    beta_img = sprintf('con_%04.0f.img',beta_img);
                    beta_file=[subj_dir beta_img];


                    B=spm_vol(beta_file);



                    vals=spm_get_data(beta_file,W{v});

                    vals=nanmean(vals); % added: length(vals)
                else
                    disp(['No contrast of ' beta_name{event} ' exists for subject ' subj_ids{s}])
                    vals = NaN;
                end
            else
                disp(['No contrast of ' beta_name{event} ' exists for subject ' subj_ids{s}])
                vals = NaN;
            end
        end	
        values(s,event,v)=vals(1);
        subjid{s} = subj_ids{s};
	end
  end
end  

% Clean up mask files
cd([homepath studyid])
delete('*spheretest*')


%%%%%%%%%%%%%%%%%%%%
%
% Do t-test 
%
% !!!!!!!! NEED TO CHANGE DETAILS MANUALLY !!!!!!!!!!!!!!!!!!!!!!!!!
%
%%%%%%%%%%%%%%%%%%%

% means of two conditions and paired t.test
    % first contrast #
%     con1 = 1;
%     % second contrast #
%     con2 = length(beta);
%     mean(values(:,con1,1))
%     mean(values(:,con2,1))
%     [h, p] = ttest(values(:,1,1),values(:,2,1))
%     [h, p] = ttest(values(:,2,1),values(:,3,1))
%     [h, p] = ttest(values(:,1,1),values(:,3,1))

% compute mean-corrected values


%%%%%%%%%%%
% compute mean and se
%%%%%%%%%%%

for v=1:length(mask)
	meanbeta = nanmean(values(:,:,v),2);
    cvalues = values(:,:,v) - repmat(meanbeta,1,size(values(:,:,v),2));
    
    for event=1:length(beta_name)
		m(event,v)=nanmean(values(:,event,v));
		se(event,v)=nanstd(values(:,event,v))/sqrt(length(subj_ids));
        cse(event,v)=nanstd(cvalues(:,event))/sqrt(length(subj_ids));
        [h p] = ttest(values(:,event,v))
	end
end

%m(1,v) = 2*m(1,v);
%%%%%%%%%%%%%
% draw figure w/ p-values 
%
%!!!!!!!! CHANGE GRAPHICAL PARAMETERS BELOW !!!!!!!!!!!!
%
%%%%%%%%%%%%%

for v = 1:length(mask)
    num = masksToUse(v);
    
    f=figure(v);
    clf
    set(f, 'Color', 'white')

    subplot(1,1,1)
    box off;
    hb=bar(m(:,v),.5);
    hold on;
    set(hb,'FaceColor',[0.5 0.5 0.5],'EdgeColor','none' )
    he=errorbar(m(:,v),se(:,v),'.');
    set(he,'LineWidth',2, ...
        'Color','black', ...
        'MarkerSize',1)
    ylabel('? coefficient','fontsize',30,'fontweight','b')
    %Determines range of y-axis
    %ylim([-4 .5]);
    set(gca, 'XTickLabel',beta_name, 'fontsize',15, 'fontweight','b')
    m(:,v)
    se(:,v)

    %text(1.35, 3.75, ['p=' num2str(p1)], 'fontsize',16,'fontweight','b')
    %text(1.35, 3.75, 'p< .05', 'fontsize',16,'fontweight','b')
    %line([1 2],[3.25 3.25],'Color','black') %horizontal line width[x x] height[y y]
    %line([1 1],[3 3.25],'Color','black') %vertical  line width[x x] height[y y]
    %line([2 2],[3 3.25],'Color','black')
    %title(xyz_name{1},'fontsize',18,'fontweight','b')


    %%%%%%%%%%%%%%%
    % Save the figure
    %%%%%%%%%%%%%%%
    if isequal(maskname{num}(1:3),'MNI')
%         cd([homepath studyid filesep 'spmResults/amasks/' maskname{num}])
        cd([homepath studyid filesep 'analysis/SPM/amasks/' maskname{num}])
    else
%         cd([homepath studyid filesep 'spmResults/fmasks/' maskname{num}])
        cd([homepath studyid filesep 'analysis/SPM/fmasks/' maskname{num}])
    end

    if graphpeak == 0
        fig_name = [maskname{num} '' modelnum measure '.png'];
        method = 'Ave';
    elseif graphpeak == 1
        fig_name = [maskname{num} '' modelnum measure '_peak.png'];
        method = 'Pk';
    else
        fig_name = [maskname{num} '' modelnum measure '_peakS.png'];
        method = 'PkS';
    end

    
    
    % close f;


    if printresults
        % print graph
        %imwrite(frame2im(getframe(gcf)),fig_name,'png')
        
        % print data in format usable by R script (e.g. BarPlot.R)
        fid = fopen('betaplotdata.txt','a');
        fprintf(fid, '# beta plots for analysis using mask %s \n',maskname{num});
        fprintf(fid, '# Model %s, %s\n', modelnum, measure);
        fprintf(fid, '# Graph method = %s \n', method);
        fprintf(fid, '# betaweights<- c(');
        for i = 1:length(m(:,v))
            fprintf(fid, ' %.4f',m(i,v));
            if i < length(m)
                fprintf(fid,',');
            end
        end

        fprintf(fid, ')\n');
        fprintf(fid, '# stderror<- c(');
        for i = 1:length(m(:,v))
            fprintf(fid, ' %.4f',se(i,v));
            if i < length(m(:,v))
                fprintf(fid,',');
            end
        end
        fprintf(fid, ')\n');

        fprintf(fid, '# cstderror<- c(');
        for i = 1:length(m(:,v))
            fprintf(fid, ' %.4f',cse(i,v));
            if i < length(m(:,v))
                fprintf(fid,',');
            end
        end
        fprintf(fid, ')\n');

        fprintf(fid, '# barcolor = "DimGray"\n');
        fprintf(fid, '# sigtext = ''*''\n');
        fprintf(fid, '# figurename = "Figures/Plot_%s_%s_%s_%s"\n\n\n',modelnum,measure,method,maskname{num});
        fclose all;

        clear fid

        % print individual subject values for condition within mask
        if exist([fig_name(1:(regexp(fig_name,'.png')-1)) '.txt'],'file')
            delete([fig_name(1:(regexp(fig_name,'.png')-1)) '.txt'])
        end
        fid = fopen([fig_name(1:(regexp(fig_name,'.png')-1)) '.txt'],'a');
        fprintf(fid, 'Subject\t');
        for i = 1:length(beta_name)
            fprintf(fid, '%s\t',beta_name{i});
        end
        fprintf(fid, '\n');
        for i = 1:length(subj_ids)
            fprintf(fid,'%s\t',subj_ids{i});
            for j = 1:length(beta_name)
                fprintf(fid,'%.4f\t',values(i,j,v));
            end
            fprintf(fid,'\n');
        end

        fclose all;
    end
end

cd(currdir)