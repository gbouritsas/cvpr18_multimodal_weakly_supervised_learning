function preprocess( movie_name ,input_folder ,result_folder,movie_id)
	[pathstr,name_wout_ext,ext]=fileparts(movie_name);
	disp(['Preprocessing ' movie_name '...'])
	fid=fopen(fullfile([input_folder '/' movie_name]), 'r', 'n', 'UTF-8');
	text=fscanf(fid,'%c');

	[text_original_case,text_init_uppercase]=preprocessing_for_parsing(text);
	disp(['Writing original script with proper identation to ' name_wout_ext  '_for_parsing.txt...'])
	fid=fopen(fullfile([result_folder '/' name_wout_ext  '_for_parsing.txt']), 'w', 'n', 'UTF-8');
	fprintf(fid,'%c',text_original_case);

	disp(['Writing script with  with proper identation and proper capitalization to ' name_wout_ext  '_preprocessed.txt...'])
	fid=fopen(fullfile([result_folder '/' name_wout_ext  '_preprocessed.txt']), 'w', 'n', 'UTF-8');
	fprintf(fid,'%c',text_init_uppercase);
	fclose('all');

  [cast_list_original,tags_regex,tags,classes]=cast_list_extractor(movie_id);
	disp(['Writing original cast list to ' name_wout_ext  '_cast_list.mat...'])
	save(fullfile([result_folder '/' name_wout_ext '_cast_list.mat']),'cast_list_original');

	disp(['Writing regular expressiong mapping to ' name_wout_ext  '_mapping.txt...'])
	fid=fopen(fullfile([result_folder '/' name_wout_ext '_mapping.txt']), 'w', 'n', 'UTF-8');
	fprintf(fid,'%c',cell2mat(tags_regex));

	disp(['Writing person tags and class ids to ' name_wout_ext  '_person_tags.mat...'])
	save(fullfile([result_folder '/' name_wout_ext '_person_tags.mat']),'tags','classes');
	fclose('all');
end
