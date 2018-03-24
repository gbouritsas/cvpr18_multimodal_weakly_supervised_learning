function preprocess_all(movies)

	global api_key

	% This path needs to get modified.
	% We assume that each movie script has the same name with the movie (extension .txt)
	% and is located in a folder that has also the same name

	movies_folder='~/Documents/movies/';
	list_file=[movies_folder 'filelist1.txt'];

	% Add your TMDB api key below.
	api_key='api_key=';

	k=1;
    i=1;
	files=cell(1,2*size(movies,2));
	for movie_name=movies

		movie_name=cell2mat(movie_name);
		input_folder=fullfile([movies_folder movie_name]);
		movie_name_file=[movie_name '.txt'];
		result_folder=fullfile([movies_folder movie_name '/results_script/']);

		result_folder_for_CoreNLP=fullfile([movie_name '/results_script/']);
		files{k}=fullfile([result_folder_for_CoreNLP movie_name '_preprocessed.txt']);
		files{k+1}=regexprep(movies{i},'^.*$','\r\n');
    i=i+1;
		k=k+2;

		if ~exist(result_folder, 'dir')
			mkdir(result_folder);
		end

		%queries to the TMDB
		if strcmp(movie_name,'BMI')==1
			movie=urlread(['https://api.themoviedb.org/3/search/movie?' api_key '&language=en-US&query=beautiful%20mind&page=1&include_adult=false&year=2001']);
		elseif strcmp(movie_name,'CRA')==1
			movie=urlread(['https://api.themoviedb.org/3/search/movie?' api_key '&language=en-US&query=crash&page=1&include_adult=false&year=2004']);
		elseif strcmp(movie_name,'DEP')==1
			movie=urlread(['https://api.themoviedb.org/3/search/movie?' api_key '&language=en-US&query=the%20departed&page=1&include_adult=false&year=2006']);
		elseif strcmp(movie_name,'GLA')==1
			movie=urlread(['https://api.themoviedb.org/3/search/movie?' api_key '&language=en-US&query=gladiator&page=1&include_adult=false&year=2000']);
		elseif isempty(regexp(regexprep(movie_name,'[0-9]',''),'GWW'))==0
			movie=urlread(['https://api.themoviedb.org/3/search/movie?' api_key '&language=en-US&query=gone%20with%20the%20wind&page=1&include_adult=false&year=1939']);
		elseif strcmp(movie_name,'LOR')==1
			movie=urlread(['https://api.themoviedb.org/3/search/movie?' api_key '&language=en-US&query=lord%20of%20the%20rings%20the%20return%20of%20the%20king&page=1&include_adult=false&year=2003']);
    elseif strcmp(movie_name,'Casablanca')==1
      movie=urlread(['https://api.themoviedb.org/3/search/movie?' api_key '&language=en-US&query=Casablanca&page=1&include_adult=false&year=1942']);
    end

		movie=parse_json(movie);
		movie_id=movie.results{1,1}.id;
		preprocess(movie_name_file,input_folder,result_folder,movie_id)
	end


	fid=fopen(fullfile(list_file), 'w', 'n', 'UTF-8');
	fprintf(fid,'%c',cell2mat(files));
