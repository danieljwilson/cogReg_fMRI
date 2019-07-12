==================
Experiment Details
==================

---------
Protocols
---------

The experiment protocol is located on Dropbox at:
``DJW_Projects/02_FOOD_REG/PAPERWORK/fMRI_Food_Regulation_Experiment_Protocol.gdoc``

The fMRI scan protocol is `here`_.

.. _here: https://github.com/danieljwilson/cogReg_fMRI/blob/master/3_experiment/3_1_inputs/fMRI_protocol.pdf

---------
Main Task
---------

The main task involved three discreet phases.

1. Pre-Scan

   - Food liking ratings
   - Main task training

2. Scan

   - In-scanner trials

     - 9 runs

3. Post-Scan

   - Food liking ratings (repeated)
   - Food taste ratings
   - Food health ratings

=====

The code for the Main Task (including the instructions)
was written in ``MATLAB`` and uses `Psychtoolbox`_.

The `Main Task Code`_ includes many files, but the key scripts are:

- ``runPreMRI.m``

  - Launches the experiment instructions and the initial Food Liking Rating

- ``runSession.m``

  - Launches a run of the experiment in-scanner

- ``runPostMRI.m``

  - Launches the post task ratings of Liking, Taste, and Health

.. _Psychtoolbox: http://psychtoolbox.org/
.. _Main Task Code: https://github.com/danieljwilson/cogReg_fMRI/tree/master/3_experiment/3_1_inputs/main_matlab

----------
Localizers
----------

The localizer task invovled two discreet phases.

1. Pre-Scan

   - Localizer task training

2. Scan

   - In-scanner trials

     - go-nogo: 2 runs
     - switching task: 1 run

The code for the Localizers was written in ``Python``,
using the `Psychopy`_ toolbox.

.. _Psychopy: https://www.psychopy.org/


Go-NoGo
-------

The `Go-NoGo task scripts`_ include both a ``practice`` and ``fMRI`` version.
The main difference is that the fMRI version waits for the scanner
to send a **5** to progress.

The Go-NoGo task  was based on `Wager et al. 2005`_.
We used the letters ‘m’ and ‘w’ as the ‘go’ and ‘no-go’ stimuli,
requiring the execution or withholding, respectively, of a keypress
response (counterbalanced).

After presentation of a 500ms fixation cross, participants had 450ms
to respond to the stimulus.

There were two types of blocks presented: low-go blocks, in which 20%
of the trials required a response, and high-go blocks, in which 50%
of trials required a response. The beginning and ends of these blocks
were not indicated to participants.

A total of 24 blocks (12 of each condition), containing 12 trials
each--a total of 288 trials--were presented. The rapid event-related
design with clustered events is expected to maximize power (`Liu 2004`_).
The task was broken into two equal (144 trial) sessions for scanning
to reduce fatigue.

.. _Go-NoGo task scripts: https://github.com/danieljwilson/cogReg_fMRI/tree/master/3_experiment/3_1_inputs/localizers_psychopy/GoNoGo
.. _Wager et al. 2005: https://www.ncbi.nlm.nih.gov/pubmed/16019232
.. _Liu 2004: https://www.ncbi.nlm.nih.gov/pubmed/14741677


Switching Task
--------------
The `switching task scripts`_ also include both a ``practice`` and
``fMRI`` version. The main difference is that the fMRI version waits
for the scanner to send a **5** to progress.

The attention switching task showed subjects a pair of images, one
face and one house, on each trial. The images were overlaid directly
on top of each other with each image’s opacity reduced so that both
images could be clearly deciphered. On each trial subjects were
directed to focus their attention either on the Face or the House
image, which was indicated both by text on screen indicating “Face”
or “House” and the background color of the image (i.e. a different
background color for Faces andHouses). On Face trials, subjects had
to determine the face’s gender, using a keypress to indicate their
response. On House trials, subjects had to indicate whether it was
an old or modern house, using a keypress to indicate their response.

There were four total response possibilities, and four corresponding
buttons to press. Participants had up to 1 second to respond.
The inter trial interval was between 1s and 6s, uniformly distributed.
A total of 80 trials were presented in a single session.

.. _switching task scripts: https://github.com/danieljwilson/cogReg_fMRI/tree/master/3_experiment/3_1_inputs/localizers_psychopy/Switching

--------------
Questionnaires
--------------

Upon completion of all tasks we asked subjects to
complete the following questionnaires:

1. `Three-Factor Eating Questionnaire`_

2. `Rapid Food Screener`_

3. `Barrat BIS 11`_

4. `Perceived Stress Scale`_


There is also a `questionnaire key`_, that will be helpful
for data analysis.

.. _Three-Factor Eating Questionnaire: https://github.com/danieljwilson/cogReg_fMRI/blob/master/3_experiment/3_1_inputs/scales/de%20Lauzon_2004_The%20Three-Factor%20Eating%20Questionnaire-R18%20is%20able%20to%20distinguish%20among%20different%20eating%20patterns%20in%20a%20general%20population.pdf
.. _Rapid Food Screener: https://github.com/danieljwilson/cogReg_fMRI/blob/master/3_experiment/3_1_inputs/scales/Block_2000_A%20rapid%20food%20screener%20to%20assess%20fat%20and%20fruit%20and%20vegetable%20intake.pdf
.. _Barrat BIS 11: https://github.com/danieljwilson/cogReg_fMRI/blob/master/3_experiment/3_1_inputs/scales/Barratt_BIS11.pdf
.. _Perceived Stress Scale: https://github.com/danieljwilson/cogReg_fMRI/blob/master/3_experiment/3_1_inputs/scales/PerceivedStressScale.pdf
.. _questionnaire key: https://docs.google.com/spreadsheets/d/1Z4bNA8LhkTxmBhc5ek14_AW4EsdOsEmLD2UNJL5FyRg/edit?usp=sharing
