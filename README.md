Description
=====================================
The implementation of the CVPR 2018 paper "Multimodal Visual Concept Learning with Weakly Supervised Learning Techinques" [1].

We provide the end-to-end system of weakly supervised face recognition. In particular the system comprises of three components: 1) face pipeline, 2) script pipeline, 3) multimodal weakly supervised learning. The implementation of 1) and 3) builds on previous code from Dr. Piotr Bojanowski (https://github.com/piotr-bojanowski/face-pipeline and https://github.com/piotr-bojanowski/actor-action respectively). We also thank Dr. Bojanowski for the implementation of the Dynamic Time Warping algorithm for the script-subtitle alignment.

We also provide the system of weakly supervised action recognition, using pre-computed action features.

Code
=====================================
### face-pipeline (MATLAB) :
This code is based on [2],[3] and [4]. The main modifications are:

- parallel implementation of the code
- small modifications in the formation of the face tracks (detector score threshold, post-processing of face tracks)
- added code to represent faces with VGG
- modified the computation of kernels (the detector scores are not taken into account)

Prior to running the code you will have to:

1. Split each video into individual frames .
2. Download VLFeat: http://www.vlfeat.org/download.html (Our code is tested with VLFeat 0.9.21) .
3. Download MatConvNet: http://www.vlfeat.org/matconvnet (Our code is tested with MatConvNet 1.0-beta25) .
4. Modify the paths in the files main.m, main_vgg.m and main_kernels.m .

The code for the extraction of the VGG descriptor is set to run on GPU. In case GPU is not available modify the main_vgg.m file as follows:
```
GPU=false
```
To run the code type:
```
a. compile : compiles the mex functions
b. main: runs the modified face pipeline (faces are represented with SIFT descriptors)
c. main_vgg: extracts the VGG-face representation
d. main_kernels: computes the kernels (both from VGG and SIFT).
```

To manually annotate face tracks run (the paths need to be modified here as well):
```
check_tracks
```

### text_processing (MATLAB + Python):

This code implements the text processing pipeline as described in the paper [1].

1. Download and setup (set up your classpath) StanfordCoreNLP: https://stanfordnlp.github.io/CoreNLP/download.html (Our code is tested with CoreNLP 3.9.1)
2. Modify the global variable movies_folder in order to point to the folder where your movies are saved (See text_processing README for more information).
3. Modify the global variables categories_folder, categories_extended_file, categories_small_file in order to point in the files where your action categories are saved (See text_processing README and 'Data' section for more information). Also you can modify the sentence similarity method.
4. Sign up to TMDB: https://www.themoviedb.org/, obtain an api_key and set the corresponding global variable (See text_processing README for more information). For new movies you need to form new queries to the database.
5. We assume that the movie script and the subtitles files have the same name with the movie (extension .txt and .srt.txt respectively) and are located in a folder that has also the same name.
6. The script files need to comply with the common screenplay format rules (in terms of indentation and capitalisation) in order to be properly segmented. The format is the following:

```
SCENE
        SPEAKER
	Monologue
Description
```
For example:
```
EXT. FOOTHILLS OF WHITE MOUNTAINS - DAY (SCENE)

ANGLE ON: SHADOWFAX powers along the COUNTRYSIDE.
ANGLE ON: PIPPIN, huddled in front of GANDALF, the WIND
sailing through his hair. (Description)

                      GANDALF (SPEAKER)
           We have just passed into the realm of
           Gondor! (Monologue)
```

You can find the commands for the entire text processing pipeline in the text_processing README.

### multimodal_weakly_supervised_learning (MATLAB + mosek):

This code implements the weakly supervised learning algorithm as described in the paper [1] and runs the related experiments.

1. Download and setup MOSEK for MATLAB https://docs.mosek.com/8.1/toolbox/install-interface.html (Our code is tested with MOSEK 8.1)
2. Modify the paths in learn_faces.m, learn_actions.m similarly to the previous components of the system.
3. In order to run the experiments of the algorithm on the visual concept of faces run :

```
learn_faces: (MATLAB)
```

4. In order to run the experiments of the algorithm on the visual concept of actions run :
```
learn_actions: (MATLAB)
```

5. In learn_{faces,actions}.m you can modify the hyperparameters of the optimization algorithm, as well as other parameters involved in the method, in order to run custom experiments. A typical execution of the algorithm for custom experiments should be:

```
a. prepare_for_opt_{face,action}(parameters): prepares the matrices that participate in the optimization procedure. See learn_{faces,actions}.m for more details regarding the parameters
b. result = main (movie_name, coordinate): executes the optimization, coordinate can be either 'face' or 'action'
```

Data
=====================================
1. You can find the - necessary for the learning algorithm - outputs of the face and action pipeline (precomputed features/kernels), as well as those of the script pipeline (person/action labels) in . We also provide the ground truth of the examples.
2. Our action categories can be found in the same link in the file manual_annotation/categories_ids_47.mat. An extended version of the categories is provided in manual_annotation/categories_ids.mat.


References
=====================================
[1] G. Bouritsas, P. Koutras, A. Zlatintsi and P. Maragos. Multimodal Visual Concept Learning with Weakly Supervised Learning Techinques. CVPR 2018

[2] M. Everingham, J. Sivic and A. Zisserman. "Hello! My name is... Buffy" - Automatic Naming of Characters in TV Video. BMVC 2006.

[3] J. Sivic, M. Everingham and A. Zisserman. "Who are you?" : Learning person specific classifiers from video. CVPR 2009.

[4] P. Bojanowski, F. Bach, I. Laptev, J. Ponce, C. Schmid, and J. Sivic. Finding actors and actions in movies. ICCV 2013
