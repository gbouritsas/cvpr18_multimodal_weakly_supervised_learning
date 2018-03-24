Description
=====================================
Code
=====================================
### face-pipeline (MATLAB) :
This code is adapted from Piotr Bojanowski (https://github.com/piotr-bojanowski/face-pipeline) and it is based on [2],[3] and [4]. The main modifications are:

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

### text_processing (MATLAB + Python):

  Check text_processing_pipeline.sh
This code implements the text processing pipeline as described in the paper [1].

1. Download and setup (set up your classpath) StanfordCoreNLP https://stanfordnlp.github.io/CoreNLP/download.html (Our code is tested with CoreNLP 3.9.1)
2. Modify the path in the files preprocess_all.m, parse_xml.py, labels_extractor_all.m, align_subs_script_all.m, classify_verbs.py, tidy_similarities.m in order to point to the folder where your movies are saved. This can be done by running the following commands in MATLAB and Python
```
global movies_folder
movies_folder = '/Users/giorgosmpouritsas/Documents/movies/';
```
3. Modify the path in the file classify_verbs.py and tidy_similarities.m in order to point in the folder where your action categories are saved. We provide our action categories in categories_ids_47.mat and in an extended version categories_ids.mat. Also you can modify the sentence similarity method. This can be done by running the following commands in MATLAB and Python
```
global categories_folder
categories_folder='../manual_annotation';

global categories_extended_file
categories_extended_file='/categories_ids.mat';

global categories_small_file
categories_small_file='/categories_ids_47.mat';
```
4. Sign up to TMDB, obtain an api_key and add it to preprocess_all.m. For new movies you need to form new queries to the database.
5. We assume that the movie script and the subtitles files have the same name with the movie (extension .txt and .srt.txt respectively) and are located in a folder that has also the same name.
6. The script files need to comply with the common screenplay format rules (in terms of indentation and capitalisation) in order to be properly segmented. The format is the following:

```
SCENE
        SPEAKER
	Monologue
Description
```
add example here


The entire text processing pipeline can be executed with the following commands:

```
a. preprocess_all({'BMI', 'CRA', 'DEP', 'GLA', 'LOR'}):	(MATLAB) preprocesses the scripts, fixes indentation and capitalisation, extracts the cast list from TMDB and transforms it to query regular expressions, creates a a file that contains the paths for the movies that need to be processed
```

```
Go to the folder where your movies are saved, open a terminal and run:

b. java  --add-modules java.se.ee -cp "../stanford-corenlp-full-2018-01-31/*" -Xmx3000m edu.stanford.nlp.pipeline.StanfordCoreNLP -enforceRequirements false -annotators tokenize,ssplit,pos,lemma,depparse -filelist filelist1.txt -outputDirectory serialized_outputs/ -outputFormat serialized:  Executes all the necessary annotators in order to perform the dependency parsing on each document (Optionally you can add ner).

Modify this movie list if necessary
c. for i in BMI CRA DEP GLA LOR; do
	java --add-modules java.se.ee -cp "../stanford-corenlp-full-2018-01-31/*" -Xmx1200m edu.stanford.nlp.pipeline.StanfordCoreNLP -enforceRequirements false -annotators regexner -file 	serialized_outputs/"$i"_preprocessed.txt.ser.gz -regexner.mapping "$i"/results_script/"$i"_mapping.txt -outputDirectory "$i"/results_script/
done: Annotates the script with person labels according to the regular expression queries.
```

```
d. python parse_xml_all: parses the xml output of CoreNLP (Our code is tested with Python 3.6.3)
e. labels_extractor_all({'BMI' , 'CRA', 'DEP', 'GLA', 'LOR'}) :(MATLAB) 	Extracts person labels from the CoreNLP annotation and creates short sentences for the sentence similarity algorithm
f.  cd read_xml_script;
fps_1=24.9997500025000;
align_subs_script_all({'BMI', 'CRA', 'DEP', 'GLA', 'LOR'},1,[fps_1 fps_1 fps_1 fps_1 fps_1]): (MATLAB) segments the scripts and performs the crude alignment between the script and the subtitles - the code was obtained from Dr. Bojanowski and got slightly modified
g. python classify_verbs_all.py: Implements various sentence similarity algorithms
h. tidy_similarities({'BMI', 'CRA', 'DEP', 'GLA', 'LOR'}, 'wordnet'): (MATLAB) Post-processing of the similarity vectors - change the similarity method if necessary. The 'wordnet' method (hybrid LSA + wordnet [5]), is time consuming because it makes http requests to the author's online API.
i. face_annotation({'BMI', 'CRA', 'DEP', 'GLA', 'LOR'}) : (MATLAB) processing of the manual annotations to match the automatic annotations of the text
```

### multimodal_learning_weakly_supervised (MATLAB + mosek):


```
learn_faces.m : modify the paths for script, faces, annotation: run face_annotation, code extended from Dr. Bojanowski
```

3)my-actor-action (MATLAB) : learning algorithms - based on the code used for Bojanowski et. al 2013
	typical execution:
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
[1] G. Bouritsas, P. Koutras, A. Zlatintsi and P. Maragos. Multimodal Visual Concept Learning with Weakly Supervised Learning Techinques. CVPR 2018
[2] M. Everingham, J. Sivic and A. Zisserman. "Hello! My name is... Buffy" - Automatic Naming of Characters in TV Video. BMVC 2006.
[3] J. Sivic, M. Everingham and A. Zisserman. "Who are you?" : Learning person specific classifiers from video. CVPR 2009.
[4] P. Bojanowski, F. Bach, I. Laptev, J. Ponce, C. Schmid, and J. Sivic. Finding actors and actions in movies. ICCV 2013
[5] L. Han, A. Kashyap, T. Finin, J. Mayfield, and J. Weese.
Umbc ebiquity-core: Semantic textual similarity systems. *SEM, 2013
