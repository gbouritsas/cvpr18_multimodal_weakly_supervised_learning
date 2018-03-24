function labels_extractor_all(movies)

    for movie_name=movies

    global movies_folder

		movie_name=cell2mat(movie_name);
		input_folder=fullfile([movies_folder movie_name '/results_script']);
		struct_name=[movie_name '_preprocessed_struct.mat'];
		person_tags_name=[movie_name '_person_tags.mat'];
		result_folder=fullfile([movies_folder movie_name '/results_script']);

    disp(['Extracting metadata from ' struct_name '...'] )
		[person_names,word_ids,dependencies,sentences_with_ids]=labels_extractor_simple(struct_name,person_tags_name,input_folder);
		disp(['Writing person labels, word_ids, dependencies and sentences for the sentence similarity algorithm in the folder:' result_folder '...'])
		save(fullfile([result_folder '/' movie_name '_init_person_labels.mat']),'person_names');
		save(fullfile([result_folder '/' movie_name '_word_ids.mat']),'word_ids');
		save(fullfile([result_folder '/' movie_name '_dependencies.mat']),'dependencies');
		save(fullfile([result_folder '/' movie_name '_sentences.mat']),'sentences_with_ids');

    end

end
