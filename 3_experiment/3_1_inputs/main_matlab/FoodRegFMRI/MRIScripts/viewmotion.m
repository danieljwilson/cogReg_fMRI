function viewmotion(subjid)
% View motion
close all
pathtofile = mfilename('fullpath');

studyid = char(regexprep(regexp(pathtofile,'/[A-Z]{3}\d?/','match'),'/',''));

homepath = pathtofile(1:(regexp(pathtofile,studyid)-1));

cd([homepath studyid '/' subjid])
s = dir('scan*');

for session = 1:length(s)
    cd([homepath studyid '/' subjid '/scan' num2str(session)])
    motionfile = dir('rp*');
    fid = fopen(motionfile.name);
    mot{session} = textscan(fid,'%f %f %f %f %f %f');  
end

X = [];
Y = [];
Z = [];
Pitch = [];
Roll = [];
Yaw = [];

for session = 1:length(s)
    X = [X,mot{session}{1}'];
    Y = [Y,(mot{session}{2}'+2*(session-1))];
    Z = [Z,(mot{session}{3}'+1*(session-1))];
    Pitch = [Pitch,mot{session}{4}'];
    Roll = [Roll,mot{session}{5}'];
    Yaw = [Yaw,mot{session}{6}'];
end 

hold on
subplot(2,1,1)
plot(X)
hold on
plot(Y,'g')
plot(Z,'r')

subplot(2,1,2)
plot(100*Pitch)
hold on
plot(100*Roll,'g')
plot(100*Yaw,'r')
