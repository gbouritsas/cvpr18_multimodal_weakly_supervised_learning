Description
=====================================
Code
=====================================
### face-pipeline (MATLAB) : 
This code is adapted from Piotr Bojanowski (https://github.com/piotr-bojanowski/face-pipeline) and it is based on [1],[2] and [3]. The main modifications are:

- parallel implementation of the code
- small modifications in the formation of the face tracks (detector score threshold, post-processing of face tracks)
- added code to represent faces with VGG
- modified the computation of kernels (the detector scores are not taken into account)

Prior to running the code you will have to:

1. Split each video into individual frames . 
2. Download VLFeat http://www.vlfeat.org/download.html (Our code is tested with VLFeat 0.9.21) . 
3. Download MatConvNet http://www.vlfeat.org/matconvnet (Our code is tested with MatConvNet 1.0-beta25) . 
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

To manually annotate face tracks run:
```
check_tracks
```

2)text_processing (MATLAB + PYTHON, WINDOWS to run the batch files - not very important): text pipeline as described in the thesis
all1.bat :
	preprocess_all:	preprocesses the scripts,
					transforms them to the format used for the script segmentation (MONOLOGUE, DESCRIPTION, etc.)
					downloads cast list from TMDB (personal api key needed) ,preprocesses it and saves the query regular expressions
	calls StanfordCoreNLP (needs to be downloaded) annotators : tokenize,ssplit,pos,lemma,depparse
	calls StanfordCoreNLP ner (optional), regexner (regular expressions created by preprocess_all
all2.bat :
	parse_xml_all: 	parses the xml output of StanfordCoreNLP
	labels_extractor_all : processes StanfordCoreNLP output and creates initial labels, short sentences, etc.
	align_subs_script_all : applies script segmentation and script to subtitle alignment
							(credits to Dr. Bojanowski - I made small modifications on the code)
	classify_verbs_slow	 : calculates semantic similarity
	tidy_similarities : creates similarity vectors
3)my-actor-action (MATLAB) : learning algorithms - based on the code used for Bojanowski et. al 2013
	typical execution:
	a) 	final_labels_all(movies,cast_list_flag,person_tagnames,action_tagnames) : extracts final labels from the outputs of text pipeline
	b) 	prepare_for_opt* :	prepares the matrices that participate in the optimization procedure
							* ='' ->action recognition
							* =_face ->face recognition
							* =_face_prior ->action recognition using knowledge from face
							* =_prior -> action recognition with prior knowledge
	c)	main (needs MOSEK)

The scripts listed below indicate the usage of the prepare_for_opt* functions and the values of the global variables for the optimization
multiple_experiments_face : variety of experiments on face -
multiple_experiments_action : variety of experiments on action -
optimize_actor_action :		variety of experiments on action using knowledge from face
optimize_with_prior : variety of experiments on action using prior knowledge from a pre-trained classifier
------------------------------------------------------------------------------------------------------------------
								DATA
1)manual_annotation_manipulation : extraction of the annotated labels and store as matlab structures
References
=====================================
[1] M. Everingham, J. Sivic and A. Zisserman. "Hello! My name is... Buffy" - Automatic Naming of Characters in TV Video. BMVC 2006.
[2] J. Sivic, M. Everingham and A. Zisserman. "Who are you?" : Learning person specific classifiers from video. CVPR 2009.

[3] P. Bojanowski, F. Bach, I. Laptev, J. Ponce, C. Schmid, and J. Sivic: Finding actors and actions in movies, ICCV 2013
