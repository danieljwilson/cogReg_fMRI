% create subject list (example)
% need to rerun: 101:113, 118:130 132:140

% error + additional subjects = 114:116, 131, 142:147
% pre file only 269 elements = 150


all_subjects.name = 'all_subjects';
%x = [114:116, 131, 142:147];         % ALT format from fmriprep
%x = [128:130, 132:140] ;                 % ORIGINAL format fmriprep
% x = [101:116, 118:140, 142:147];     % ALL subjects
x = [158];
all_subjects.subjects = strseq('', x);

%114 %116(icanonaggr)
good_subjects.name = 'good_subjects';
y = [102:104, 106:112, 114, 116, 118:121, 123:126, 129:137, 139:140, 142:148, 150, 152:158, 162:164];  
good_subjects.subjects = strseq('', y);

remaining_subjects.name = 'remaining_subjects';
y = [157:158, 162:164];  
remaining_subjects.subjects = strseq('', y);

%114 %131
new_subjects.name = 'new_subjects';
z = [102];
new_subjects.subjects = strseq('', z);
