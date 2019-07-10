
=============
Data Analysis
=============

---------------
Data Processing
---------------

The `data preprocessing notebook`_ contains the code for:

- Import data from dropbox
- Add columns for analysis
- Clean data
    * Remove poor accuracy subjects
    * Remove really long duration trials



.. note::

    This is a Jupyter notebook. However it is using an R kernel. It is best viewed using `Jupyter Lab`_.

.. _data preprocessing notebook: https://github.com/danieljwilson/MADE/blob/master/3_experiment/3_3_data_analysis_md/ma_clean_data.ipynb

-------------
Behavioral
-------------

The `behavioral analysis notebook`_ contains the code for:

- Basic Psychometrics
    * RT
    * Fixations
    * P(accept) offer
- Performance
- Attention
    * First Fixation
    * First Multiplier
    * Middle Fixation
    * Final Fixation
    * Multiplier Difference
- Multiplier weighting
- Choice ~ Attention & Value



.. note::

    This is a Jupyter notebook. However it is using an R kernel. It is best viewed using `Jupyter Lab`_.


.. _behavioral analysis notebook: https://github.com/danieljwilson/MADE/blob/master/3_experiment/3_3_data_analysis_md/ma_behavioral.ipynb
.. _Jupyter Lab: https://github.com/jupyterlab/jupyterlab

-------------
DDM
-------------

A number of versions of an attentional drift diffusion model (aDDM)
were simulated and fit to the data.

Versions
--------

The versions that have been iterated through, and their fits, can be
viewed via this Jupyter notebook [add notebook].

The data from these simulations lives [update location]

Note that all simulations were run using SciNet.


Running on a Cluster
--------------------

In order to run on a cluster (like SciNet) you will need an account.

More information can be found `here`_ about options.

.. _here: http://decisionneurolab.pbworks.com/w/page/132653304/Supercomputers

