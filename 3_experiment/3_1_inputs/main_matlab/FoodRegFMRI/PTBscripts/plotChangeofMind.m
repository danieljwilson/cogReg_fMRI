for t = 1:144

        input(['View trial ' num2str(t)])
        x = Data.ChoiceX{t};
        y = Data.ChoiceY{t};
        time = Data.ChoiceTime{t};
        temp(t) = processMouseTrace([x,y],time,1);
        temp(t).firstDeviation * 1000

end

OnRight = cell2mat(Data.ProposalOnRight) == 1;
AcceptedProposal = (OnRight & strcmp(Data.Choice, 'right')) | ...
                   (~OnRight & strcmp(Data.Choice,'left'));
SelfAmount = OnRight .* cell2mat(Data.Self_R) + ~OnRight .* cell2mat(Data.Self_L);
OtherAmount = OnRight .* cell2mat(Data.Other_R) + ~OnRight .* cell2mat(Data.Other_L);
GenerousChoice = (AcceptedProposal & SelfAmount < 10 & OtherAmount > 10) | ...
                 (~AcceptedProposal & SelfAmount > 10 & OtherAmount < 10);
ChoiceImplemented = cell2mat(Data.ChoiceImplemented);
% 
% % Generous Trials
% GChoiceImpTrials = find(ChoiceImplemented & GenerousChoice);
% GChoiceVetoTrials = find(~ChoiceImplemented & GenerousChoice);
% 
% nGChoiceImp = length(GChoiceImpTrials);
% nGChoiceVeto = length(GChoiceVetoTrials);
% 
% TraceGChoiceImpX  = zeros(nGChoiceImp,100);
% TraceGChoiceImpY  = zeros(nGChoiceImp,100);
% 
% TraceGChoiceVetoX  = zeros(nGChoiceVeto,100);
% TraceGChoiceVetoY  = zeros(nGChoiceVeto,100);
% 
% for i = 1:length(GChoiceImpTrials)
%    trial = GChoiceImpTrials(i);
%    TraceGChoiceImpX(i,:) = temp(trial).normX100 ;
%    TraceGChoiceImpY(i,:) = temp(trial).normY100 ;
% end
% 
% for i = 1:length(GChoiceVetoTrials)
%    trial = GChoiceVetoTrials(i);
%    TraceGChoiceVetoX(i,:) = temp(trial).normX100 ;
%    TraceGChoiceVetoY(i,:) = temp(trial).normY100 ;
% end
% 
% figure
% plot(mean(TraceGChoiceVetoX,1),mean(TraceGChoiceVetoY,1),'r')
% hold on;
% plot(mean(TraceGChoiceImpX,1),mean(TraceGChoiceImpY,1),'b')
% 
% % Selfish Trials
% SChoiceImpTrials = find(ChoiceImplemented & ~GenerousChoice);
% SChoiceVetoTrials = find(~ChoiceImplemented & ~GenerousChoice);
% 
% nSChoiceImp = length(SChoiceImpTrials);
% nSChoiceVeto = length(SChoiceVetoTrials);
% 
% TraceSChoiceImpX  = zeros(nSChoiceImp,100);
% TraceSChoiceImpY  = zeros(nSChoiceImp,100);
% 
% TraceSChoiceVetoX  = zeros(nSChoiceVeto,100);
% TraceSChoiceVetoY  = zeros(nSChoiceVeto,100);
% 
% for i = 1:length(SChoiceImpTrials)
%    trial = SChoiceImpTrials(i);
%    TraceSChoiceImpX(i,:) = temp(trial).normX100 ;
%    TraceSChoiceImpY(i,:) = temp(trial).normY100 ;
% end
% 
% for i = 1:length(SChoiceVetoTrials)
%    trial = SChoiceVetoTrials(i);
%    TraceSChoiceVetoX(i,:) = temp(trial).normX100 ;
%    TraceSChoiceVetoY(i,:) = temp(trial).normY100 ;
% end
% 
% 
% plot(mean(TraceSChoiceVetoX,1),mean(TraceSChoiceVetoY,1),'r--')
% plot(mean(TraceSChoiceImpX,1),mean(TraceSChoiceImpY,1),'b--')
% 
% [nGChoiceImp, nGChoiceVeto, nSChoiceImp, nSChoiceVeto]