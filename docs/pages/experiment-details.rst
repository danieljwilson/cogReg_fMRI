==================
Experiment Details
==================

Recall that the experiment protocol is located on Dropbox at:
``DJW_Projects/02_FOOD_REG/PAPERWORK/fMRI_Food_Regulation_Experiment_Protocol.gdoc``


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

The localizer task invovled two descreet phases.

1. Pre-Scan

   - Localizer task training

2. Scan

   - In-scanner trials

     - go-nogo: 2 runs
     - switching task: 1 run

The code for the Localizers was written in ``Python``,
using the `Psychopy`_ toolbox.

There are two key scrtips CONTINUE FROM HERE

.. _Psychopy: https://www.psychopy.org/

--------------
Questionnaires
--------------

Upon completion of all tasks we asked subjects to
complete the following questionnaires:

1. CONTINUE FROM HERE

LINK TO QUESTIONNAIRES GOOGLE SHEET
