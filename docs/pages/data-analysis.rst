
=============
Data Analysis
=============

------------------
fMRI Preprocessing
------------------

fmriprep
--------

``fmriprep`` is a pipeline developed by the `Poldrack lab at Stanford University
<https://poldracklab.stanford.edu/>`_ for use at the `Center for Reproducible
Neuroscience (CRN) <http://reproducibility.stanford.edu/>`_, as well as for
open-source software distribution.

``fmriprep`` is designed to provide an easily accessible,
state-of-the-art interface that is robust to variations in scan acquisition
protocols and that requires minimal user input, while providing easily
interpretable and comprehensive error and output reporting.

It performs basic processing steps (coregistration, normalization, unwarping,
noise component extraction, segmentation, skullstripping etc.) providing
outputs that can be easily submitted to a variety of group level analyses,
including task-based or resting-state fMRI, graph theory measures, surface or
volume-based statistics, etc.

.. image:: https://github.com/oesteban/fmriprep/raw/38a63e9504ab67812b63813c5fe9af882109408e/docs/_static/fmriprep-workflow-all.png

The ``fmriprep`` workflow takes as principal input the path of the dataset
that is to be processed.
The input dataset is required to be in valid BIDS (Brain Imaging Data
Structure) format, and it must include at least one T1w structural image and
(unless disabled with a flag) a BOLD series.
We highly recommend that you validate your dataset with the free, online
`BIDS Validator <http://bids-standard.github.io/bids-validator/>`_.

The exact command to run ``fmriprep`` depends on the Installation method.
The common parts of the command follow the `BIDS-Apps
<https://github.com/BIDS-Apps>`_ definition.
Example: ::

    fmriprep data/bids_root/ out/ participant -w work/

Running on a Cluster
--------------------

In order save time it makes sense to do preprocessing on a cluster
(like `SciNet <https://www.scinethpc.ca/>`_). To do so you will need an account.

More information can be found `here`_ about options.

.. _here: http://decisionneurolab.pbworks.com/w/page/132653304/Supercomputers

----
GLMs
----

General linear models were run using ``MATLAB`` and ``SPM 8``.




------------
Correlations
------------

TO BE ADDED...
