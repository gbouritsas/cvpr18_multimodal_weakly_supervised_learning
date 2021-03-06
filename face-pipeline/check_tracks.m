% Moidfy this according to each movie
movie_name='BMI';
% Paths need to be modified
dump_dir = ['/Data/gbouritsas_thesis/movies/' movie_name '/frames/'];
result_dir  = ['/Data/gbouritsas_thesis/movies/' movie_name '/results_face'];


dump_string = [dump_dir '/image-%06d.png'];
facedetfname    = 'facedets.mat';
facedetpath     = fullfile(result_dir, facedetfname);
load(facedetpath);

track = cat(1, facedets.track);
[a,b]=sort(track);
facedets=facedets(b);
track = cat(1, facedets.track);
utrack = unique(track);
f   = cat(1, [], facedets.frame);
rect    = cat(2, [], facedets.rect);
rect=rect';


%%ama thes na ksekinhseis apo endiameso track allazeis to i=1:length(utrack) kai vazeis to noumero ths grammhs tou txt apo thn opoia %%theleis na ksekinhseis ,dhladh to noumero tou unique track. OXI TO NOUMERO TOU TRACK. P.x ama exeis meinei sthn grammh 49 kai to noumero tou track einai 65 kai theleis na ksanadeis authn thn grammh, tote vazeis i=49:length(utrack)
uicontrol('Style', 'pushbutton','String','continue','CallBack','cflag=1;uiresume');
for i=1:length(utrack);
	cflag=0;
	track_ind=find(track==utrack(i));
	for j=1:length(track_ind)
		r = rect(track_ind(j),:);
		box = [r(1) r(3) r(2)-r(1)+1 r(4)-r(3)+1];
		if (cflag)
			break;
		end
		%clf;
		image(imread(fullfile(sprintf(dump_string, f(track_ind(j))))));
		axis image off
		hold on;
		rectangle('Position', box, 'EdgeColor', 'red', 'LineWidth', 2);
		hold off;
		title([sprintf('frame %d ',f(track_ind(j))) sprintf('track %d',utrack(i))]);
		drawnow;

	end
	if cflag==0
		uiwait;
	end

end
