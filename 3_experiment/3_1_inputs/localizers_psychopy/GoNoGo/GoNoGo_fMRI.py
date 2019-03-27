'''
Go/no-go task for fMRI.
Adapted from Hause Lin (who adapted from ?).

Daniel J Wilson
Hutcherson Lab, University of Toronto

Click green runinng man icon to begin experiment.

NEXT: Set timing and look for 5s from fMRI

Go stimuli: TTL 11
Nogo stimuli: TTL 12
Go trials + key press: TTL 15 (correct go trials)
Nogo trials + key press: TTL 16 (incorrect nogo trials) (ERN trials)
Go trials + no key press: TTL 18 (incorrect go trials) (no response-locked stuff)
Nogo trials + no key press: TTL 19 (correct nogo trials) (no response-locked stuff)
'''
# 7 to skip to end of block
# 0 to exit

# set DEBUG mode or not: if True, then participant ID will be 999 and display will not be fullscreen. 
# If False, will have to provide participant ID and will be in fullscreen mode
DEBUG = True
sendTTL = False

#------------------------------------#
# MAKE SURE THE FRAMERATE IS CORRECT #
#------------------------------------#

Hz = 2  # (=1 for 60Hz, =2 for 120Hz) based on refresh rate of monitor, 120Hz at ToNI

#-----------------------------#
# UPDATE FOR EACH PARTICIPANT #
#-----------------------------#

goLetter = 'w' # check Anonymized Subjects sheet to see which version to user for subject!


import pandas as pd
import numpy as np
import random, os, time
from psychopy import visual, core, event, data, gui, logging, parallel, monitors

# If you have a calibrated monitor set it here (and add it to Window())
monitor = 'testMonitor'
#monitor = 'EEG3Display'
#monitor = 'iMac'
#monitor = 'BehavioralLab'
#monitor = 'MacBookAir'

#stimulus directory/folder/path
stimulusDir = 'Stimuli' + os.path.sep

#EXPERIMENT SET UP
info = {} #create empty dictionary to store stuff

#import csv file with unique trials
if goLetter == 'm':
    trialsCSV_low = "GoNoGo_mw_low.csv"
    trialsCSV_high = "GoNoGo_mw_high.csv"
    info['goLetter'] = 'm'
    info['nogoLetter'] = 'w'
if goLetter == 'w':
    trialsCSV_low = "GoNoGo_wm_low.csv"
    trialsCSV_high = "GoNoGo_wm_high.csv"
    info['goLetter'] = 'w'
    info['nogoLetter'] = 'm'
trialsList_low = pd.read_csv(stimulusDir + trialsCSV_low)
trialsList_high = pd.read_csv(stimulusDir + trialsCSV_high)

if DEBUG:
    fullscreen = False #set fullscreen variable = False
    # logging.console.setLevel(logging.DEBUG)
    info['participant'] = 999 #let 999 = debug participant no.
else: #if DEBUG is not False... (or True)
    fullscreen = True #set full screen
    # logging.console.setLevel(logging.WARNING)
    info['participant'] = '' #dict key to store participant no.
    #present dialog to collect info
    dlg = gui.DlgFromDict(info) #create a dialogue box (function gui)
    if not dlg.OK: #if dialogue response is NOT OK, quit
        #moveFiles(dir = 'Data')
        core.quit()

info['task'] = 'gonogo' #task name
info['fixationFrames'] = 29 * Hz #frames (500ms)
#info['postFixationFrames'] = 36 #frames (600ms)
info['postFixationFrames'] = 20 * Hz #frames (500ms)... np.arange(36, 43, 1) #36 frames to 42 frames (600 ms to 700ms)
info['targetFrames'] = 27 * Hz #frames (at 120Hz, 120 frames = 1 second); max time to wait for response (in this case same as time stim is shown)
info['targetRemoveFrames'] = 27 * Hz #target stimuli will be shown for this number of frames and will be removed from screen (450ms)
info['blockEndPause'] = 0 #frames (500ms)
info['feedbackTime'] = 48 * Hz #frames
info['startTime'] = str(time.strftime('%Y-%m-%d-%H-%M-%S', time.localtime())) #create str of current date/time
info['endTime'] = ''
info['ITIDuration'] = 1. # np.arange(0.50, 0.81, 0.05) #a numpy array of ITI in seconds (to be randomly selected later for each trial)

globalClock = core.Clock() #create and start global clock to track OVERALL elapsed time
ISI = core.StaticPeriod(screenHz = 60 * Hz) #function for setting inter-trial interval later

if sendTTL:
    port = parallel.ParallelPort(address = 49168) #set parallel port address (EEG3: 49168, EEG1: 57360)
    port.setData(0) #make sure all pins are low

#create window to draw stimuli on
win = visual.Window(size = (800, 600), fullscr = fullscreen, units = 'norm', monitor=monitor, colorSpace = 'rgb', color = (-1, -1, -1))
#create mouse
mouse = event.Mouse(visible = False, win = win)
mouse.setVisible(0) #make mouse invisible

#create base filename to store data (assumes existence of Subject_Data folder)
filename = "Subject_Data/%03d-%s-%s.csv" %(int(info['participant']), info['startTime'], info['task'])
#create name for logfile
logFilename = "%03d-%s-%s" %(int(info['participant']), info['startTime'], info['task'])
# logfile = logging.LogFile(logFilename + ".log", filemode = 'w', level = logging.EXP) #set logging information (core.quit() is required at the end of experiment to store logging info!!!)
#logging.console.setLevel(logging.DEBUG) #set COSNSOLE logging level

#create stimuli that are constant for entire experiment
#draw stimuli required for this block
#[1.0,-1,-1] is red; #[1, 1, 1] is white
fixation = visual.TextStim(win = win, units = 'norm', height = 0.15, ori = 0, name = 'target', text = '+', font = 'Courier New Bold', colorSpace = 'rgb', color = [1, 1, 1], opacity = 1)

goText = visual.TextStim(win = win, units = 'norm', height = 0.25, ori = 0, name = 'target', text = info['goLetter'], font = 'Courier New', colorSpace = 'rgb', color = [1, 1, 1], opacity = 1)

nogoText = visual.TextStim(win = win, units = 'norm', height = 0.25, ori = 0, name = 'target', text = info['nogoLetter'], font = 'Courier New', colorSpace = 'rgb', color = [1, 1, 1], opacity = 1)


########################################################################
#CUSTOM FUNCTIONS TO DO STUFF
def showInstructions(text, timeBeforeAutomaticProceed = 0, timeBeforeShowingSpace = 0):
    '''Show instructions.
    text: Provide a list with instructions/text to present. One list item will be presented per page.
    timeBeforeAutomaticProceed: The time in seconds to wait before proceeding automatically.
    timeBeforeShowingSpace: The time in seconds to wait before showing 'Press space to continue' text.
    '''
    mouse.setVisible(0)
    event.clearEvents()

    #'Press space to continue' text for each 'page'
    continueText = visual.TextStim(win = win, units = 'norm', colorSpace = 'rgb', color = [1, 1, 1], font = 'Verdana', text = "Press button to continue", height = 0.06, wrapWidth = 1.4, pos = [0.0, 0.0])
    #instructions to be shown
    instructText = visual.TextStim(win = win, units = 'norm', colorSpace = 'rgb', color = [1, 1, 1], font = 'Verdana', text = 'DEFAULT', height = 0.13, wrapWidth = 1.4, pos = [0.0, 0.5])

    for i in range(len(text)): #for each item/page in the text list
        instructText.text = text[i] #set text for each page
        if timeBeforeAutomaticProceed == 0 and timeBeforeShowingSpace == 0: #if
            while not event.getKeys(keyList = ['1']): # changed 'space' to '1'
                continueText.draw(); instructText.draw(); win.flip()
                if event.getKeys(keyList = ['0']):
                    #moveFiles(dir = 'Data')
                    core.quit()
                elif event.getKeys(['7']): #if press 7, skip to next block
                    return None
        elif timeBeforeAutomaticProceed != 0 and timeBeforeShowingSpace == 0:
            #clock to calculate how long to show instructions
            #if timeBeforeAutomaticProceed is not 0 (e.g., 3), then each page of text will be shown 3 seconds and will proceed AUTOMATICALLY to next page
            instructTimer = core.Clock()
            while instructTimer.getTime() < timeBeforeAutomaticProceed:
                if event.getKeys(keyList = ['0']):
                    #moveFiles(dir = 'Data')
                    core.quit()
                elif event.getKeys(['7']): #if press 7, skip to next block
                    return None
                instructText.draw(); win.flip()
        elif timeBeforeAutomaticProceed == 0 and timeBeforeShowingSpace != 0:
            instructTimer = core.Clock()
            while instructTimer.getTime() < timeBeforeShowingSpace:
                if event.getKeys(keyList = ['0']):
                    #moveFiles(dir = 'Data')
                    core.quit()
                elif event.getKeys(['7']): #if press 7, skip to next block
                    return None
                instructText.draw(); win.flip()
            win.flip(); event.clearEvents() #clear events to ensure if participants press space before 'press space to continue' text appears, their response won't be recorded

    instructText.setAutoDraw(False)
    continueText.setAutoDraw(False)

    for frameN in range(info['blockEndPause']):
        win.flip() #wait at the end of the block

def runBlockLow(blockType = '', reps = 1, feedback = False, saveData = True, practiceTrials = 10):
    '''Run a block of trials.
    blockType: custom name of the block; if blockType is set to 'practice', then no TTLs will be sent and the number of trials to run will be determined by argument supplied to parameter practiceTrials.
    reps: number of times to repeat each unique trial
    feedback: whether feedback is presented or not
    saveData = whether to save data to csv file
    practiceTrials: no. of practice trials to run
    '''
    
    mouse.setVisible(0) #make mouse invisible

    #Write header to csv or not? Default is not to write header. Try to read csv file from working directory. If fail to read csv (it hasn't been created yet), then the csv has to be created for the study and the header has to be written.
    writeHeader = False
    try: #try reading csv file dimensions (rows = no. of trials)
        pd.read_csv(filename)
    except: #if fail to read csv, then it's trial 1
        writeHeader = True

    trialsInBlock = trialsList_low
    trialsInBlock = pd.concat([trialsInBlock] * reps, ignore_index = True) #repeat each trial/row in dataframe reps number of times
    trialsDf = trialsInBlock.reindex(np.random.permutation(trialsInBlock.index)) #random shuffle trials
    trialsDf = trialsDf.reset_index(drop = True) #reset row index
    trialsDf = trialsDf[:-3] # because this gives us 5*3 = 15 trials we need to remove three to get to 12 trials
    
    #if this is a practice block
    if blockType == 'practice':
        trialsDf = trialsDf[0:practiceTrials] #number of practice trials to present

    #store additional info in dataframe
    trialsDf['participant'] = info['participant']
    trialsDf['trialNo'] = range(1, len(trialsDf) + 1) #add trialNo
    trialsDf['blockType'] = blockType #add blockType
    trialsDf['noGoFreq'] = 'low'
    trialsDf['goLetter'] = goLetter
    trialsDf['task'] = info['task'] #task name
    trialsDf['fixationFrames'] = info['fixationFrames']
    trialsDf['postFixationFrames'] = np.nan
    trialsDf['targetFrames'] = info['targetFrames']
    trialsDf['targetRemoveFrames'] = info['targetRemoveFrames']
    trialsDf['startTime'] = info['startTime']
    trialsDf['endTime'] = info['endTime']
    trialsDf['firstTR'] = np.nan

    #create variables to store data later
    trialsDf['blockNumber'] = 0 #add blockNumber
    trialsDf['elapsedTime'] = np.nan
    trialsDf['resp'] = None
    trialsDf['rt'] = np.nan
    trialsDf['iti'] = np.nan
    trialsDf['responseTTL'] = np.nan
    trialsDf['choice'] = np.nan
    trialsDf['overallTrialNum'] = 0 #cannot use np.nan because it's a float, not int!

    #Assign blockNumber based on existing csv file. Read the csv file and find the largest block number and add 1 to it to reflect this block's number.
    try:
        blockNumber = max(pd.read_csv(filename)['blockNumber']) + 1
        trialsDf['blockNumber'] = blockNumber
    except: #if fail to read csv, then it's block 1
        blockNumber = 1
        trialsDf['blockNumber'] = blockNumber
        # IF first trial, then wait for MRI signal '5'
        #while(not event.getKeys(keyList=['5'])):
        #    time.sleep(0.01)

    #create clocks to collect reaction and trial times
    respClock = core.Clock()
    trialClock = core.Clock()
    
    for i, thisTrial in trialsDf.iterrows(): #for each trial...
        if thisTrial.trialNo == 1 and blockNumber ==1:
            # IF first trial in first block, then wait for MRI signal '5'
            # Note that we are tossing out the first 3 TRs
            while(not event.getKeys(keyList=['5'])):
                time.sleep(0.001)
            trialsDf.loc[0, 'firstTR'] = globalClock.getTime() # note time of first TR
            fixation.setAutoDraw(True)
            win.flip()
            while(not event.getKeys(keyList=['5'])):
                time.sleep(0.001)
            while(not event.getKeys(keyList=['5'])):
                time.sleep(0.001)
            while(not event.getKeys(keyList=['5'])):
                time.sleep(0.001)
            fixation.setAutoDraw(False)
            win.flip()
        #start inter-trial interval 1 (for stim)...
        ISI.start(0.5)
        trialsDf.loc[i, 'startTime'] = globalClock.getTime() #store starting time in seconds
        fixation.setAutoDraw(False) #stop showing fixation
        
        #add overall trial number to dataframe
        try: #try reading csv file dimensions (rows = no. of trials)
            #thisTrial['overallTrialNum'] = pd.read_csv(filename).shape[0] + 1
            trialsDf.loc[i, 'overallTrialNum'] = pd.read_csv(filename).shape[0] + 1
            ####print 'Overall Trial No: %d' %thisTrial['overallTrialNum']
        except: #if fail to read csv, then it's trial 1
            #thisTrial['overallTrialNum'] = 1
            trialsDf.loc[i, 'overallTrialNum'] = 1
            ####print 'Overall Trial No: %d' %thisTrial['overallTrialNum']

        if sendTTL and not blockType == 'practice':
            port.setData(0) #make sure all pins are low before new trial
            ###print 'Start Trial TTL 0 set all pins to low'

        #3: draw stimulus automatically on next flips
        if thisTrial['trialType'] == 'go':
            goText.setAutoDraw(True)
        elif thisTrial['trialType'] == 'nogo':
            nogoText.setAutoDraw(True)

        win.callOnFlip(respClock.reset) #reset response clock on next flip
        win.callOnFlip(trialClock.reset) #reset trial clock on next flip

        event.clearEvents() #clear events

        for frameN in range(info['targetFrames']):
            if frameN == 0: #on first frame/flip/refresh
                if sendTTL and not blockType == 'practice':
                    win.callOnFlip(port.setData, int(thisTrial['TTLStim']))
                ##print "First frame in Block %d Trial %d OverallTrialNum %d" %(blockNumber, i + 1, trialsDf.loc[i, 'overallTrialNum'])
                ##print "Stimulus TTL: %d" %(int(thisTrial['TTLStim']))
            else:
                #if frameN == info['targetRemoveFrames']:
                #    #remove stimulus from screen
                #    goText.setAutoDraw(False); nogoText.setAutoDraw(False)
                keys = event.getKeys(keyList = ['1', '0', '7']) # changed 'space' to '1'
                if len(keys) > 0: #if a response has been made
                    trialsDf.loc[i, 'resp'] = keys[0] #store response in pd df
                    trialsDf.loc[i, 'rt'] = respClock.getTime() #store RT

                    if trialsDf.loc[i, 'resp'] == '1' and thisTrial['trialType'] == 'go': #if go trial and keypress (changed 'space' to '1')
                        if sendTTL and not blockType == 'practice':
                            port.setData(15) #correct response
                        trialsDf.loc[i, 'responseTTL'] = 15
                        trialsDf.loc[i, 'acc'] = 1
                        ##print 'correct keypress: %s' %str(trialsDf.loc[i, 'resp'])
                        ##print "Response TTL: 15"

                    elif trialsDf.loc[i, 'resp'] == '1' and thisTrial['trialType'] == 'nogo': #if nogo trial and keypress (changed 'space' to '1')
                        if sendTTL and not blockType == 'practice':
                            port.setData(16) #incorrect response
                        trialsDf.loc[i, 'responseTTL'] = 16
                        trialsDf.loc[i, 'acc'] = 0
                        ##print 'incorrect keypress: %s' %str(trialsDf.loc[i, 'resp'])
                        ##print "Response TTL: 16"

                    #remove stimulus from screen
                    #goText.setAutoDraw(False); nogoText.setAutoDraw(False)
                    #win.flip() #clear screen (remove stuff from screen)
                    #break #break out of the for loop when response has been made (ends trial and moves on to intertrial interval)
            win.flip()
        
        #if no response has been made within allowed time, remove stimuli and record accuracay
        if trialsDf.loc[i, 'resp'] is None: #if no response made
            if thisTrial['trialType'] == 'go': #if go trial
                if sendTTL and not blockType == 'practice':
                    port.setData(18) #incorrect response
                trialsDf.loc[i, 'acc'] = 0 #wrong
                trialsDf.loc[i, 'responseTTL'] = 18
                ##print "Incorrect: No keypress detected/no response."
                ##print "Response TTL: 18"
                ###print respClock.getTime()
            elif thisTrial['trialType'] == 'nogo': #if nogo trial
                if sendTTL and not blockType == 'practice':
                    port.setData(19) #incorrect response
                trialsDf.loc[i, 'acc'] = 1 #correct
                trialsDf.loc[i, 'responseTTL'] = 19
                ##print "Correct: No keypress detected/no response."
                ##print "Response TTL: 19"
                ###print respClock.getTime()
            #goText.setAutoDraw(False); nogoText.setAutoDraw(False)
            #win.flip() #clear screen (remove stuff from screen)

        if sendTTL and not blockType == 'practice':
            port.setData(0) #parallel port: set all pins to low

        
        # trialsDf.loc[i, 'endTime'] = str(time.strftime('%Y-%m-%d-%H-%M-%S', time.localtime())) #store current time
        iti =  info['ITIDuration'] # random.choice(info['ITIDuration']) #randomly select an ITI duration
        trialsDf.loc[i, 'iti'] = iti #store ITI duration
        # remove text from screen
        goText.setAutoDraw(False); nogoText.setAutoDraw(False)
        ISI.complete()

        #start inter-trial interval (after stim)...
        ISI.start(iti)
        trialsDf.loc[i, 'endTime'] = globalClock.getTime() #store end of trial time
        ###print "TRIAL OK TRIAL %d OVERALL TRIAL %d" %(i + 1, int(trialsDf.loc[i, 'overallTrialNum']))
            
        #if press 0 (quit script) or 7 (skip block)
        if trialsDf.loc[i, 'resp'] == '0':
            trialsDf.loc[i, 'responseTTL'] = np.nan
            trialsDf.loc[i, 'acc'] = np.nan
            trialsDf.loc[i, 'resp'] = None
            if saveData: #if saveData argument is True, then append current row/trial to csv
                trialsDf[i:i+1].to_csv(filename, header = True if i == 0 and writeHeader else False, mode = 'a', index = False) #write header only if index i is 0 AND block is 1 (first block)
            #moveFiles(dir = 'Data')
            core.quit() #quit when '0' has been pressed
        elif trialsDf.loc[i, 'resp'] == '7':#if press 7, skip to next block
            trialsDf.loc[i, 'responseTTL'] = np.nan
            trialsDf.loc[i, 'acc'] = np.nan
            trialsDf.loc[i, 'responseTTL'] = np.nan
            trialsDf.loc[i, 'resp'] == None
            #naturalText.setAutoDraw(False)
            #healthText.setAutoDraw(False)
            #tasteText.setAutoDraw(False)
            win.flip()
            if saveData: #if saveData argument is True, then append current row/trial to csv
                trialsDf[i:i+1].to_csv(filename, header = True if i == 0 and writeHeader else False, mode = 'a', index = False) #write header only if index i is 0 AND block is 1 (first block)
            return None

        if saveData: #if saveData argument is True, then append current row/trial to csv
            trialsDf[i:i+1].to_csv(filename, header = True if i == 0 and writeHeader else False, mode = 'a', index = False) #write header only if index i is 0 AND block is 1 (first block)

        #1: draw and show fixation
        fixation.setAutoDraw(True) #draw fixation on next flips
        win.flip()
        #for frameN in range(info['fixationFrames']):
        #    win.flip()
        

        #2: postfixation black screen
        #postFixationBlankFrames = info['postFixationFrames'] # random.choice(info['postFixationFrames'])
        ###print postFixationBlankFrames
        #trialsDf.loc[i, 'postFixationFrames'] = postFixationBlankFrames #store in dataframe
        #for frameN in range(postFixationBlankFrames):
        #    win.flip()

        ISI.complete() #end inter-trial interval
        
        
        #if np.isnan(trialsDf.loc[i, 'rt'])==False:
        #    print(.45 - trialsDf.loc[i, 'rt'])
        #    core.wait(.45 - trialsDf.loc[i, 'rt'])
            
        #feedback for trial
        if feedback:
            #stimuli
            accuracyFeedback = visual.TextStim(win = win, units = 'norm', colorSpace = 'rgb', color = [1, 1, 1], font = 'Courier New', text = '', height = 0.13, wrapWidth = 1.4, pos = [0.0, 0.0])

            reactionTimeFeedback = visual.TextStim(win = win, units = 'norm', colorSpace = 'rgb', color = [1, 1, 1], font = 'Courier New', text = '', height = 0.11, wrapWidth = 1.4, pos = [0.0, 0.0])

            if trialsDf.loc[i, 'resp'] == '1' and thisTrial['trialType'] == 'nogo': #if nogo trial and keypress (changed 'space' to '1')
                accuracyFeedback.setText("Wrong! No response required!")
                for frameN in range(info['feedbackTime']):
                    accuracyFeedback.draw()
                    #reactionTimeFeedback.draw()
                    win.flip()
            elif trialsDf.loc[i, 'resp'] is None and thisTrial['trialType'] == 'go': #if go trial and no response
                accuracyFeedback.setText("Wrong! Respond faster!")
                for frameN in range(info['feedbackTime']):
                    accuracyFeedback.draw()
                    #reactionTimeFeedback.draw()
                    win.flip()
            '''
            elif trialsDf.loc[i, 'resp'] is None and thisTrial['trialType'] == 'nogo': #if nogo trial and no response
                accuracyFeedback.setText("Correct!")
                for frameN in range(info['feedbackTime']):
                    accuracyFeedback.draw()
                    #reactionTimeFeedback.draw()
                    win.flip()
            elif trialsDf.loc[i, 'resp'] == 'space' and thisTrial['trialType'] == 'go': #if go trial and keypress
                accuracyFeedback.setText("Correct.")
                #accuracyFeedback.setPos([0.0, 0.0])
                #reactionTimeFeedback.setText("No response within 3s.")
                #reactionTimeFeedback.setPos([0.0, -0.025])
                for frameN in range(info['feedbackTime']):
                    accuracyFeedback.draw()
                    #reactionTimeFeedback.draw()
                    win.flip()
            '''
    fixation.setAutoDraw(False) #stop showing fixation
    for frameN in range(info['blockEndPause']):
        win.flip() #wait at the end of the block

def runBlockHigh(blockType = '', reps = 1, feedback = False, saveData = True, practiceTrials = 10):
    '''Run a block of trials.
    blockType: custom name of the block; if blockType is set to 'practice', then no TTLs will be sent and the number of trials to run will be determined by argument supplied to parameter practiceTrials.
    reps: number of times to repeat each unique trial
    feedback: whether feedback is presented or not
    saveData = whether to save data to csv file
    practiceTrials: no. of practice trials to run
    '''
    
    mouse.setVisible(0) #make mouse invisible

    #Write header to csv or not? Default is not to write header. Try to read csv file from working directory. If fail to read csv (it hasn't been created yet), then the csv has to be created for the study and the header has to be written.
    writeHeader = False
    try: #try reading csv file dimensions (rows = no. of trials)
        pd.read_csv(filename)
    except: #if fail to read csv, then it's trial 1
        writeHeader = True

    trialsInBlock = trialsList_high # specify the trial list with the higher freq. of nogo 
    trialsInBlock = pd.concat([trialsInBlock] * reps, ignore_index = True) #repeat each trial/row in dataframe reps number of times
    trialsDf = trialsInBlock.reindex(np.random.permutation(trialsInBlock.index)) #random shuffle trials
    trialsDf = trialsDf.reset_index(drop = True) #reset row index
    
    #if this is a practice block
    if blockType == 'practice':
        trialsDf = trialsDf[0:practiceTrials] #number of practice trials to present

    #store additional info in dataframe
    trialsDf['participant'] = info['participant']
    trialsDf['trialNo'] = range(1, len(trialsDf) + 1) #add trialNo
    trialsDf['blockType'] = blockType #add blockType
    trialsDf['noGoFreq'] = 'high'
    trialsDf['goLetter'] = goLetter
    trialsDf['task'] = info['task'] #task name
    trialsDf['fixationFrames'] = info['fixationFrames']
    trialsDf['postFixationFrames'] = np.nan
    trialsDf['targetFrames'] = info['targetFrames']
    trialsDf['targetRemoveFrames'] = info['targetRemoveFrames']
    trialsDf['startTime'] = info['startTime']
    trialsDf['endTime'] = info['endTime']
    trialsDf['firstTR'] = np.nan  # just as a placeholder so that the columns are correctly aligned

    #create variables to store data later
    trialsDf['blockNumber'] = 0 #add blockNumber
    trialsDf['elapsedTime'] = np.nan
    trialsDf['resp'] = None
    trialsDf['rt'] = np.nan
    trialsDf['iti'] = np.nan
    trialsDf['responseTTL'] = np.nan
    trialsDf['choice'] = np.nan
    trialsDf['overallTrialNum'] = 0 #cannot use np.nan because it's a float, not int!

    #Assign blockNumber based on existing csv file. Read the csv file and find the largest block number and add 1 to it to reflect this block's number.
    try:
        blockNumber = max(pd.read_csv(filename)['blockNumber']) + 1
        trialsDf['blockNumber'] = blockNumber
    except: #if fail to read csv, then it's block 1
        blockNumber = 1
        trialsDf['blockNumber'] = blockNumber
        # IF first trial, then wait for MRI signal '5'
        while(not event.getKeys(keyList=['5'])):
            time.sleep(0.01)

    #create clocks to collect reaction and trial times
    respClock = core.Clock()
    trialClock = core.Clock()
    
    for i, thisTrial in trialsDf.iterrows(): #for each trial...
        #start inter-trial interval 1 (for stim)...
        ISI.start(0.5)
        trialsDf.loc[i, 'startTime'] = globalClock.getTime() #store starting time in seconds
        fixation.setAutoDraw(False) #stop showing fixation
        
        #add overall trial number to dataframe
        try: #try reading csv file dimensions (rows = no. of trials)
            #thisTrial['overallTrialNum'] = pd.read_csv(filename).shape[0] + 1
            trialsDf.loc[i, 'overallTrialNum'] = pd.read_csv(filename).shape[0] + 1
            ####print 'Overall Trial No: %d' %thisTrial['overallTrialNum']
        except: #if fail to read csv, then it's trial 1
            #thisTrial['overallTrialNum'] = 1
            trialsDf.loc[i, 'overallTrialNum'] = 1
            ####print 'Overall Trial No: %d' %thisTrial['overallTrialNum']

        if sendTTL and not blockType == 'practice':
            port.setData(0) #make sure all pins are low before new trial
            ###print 'Start Trial TTL 0 set all pins to low'

        #3: draw stimulus automatically on next flips
        if thisTrial['trialType'] == 'go':
            goText.setAutoDraw(True)
        elif thisTrial['trialType'] == 'nogo':
            nogoText.setAutoDraw(True)

        win.callOnFlip(respClock.reset) #reset response clock on next flip
        win.callOnFlip(trialClock.reset) #reset trial clock on next flip

        event.clearEvents() #clear events

        for frameN in range(info['targetFrames']):
            if frameN == 0: #on first frame/flip/refresh
                if sendTTL and not blockType == 'practice':
                    win.callOnFlip(port.setData, int(thisTrial['TTLStim']))
                ##print "First frame in Block %d Trial %d OverallTrialNum %d" %(blockNumber, i + 1, trialsDf.loc[i, 'overallTrialNum'])
                ##print "Stimulus TTL: %d" %(int(thisTrial['TTLStim']))
            else:
                #if frameN == info['targetRemoveFrames']:
                #    #remove stimulus from screen
                #    goText.setAutoDraw(False); nogoText.setAutoDraw(False)
                keys = event.getKeys(keyList = ['1', '0', '7']) # changed 'space' to '1'
                if len(keys) > 0: #if a response has been made
                    trialsDf.loc[i, 'resp'] = keys[0] #store response in pd df
                    trialsDf.loc[i, 'rt'] = respClock.getTime() #store RT

                    if trialsDf.loc[i, 'resp'] == '1' and thisTrial['trialType'] == 'go': #if go trial and keypress (changed 'space' to '1')
                        if sendTTL and not blockType == 'practice':
                            port.setData(15) #correct response
                        trialsDf.loc[i, 'responseTTL'] = 15
                        trialsDf.loc[i, 'acc'] = 1
                        ##print 'correct keypress: %s' %str(trialsDf.loc[i, 'resp'])
                        ##print "Response TTL: 15"

                    elif trialsDf.loc[i, 'resp'] == '1' and thisTrial['trialType'] == 'nogo': #if nogo trial and keypress (changed 'space' to '1')
                        if sendTTL and not blockType == 'practice':
                            port.setData(16) #incorrect response
                        trialsDf.loc[i, 'responseTTL'] = 16
                        trialsDf.loc[i, 'acc'] = 0
                        ##print 'incorrect keypress: %s' %str(trialsDf.loc[i, 'resp'])
                        ##print "Response TTL: 16"

                    #remove stimulus from screen
                    #goText.setAutoDraw(False); nogoText.setAutoDraw(False)
                    #win.flip() #clear screen (remove stuff from screen)
                    #break #break out of the for loop when response has been made (ends trial and moves on to intertrial interval)
            win.flip()
        
        #if no response has been made within allowed time, remove stimuli and record accuracay
        if trialsDf.loc[i, 'resp'] is None: #if no response made
            if thisTrial['trialType'] == 'go': #if go trial
                if sendTTL and not blockType == 'practice':
                    port.setData(18) #incorrect response
                trialsDf.loc[i, 'acc'] = 0 #wrong
                trialsDf.loc[i, 'responseTTL'] = 18
                ##print "Incorrect: No keypress detected/no response."
                ##print "Response TTL: 18"
                ###print respClock.getTime()
            elif thisTrial['trialType'] == 'nogo': #if nogo trial
                if sendTTL and not blockType == 'practice':
                    port.setData(19) #incorrect response
                trialsDf.loc[i, 'acc'] = 1 #correct
                trialsDf.loc[i, 'responseTTL'] = 19
                ##print "Correct: No keypress detected/no response."
                ##print "Response TTL: 19"
                ###print respClock.getTime()
            #goText.setAutoDraw(False); nogoText.setAutoDraw(False)
            #win.flip() #clear screen (remove stuff from screen)

        if sendTTL and not blockType == 'practice':
            port.setData(0) #parallel port: set all pins to low

        
        # trialsDf.loc[i, 'endTime'] = str(time.strftime('%Y-%m-%d-%H-%M-%S', time.localtime())) #store current time
        iti =  info['ITIDuration'] # random.choice(info['ITIDuration']) #randomly select an ITI duration
        trialsDf.loc[i, 'iti'] = iti #store ITI duration
        # remove text from screen
        goText.setAutoDraw(False); nogoText.setAutoDraw(False)
        ISI.complete()

        #start inter-trial interval (after stim)...
        ISI.start(iti)
        trialsDf.loc[i, 'endTime'] = globalClock.getTime() #store end of trial time
        ###print "TRIAL OK TRIAL %d OVERALL TRIAL %d" %(i + 1, int(trialsDf.loc[i, 'overallTrialNum']))
            
        #if press 0 (quit script) or 7 (skip block)
        if trialsDf.loc[i, 'resp'] == '0':
            trialsDf.loc[i, 'responseTTL'] = np.nan
            trialsDf.loc[i, 'acc'] = np.nan
            trialsDf.loc[i, 'resp'] = None
            if saveData: #if saveData argument is True, then append current row/trial to csv
                trialsDf[i:i+1].to_csv(filename, header = True if i == 0 and writeHeader else False, mode = 'a', index = False) #write header only if index i is 0 AND block is 1 (first block)
            #moveFiles(dir = 'Data')
            core.quit() #quit when '0' has been pressed
        elif trialsDf.loc[i, 'resp'] == '7':#if press 7, skip to next block
            trialsDf.loc[i, 'responseTTL'] = np.nan
            trialsDf.loc[i, 'acc'] = np.nan
            trialsDf.loc[i, 'responseTTL'] = np.nan
            trialsDf.loc[i, 'resp'] == None
            #naturalText.setAutoDraw(False)
            #healthText.setAutoDraw(False)
            #tasteText.setAutoDraw(False)
            win.flip()
            if saveData: #if saveData argument is True, then append current row/trial to csv
                trialsDf[i:i+1].to_csv(filename, header = True if i == 0 and writeHeader else False, mode = 'a', index = False) #write header only if index i is 0 AND block is 1 (first block)
            return None

        if saveData: #if saveData argument is True, then append current row/trial to csv
            trialsDf[i:i+1].to_csv(filename, header = True if i == 0 and writeHeader else False, mode = 'a', index = False) #write header only if index i is 0 AND block is 1 (first block)

        #1: draw and show fixation
        fixation.setAutoDraw(True) #draw fixation on next flips
        win.flip()
        #for frameN in range(info['fixationFrames']):
        #    win.flip()
        

        #2: postfixation black screen
        #postFixationBlankFrames = info['postFixationFrames'] # random.choice(info['postFixationFrames'])
        ###print postFixationBlankFrames
        #trialsDf.loc[i, 'postFixationFrames'] = postFixationBlankFrames #store in dataframe
        #for frameN in range(postFixationBlankFrames):
        #    win.flip()

        ISI.complete() #end inter-trial interval
        
        
        #if np.isnan(trialsDf.loc[i, 'rt'])==False:
        #    print(.45 - trialsDf.loc[i, 'rt'])
        #    core.wait(.45 - trialsDf.loc[i, 'rt'])
            
        #feedback for trial
        if feedback:
            #stimuli
            accuracyFeedback = visual.TextStim(win = win, units = 'norm', colorSpace = 'rgb', color = [1, 1, 1], font = 'Courier New', text = '', height = 0.13, wrapWidth = 1.4, pos = [0.0, 0.0])

            reactionTimeFeedback = visual.TextStim(win = win, units = 'norm', colorSpace = 'rgb', color = [1, 1, 1], font = 'Courier New', text = '', height = 0.11, wrapWidth = 1.4, pos = [0.0, 0.0])

            if trialsDf.loc[i, 'resp'] == '1' and thisTrial['trialType'] == 'nogo': #if nogo trial and keypress (changed 'space' to '1')
                accuracyFeedback.setText("Wrong! No response required!")
                for frameN in range(info['feedbackTime']):
                    accuracyFeedback.draw()
                    #reactionTimeFeedback.draw()
                    win.flip()
            elif trialsDf.loc[i, 'resp'] is None and thisTrial['trialType'] == 'go': #if go trial and no response
                accuracyFeedback.setText("Wrong! Respond faster!")
                for frameN in range(info['feedbackTime']):
                    accuracyFeedback.draw()
                    #reactionTimeFeedback.draw()
                    win.flip()
            '''
            elif trialsDf.loc[i, 'resp'] is None and thisTrial['trialType'] == 'nogo': #if nogo trial and no response
                accuracyFeedback.setText("Correct!")
                for frameN in range(info['feedbackTime']):
                    accuracyFeedback.draw()
                    #reactionTimeFeedback.draw()
                    win.flip()
            elif trialsDf.loc[i, 'resp'] == 'space' and thisTrial['trialType'] == 'go': #if go trial and keypress
                accuracyFeedback.setText("Correct.")
                #accuracyFeedback.setPos([0.0, 0.0])
                #reactionTimeFeedback.setText("No response within 3s.")
                #reactionTimeFeedback.setPos([0.0, -0.025])
                for frameN in range(info['feedbackTime']):
                    accuracyFeedback.draw()
                    #reactionTimeFeedback.draw()
                    win.flip()
            '''
    fixation.setAutoDraw(False) #stop showing fixation
    for frameN in range(info['blockEndPause']):
        win.flip() #wait at the end of the block
        

def showTaskInstructions():
    showInstructions(text =
    ["", #black screen at the beginning
    "In this task, you'll see the letters '{}' and '{}' presented one at a time.".format(info['goLetter'], info['nogoLetter']),
    "Place your finger on the first button key.",
    "When you see '{}', press the button quickly.".format(info['goLetter']),
    "When you see '{}', do not press the button.".format(info['nogoLetter']),
    "The letter will disappear after {:.2f} seconds, so you'll have to respond quickly.".format(float(info['targetRemoveFrames']) / (60*Hz)),
    # "You have up to {:.1f} seconds to respond.".format(float(info['targetFrames']) / 60),
    "You have up to respond within this time.",
    "Now, time for practice trials with feedback.",
    "You'll only receive feedback if you've responded incorrectly (no feedback if you were correct).",
    "Try to remain still and not move too much when doing the task."]) # You'll have opportunities to take short breaks during study.

def showBlockBeginInstructions():
    showInstructions(text =
    ["Get ready and place your finger on the button.",
    "{:.2f} seconds to respond.".format(float(info['targetFrames']) / (60*Hz)),
    "Try to remain still and not move too much.",
    "Please wait for the scanner to start..."
    ])

def showBlockEndInstructions():
    showInstructions(text =
    ["Take a break. Press the button when ready to continue."])


def showWaitForRAInstructions():
    #new block instructions (check eye tracker)
    showInstructions(timeBeforeAutomaticProceed = 9999, text =
    ["Before you continue, we'll check whether all equipment and systems are in place. Please wait while we check everything. We'll let you know if they are any issues."
    ]) #RA has to press 7 to continue



##############################################################################
#showTaskInstructions() #instructions for the task

#practice block
#showBlockBeginInstructions()
#runBlockLow(feedback = True, reps = 6, blockType = 'practice', saveData = False, practiceTrials = 27) #reps * 5 practice trials - 3

#showInstructions(text = #finish practice trial instructions
#["Finished practice. From now on, you'll start the actual experiment and won't any receive feedback.",
#"The trials will take about 6 minutes."
#"You will have a break half-way through."
#"If you have any questions, please ask the research assistant now."
#])

if sendTTL:
    port.setData(0) #make sure all pins are low

showInstructions(text =
    ["", #black screen at the beginning
    "In this task, you'll see the letters '{}' and '{}' presented one at a time.".format(info['goLetter'], info['nogoLetter']),
    "Place your finger on the first button key.",
    "When you see '{}', press the button quickly.".format(info['goLetter']),
    "When you see '{}', do not press the button.".format(info['nogoLetter']),
    "The letter will disappear after {:.2f} seconds, so you'll have to respond quickly.".format(float(info['targetRemoveFrames']) / (60*Hz))])
#1 
showBlockBeginInstructions()
runBlockLow(feedback = False, reps = 3, blockType = 'actual', saveData = True) # reps * 5 actual trials in this block (then subtracting 3 to get 12)
runBlockHigh(feedback = False, reps = 6, blockType = 'actual', saveData = True)
#2 
runBlockLow(feedback = False, reps = 3, blockType = 'actual', saveData = True) # reps * 5 actual trials in this block (then subtracting 3 to get 12)
runBlockHigh(feedback = False, reps = 6, blockType = 'actual', saveData = True)
#3
runBlockLow(feedback = False, reps = 3, blockType = 'actual', saveData = True) # reps * 5 actual trials in this block (then subtracting 3 to get 12)
runBlockHigh(feedback = False, reps = 6, blockType = 'actual', saveData = True)
#4
runBlockLow(feedback = False, reps = 3, blockType = 'actual', saveData = True) # reps * 5 actual trials in this block (then subtracting 3 to get 12)
runBlockHigh(feedback = False, reps = 6, blockType = 'actual', saveData = True)
#5
runBlockLow(feedback = False, reps = 3, blockType = 'actual', saveData = True) # reps * 5 actual trials in this block (then subtracting 3 to get 12)
runBlockHigh(feedback = False, reps = 6, blockType = 'actual', saveData = True)



#6
#showBlockEndInstructions()
#showBlockBeginInstructions()
#runBlockLow(feedback = False, reps = 3, blockType = 'actual', saveData = True) # reps * 5 actual trials in this block (then subtracting 3 to get 12)
#runBlockHigh(feedback = False, reps = 6, blockType = 'actual', saveData = True)
#7
#runBlockLow(feedback = False, reps = 3, blockType = 'actual', saveData = True) # reps * 5 actual trials in this block (then subtracting 3 to get 12)
#runBlockHigh(feedback = False, reps = 6, blockType = 'actual', saveData = True)
#8
#runBlockLow(feedback = False, reps = 3, blockType = 'actual', saveData = True) # reps * 5 actual trials in this block (then subtracting 3 to get 12)
#runBlockHigh(feedback = False, reps = 6, blockType = 'actual', saveData = True)
#9
#runBlockLow(feedback = False, reps = 3, blockType = 'actual', saveData = True) # reps * 5 actual trials in this block (then subtracting 3 to get 12)
#runBlockHigh(feedback = False, reps = 6, blockType = 'actual', saveData = True)
#10
#runBlockLow(feedback = False, reps = 3, blockType = 'actual', saveData = True) # reps * 5 actual trials in this block (then subtracting 3 to get 12)
#runBlockHigh(feedback = False, reps = 6, blockType = 'actual', saveData = True)

#showBlockEndInstructions()
#showWaitForRAInstructions()

#end task
showInstructions(text = ["You've completed this task. Well done."])

if sendTTL:
    port.setData(255) #make sure all pins are low

#quit PsychoPy
core.quit()
