function checkpassedflag=align_subs_script_all(movies,wordtowordflag,fps)
	i=1;

	global movies_folder

    for movie_name=movies

		movie_name=cell2mat(movie_name);
		input_folder=fullfile([movies_folder movie_name]);
		results_folder=fullfile([movies_folder movie_name '/results_script']);
		scr_name=[movie_name '_for_parsing.txt'];
		scr_xml_name=[movie_name  '.xml'];
		wordname=[movie_name  '_word_ids.mat'];
		disp(['Converting ' scr_name ' to xml ' scr_xml_name ' (scene/speaker/description/monologue annotation and more)...'] )
		[docNode,checkpassedflag]=moviescript2xml(fullfile([results_folder '/' scr_name]),fullfile([results_folder '/' wordname]));
		str=xmlwrite(docNode);
		fd=fopen(fullfile([results_folder '/' scr_xml_name]),'w');
		fprintf(fd,'%c',str);
		fclose(fd);

		subsname=[movie_name  '.srt.txt'];
		outname=[movie_name  '_aligned.xml'];
		ascore=alignmoviescript(fullfile([input_folder  '/' subsname]),fullfile([results_folder '/' scr_xml_name]),fullfile([results_folder '/' outname]),wordtowordflag);
		extname=[movie_name  '_aligned_extended.xml'];
		extendmoviescript(outname,extname,results_folder)
		synchname=[movie_name  '_synchronized.xml'];
		synch=struct('scrfname',extname, 'synchscrfname',synchname,   'videofname',[movie_name '.avi'] ,'a',1,'b',0,'fps',fps(i));        % input script
                    % output script
                    % video file (optional)
                    % time scaling factor
                    % time shift factor
                    % frame-rate of the video file
		synchronizemoviescript(synch,results_folder,input_folder);
		i=i+1;
	end
end
