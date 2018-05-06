function final_labels_all(movies,cast_list_flag,person_tagnames,action_tagnames,similarity_method)
	%	FINAL_LABELS_ALL(movies,cast_list_flag,person_tagnames,action_tagnames)
	%	MOVIES is a cell array of names of movie folders
	%	CAST_LIST_FLAG : when true the only weak labels allowed are part of the cast list
	%	PERSON_TAGNAMES : cell array with allowed values :'speaker','description','dialogue','scene','unkwnown'. Indicates the parts of the script from which
	%					the person weak labels are extracted
	%	ACTION_TAGNAMES : cell array with allowed values :'speaker','description','dialogue','scene','unkwnown'. Indicates the parts of the script from which
	%					the action weak labels are extracted
  %   SIMILARITY_METHOD: chose method of precomputed similarities, e.g
  %   'wordnet','word2vec','glove','fasttext','sent2vec',....

	addpath('script_to_subtitle_DTW')
	global movies_folder
	global categories_folder
	global categories_extended_file
	categories_file = fullfile([categories_folder categories_extended_file]);
	for movie_name=movies

		movie_name=cell2mat(movie_name);
		input_folder=fullfile([movies_folder movie_name '/results_script']);
		result_folder=fullfile([movies_folder movie_name '/results_script']);

		person_names_file=[movie_name '_init_person_labels.mat'];
		original_tags_file=[movie_name '_person_tags.mat'];

    similarities_file=[movie_name '_similarities_' similarity_method '_69.mat'];
		sentences_file=[movie_name '_sentences.mat'];
		dependencies_file=[movie_name '_dependencies.mat'];
		scrfname=[movie_name '_synchronized.xml'];

		disp(['Extracting final person and action labels using timestamps from the alignment procedure ...'] )
		[person_labels,action_labels]=final_labels(input_folder,scrfname,...
		person_names_file,cast_list_flag,original_tags_file,person_tagnames,...
		categories_file,similarities_file,sentences_file,dependencies_file,...
		action_tagnames);

		save(fullfile([result_folder '/' movie_name '_final_person_labels.mat']),'person_labels');
    save(fullfile([result_folder '/' movie_name '_final_action_labels_' similarity_method '.mat']),'action_labels');


	end
end
