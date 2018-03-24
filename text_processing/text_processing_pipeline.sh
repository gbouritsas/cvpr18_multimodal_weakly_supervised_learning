matlab -nodisplay -nosplash -nodesktop /r "global movies_folder;
movies_folder = '/Users/giorgosmpouritsas/Documents/movies/';
global api_key;
api_key='api_key=5f63aa856dfa7e1bb5a5ec19cb408f1c';
preprocess_all({'BMI', 'CRA', 'DEP', 'GLA', 'LOR'});
exit;"

java  --add-modules java.se.ee -cp "../stanford-corenlp-full-2018-01-31/*" -Xmx3000m edu.stanford.nlp.pipeline.StanfordCoreNLP -enforceRequirements false -annotators tokenize,ssplit,pos,lemma,ner,depparse -filelist filelist1.txt -outputDirectory serialized_outputs/ -outputFormat serialized
for i in BMI CRA DEP GLA LOR; do
	java --add-modules java.se.ee -cp "../stanford-corenlp-full-2018-01-31/*" -Xmx1200m edu.stanford.nlp.pipeline.StanfordCoreNLP -enforceRequirements false -annotators regexner -file 	serialized_outputs/"$i"_preprocessed.txt.ser.gz -regexner.mapping "$i"/results_script/"$i"_mapping.txt -outputDirectory "$i"/results_script/
done

python parse_xml.all

matlab -nodisplay -nosplash -nodesktop /r "
labels_extractor_all({'BMI' , 'CRA', 'DEP', 'GLA', 'LOR'});
cd read_xml_script;
fps_1=24.9997500025000;
align_subs_script_all({'BMI', 'CRA', 'DEP', 'GLA', 'LOR'},1,[fps_1 fps_1 fps_1 fps_1 fps_1]);
exit;"

python classify_verbs_slow.py

matlab -nodisplay -nosplash -nodesktop /r "
global categories_folder;
categories_folder='../manual_annotation';
global categories_extended_file;
categories_extended_file='/categories_ids.mat';
global categories_small_file;
categories_small_file='/categories_ids_47.mat';
tidy_similarities({'BMI', 'CRA', 'DEP', 'GLA', 'LOR'}, 'wordnet');
exit;"
