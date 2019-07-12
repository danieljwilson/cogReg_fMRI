
% ANALYZE
% foodreg_m1_Preference_analyze2(new_subjects.subjects, 'SubjectData_icaAroma_nonAggr_6mm')
% foodreg_m1_PostPre_analyze2(new_subjects.subjects, 'SubjectData_icaAroma_nonAggr_6mm')
% foodreg_m1_TasteHealth_analyze2(new_subjects.subjects, 'SubjectData_icaAroma_nonAggr_6mm')
% 
% foodreg_m1_Preference_analyze2(new_subjects.subjects, 'SubjectData_MNI152_8mm')
% foodreg_m1_PostPre_analyze2(new_subjects.subjects, 'SubjectData_MNI152_8mm')
% foodreg_m1_TasteHealth_analyze2(new_subjects.subjects, 'SubjectData_MNI152_8mm')
% foodreg_m4_preference_a_pre_m_post_analyze2(good_subjects.subjects, 'SubjectData_MNI152_8mm')
% foodreg_m5_preference_a_reg_success_lasting_analyze2(good_subjects.subjects, 'SubjectData_MNI152_8mm')
% foodreg_m7_preference_a_reg_success_lasting_post_trial_analyze2(remaining_subjects.subjects, 'SubjectData_MNI152_8mm')
% foodreg_m8_pre_liking_analyze2(remaining_subjects.subjects, 'SubjectData_MNI152_8mm')

% CONTRASTS
preproc_version = 'SubjectData_MNI152_8mm';
% 
% contrast2_par_m1_preference(good_subjects.subjects, preproc_version);
% contrast2_par_m2_taste_a_health(good_subjects.subjects, preproc_version);
% contrast2_par_m3_pre_m_post(good_subjects.subjects, preproc_version);
% contrast2_par_m4_preference_a_pre_m_post(good_subjects.subjects, preproc_version);
% contrast2_par_m5_preference_a_reg_success_lasting(good_subjects.subjects, preproc_version);
% contrast2_par_m7_preference_a_reg_success_lasting_post_trial(good_subjects.subjects, preproc_version);
% contrast2_par_m8_pre_liking(good_subjects.subjects, preproc_version);


% 2ND LEVEL
% cd /Volumes/DJW_Lacie_01/PROJECTS/2018_Food_Reg_fMRI/09_DATA/food_reg_fmri_01/analysis/SPM/
% f = fullfile('m1_Preference', preproc_version, 'm1_Preference_cons.mat');
% load(f);
% for con = 1:length(cname)
% rfx_par('m1_Preference',cname(con),good_subjects,preproc_version)
% end
% 
% cd /Volumes/DJW_Lacie_01/PROJECTS/2018_Food_Reg_fMRI/09_DATA/food_reg_fmri_01/analysis/SPM/
% f = fullfile('m2_taste_a_health', preproc_version, 'm2_taste_a_health_cons.mat');
% load(f);
% for con = 1:length(cname)
% rfx_par('m2_taste_a_health',cname(con),good_subjects,preproc_version)
% end
% 
% cd /Volumes/DJW_Lacie_01/PROJECTS/2018_Food_Reg_fMRI/09_DATA/food_reg_fmri_01/analysis/SPM/
% f = fullfile('m3_pre_m_post', preproc_version, 'm3_pre_m_post_cons.mat');
% load(f);
% for con = 1:length(cname)
% rfx_par('m3_pre_m_post',cname(con),good_subjects,preproc_version)
% end

% cd /Volumes/DJW_Lacie_01/PROJECTS/2018_Food_Reg_fMRI/09_DATA/food_reg_fmri_01/analysis/SPM/
% f = fullfile('7_preference_a_reg_success_lasting_post_trial', preproc_version, 'm7_preference_a_reg_success_lasting_post_trial_cons.mat');
% load(f);
% for con = 1:length(cname)
% rfx_par('7_preference_a_reg_success_lasting_post_trial',cname(con),good_subjects,preproc_version)
% end

cd /Volumes/DJW_Lacie_01/PROJECTS/2018_Food_Reg_fMRI/09_DATA/food_reg_fmri_01/analysis/SPM/
f = fullfile('8_pre_liking', preproc_version, 'm8_pre_liking_cons.mat');
load(f);
for con = 1:length(cname)
rfx_par('8_pre_liking',cname(con),good_subjects,preproc_version)
end