AddPerSubject = function(ChoiceData, PerSubjectData, f, varname, byCond = TRUE){
  subjNames = unique(PerSubjectData$Subject)
  nSubjects = length(subjNames)
  for(l in 1:length(varname)){
    PerSubjectData[[varname[l]]] = NA
  }
  row = 1
  for(s in 1:nSubjects){
    if(byCond){
    for(cond in unique(PerSubjectData$Cond[PerSubjectData$Subject == subjNames[s]])){
      temp = subset(ChoiceData,Subject == subjNames[s] & Condition == cond)
      toAdd = f(temp)
      if(length(toAdd) == length(varname)){     
          for(l in 1:length(varname)){
            PerSubjectData[[varname[l]]][row] = toAdd[l]
          }
      }else{stop('Variable names do not match output length!')}
      row = row + 1
      }
    }else{
      print(subjNames[s])
      temp = ChoiceData[ChoiceData$Subject == subjNames[s],]
      toAdd = f(temp)
      if(length(toAdd) == length(varname)){
        for(i in unique(PerSubjectData$Instruction[PerSubjectData$Subject == subjNames[s]])){     
          for(l in 1:length(varname)){
            PerSubjectData[[varname[l]]][row] = toAdd[l]
          }
          row = row + 1
        }
      }else{stop('Variable names do not match output length!')}
      }
    }  
  return(PerSubjectData)
  }