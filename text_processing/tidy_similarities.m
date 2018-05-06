function tidy_similarities(movies,method)

	%These paths needs to get modified
	global movies_folder
	global categories_folder
	global categories_small_file
	global categories_extended_file

	for movie_name=movies
		movie_name=cell2mat(movie_name);

		input_folder=fullfile([movies_folder movie_name '/results_script']);
		result_folder=input_folder;

		categories_file=fullfile([categories_folder categories_extended_file]);
		load(categories_file)
		old_categories=categories_ids;

		categories_file=fullfile([categories_folder categories_small_file]);
		load(categories_file)
		new_categories=categories_ids;

        clear sentences_embeddings_all
		similarities_file_input=[movie_name '_similarities_' method '_47.mat'];
		load(fullfile([input_folder '/' similarities_file_input]))

		old_ids=cat(1,[],old_categories.ids);
		similarities_all_new=cell(1,length(similarities_all));
        

		new_ids=cat(1,[],new_categories.ids);
		for i=1:length(similarities_all_new)
            similarities_all_new{i}=zeros(1,length(old_ids));
			similarities_all_new{i}(new_ids)=similarities_all{i};
        end
        
		similarities_all=similarities_all_new;
        if exist('sentences_embeddings_all')==0
            sentences_embeddings_all = zeros(length(similarities_all),1);
        end   
		similarities_file_output=[movie_name '_similarities_' method '_69.mat'];
		save(fullfile(result_folder,similarities_file_output),'similarities_all','sentences_embeddings_all');
	end
