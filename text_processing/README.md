Prior to running the commands below you should set some global variables in order to point to the correct files. This needs to be done both in MATLAB and Python:
```
global movies_folder; movies_folder='/Users/giorgosmpouritsas/Documents/movies/';
global api_key; api_key='api_key=';
global movies; movies = {'BMI', 'CRA', 'DEP', 'GLA', 'LOR'}; % in Python: ['BMI', 'CRA', 'DEP', 'GLA', 'LOR']
global categories_folder; categories_folder='../manual_annotation/';
% In case some of the action categories are removed, the remaining should be placed in this file.
global categories_small_file; categories_small_file='categories_ids_47.mat';
% If no categories are removed then categories_small_file and categories_extended_file should point to the same file
global categories_extended_file; categories_extended_file='/categories_ids.mat';
```

### MATLAB:
```
preprocess_all(movies);
```

### Terminal:

This should be run from the movies_folder directory:
```
java  --add-modules java.se.ee -cp "*" -Xmx3000m edu.stanford.nlp.pipeline.StanfordCoreNLP -enforceRequirements false -annotators tokenize,ssplit,pos,lemma,depparse -filelist filelist1.txt -outputDirectory serialized_outputs/ -outputFormat serialized

for i in BMI CRA DEP GLA LOR; do
	java --add-modules java.se.ee -cp "*" -Xmx1200m edu.stanford.nlp.pipeline.StanfordCoreNLP -enforceRequirements false -annotators regexner -file 	serialized_outputs/"$i"_preprocessed.txt.ser.gz -regexner.mapping "$i"/results_script/"$i"_mapping.txt -outputDirectory "$i"/results_script/
done
```

### Python:

```
parse_xml_all(movies)
```

### MATLAB

```
labels_extractor_all(movies);
cd read_xml_script;
fps=24.9997500025000 * ones(length(movies)); % Vector containing the fps of each video
align_subs_script_all(movies ,1, fps); % the script-subtitle DTW algorithm
```

### Python

```
similarity_method = 'wordnet';
classify_verbs_all(movies, similarity_method)
```

### MATLAB

```
similarity_method = 'wordnet';
tidy_similarities(movies, similarity_method) ;
face_annotation(movies);

cast_list_flag=1; %only names in cast list are chosen as labels.
person_tagnames={'speaker','description','unknown'};% extract labels only from these parts of the text
action_tagnames={'description','unknown'};% extract labels only from these parts of the text

final_labels_all(movies, cast_list_flag, person_tagnames, action_tagnames, similarity_method);
```
