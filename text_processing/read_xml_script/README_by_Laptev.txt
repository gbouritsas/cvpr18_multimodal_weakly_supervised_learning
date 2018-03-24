
This directory contains Matlab functions for manipulating,
synchronizing and annotating movie scripts. Current annotation
interface 'annotatevideoevents' enables to attach labels to
arbitrary time intervals of a video. See examples below to get
started, you will need to modify some path-variables to
run them. For more information contact ivan.laptev@inria.fr

Author: Ivan Laptev, INRIA, 2007-2008

Updates:

27-02-2008 Added video annotation tool, see annotatevideoevents.m
           and the corresponding examples below

14-03-2008 Added code for movie script <-> subtitles alignment
           and video frame synchronization. See example and the
           description below under "Subtitle-script alignment"
           section.
-------------------------------------------------------------

Examples:


%%%%%%%%%%%%% load/save/search examples

% read movie script
scrfname='../alignedscripts/American Beauty_labeled_synchronized.xml';
mscr=loadmoviescript(scrfname);

% overlay script with the movie avi
avifname='E:/video/fullmovies/American beauty.(1h56mn38s).avi';
avsfname='American Beauty_overlayed.avs';
overlaymoviescript(mscr,avsfname,avifname);

% save movie script [and check the difference]
savemoviescript(mscr,'c:/temp/script.xml');
mscr2=loadmoviescript('c:/temp/script.xml');
isequal(mscr,mscr2)

% get all monologues
mscr.items(mscr.mind)

% get all scene descriptions
mscr.items(mscr.dind)

% get text from the 100's scene description
mscr.items(mscr.dind(100)).words

% get all annotated instances of GetOutCar action
ind=findcellstr({mscr.items(mscr.dind(:)).labels},{'GetOutCar'})
strvcat(mscr.items(mscr.dind(ind)).words)

% get all annotated classes
setdiff(unique({mscr.items(mscr.dind(:)).labels}),{''})

% get all occurances of the word "kiss" in scene descriptions
ind=findcellstr({mscr.items(mscr.dind(:)).words},{'kiss'})
strvcat(mscr.items(mscr.dind(ind)).words)


%%%%%%%%%%%%% running video annotation example (Windows only, seems not to work with all Matlab versions)

% file names for input video and script
videofname='E:\video\fullmovies\American beauty.(1h56mn38s).avi';
scrfname='../alignedscripts/American Beauty_labeled_synchronized.xml';
% file name for output script (can be the same as input script)
scrfname='../alignedscripts/American Beauty_labeled_synchronized.xml';
% define of annotation labels
labels={'<ActionAnswerPhone>','<ActionGetOutCar>','<ActionHandShake>',...
        '<ActionHugPerson>','<ActionKiss>','<ActionSitDown>',...
	'<ActionSitUp>','<ActionStandUp>'};

% run annotation
annotatevideoevents(videofname,scrfname,labels,'annotatedscript.xml');

% While running the annotation interface you can play/browse the video;
% see the current annotation available in the script; annotate events
% by setting (1) begin/end frame numbers (2) choosing an appropriate
% annotation label and (3) pressing "Add Annotation" button.
% To save annotation DO NOT FORGET to press "SAVE script" button.

% After finishing, you can make sure your annotation has been saved:
annotatevideoevents(videofname,'annotatedscript.xml',labels);

% NOTE: Matlab ActiveX interface seems to have some bugs, if you cannot
% see the full extent of the video frame in the annotation window, do
% restart 'annotatevideoevents' (possibly several)


% anoter annotation example
videofname='E:/video/fullmovies/[DivX-ITA] Casablanca(M.CURTIZ 1942 Bogart-bergman).avi';
scrfname='../alignedscripts/Casablanca_labeled_synchronized.xml';
annotatevideoevents(videofname,scrfname,labels,'annotatedscript.xml');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Subtitle-script alignment

% The following steps
% Here are the steps to follow 

% 1. Parsing
% below is a very simple parser for movie scripts, it is likely to work on
% scripts found on www.weeklyscript.com and www.dailyscript.com It usually
% works or fails complitely, so a simple manual check at the end is sufficient
% to approve or reject the parsing. Here is a working example:

[docNode,checkpassedflag]=moviescript2xml('sources/American Beauty.txt');
str=xmlwrite(docNode);
fd=fopen('American Beauty.xml','w');
fprintf(fd,'%c',str);
fclose(fd);

% 2. Subtitle alignment
% Input: paresed xml movie script (see above); subtitles in .srt text format
% See 'help alignmoviescript' to get description of the method. Two options
% are available: either word-to-word or section-to-section alignment. The
% first one is slow and produces just a little better result (alignemnt score)
% that the secon one, which is "not so slow". The resulting movie script will
% have time information ripped from the subtitles to the monologue and description
% sections. A .html file will be generated as well for the manual check and
% browsing of alignment.

wordtowordflag=0;
ascore=alignmoviescript('sources/American Beauty ENG.srt',...
                        'American Beauty.xml','American Beauty_aligned.xml',...
                        wordtowordflag);

% 3. Synchronization
% Now you also have to convert seconds to frame numbers in order to
% synchronize the aligned script with the movie file. For this, you need
% to estimate the linear time transformation (time_seconds<->frame_numbers)
% frame_number=fps*(a*time_seconds+b) i.e. you need parameters 'a','b','fps'.
% You can get 'fps' automatically with Matlab aviinfo command
% 'a' and 'b' I estimate manually at the moment.

synch=struct('scrfname','American Beauty_aligned.xml',...            % input script
             'synchscrfname','American Beauty_synchronized.xml',...  % output script
             'videofname','American beauty.(1h56mn38s).avi',...      % video file (optional)
             'a',1,...          % time scaling factor
             'b',0,...          % time shift factor
             'fps',24.9950);    % frame-rate of the video file
synchronizemoviescript(synch,'.');

% 4. Check
% To check the alignemnt and the synchronization you now can
% overlay synchronized script with the movie:

mscr=loadmoviescript('American Beauty_synchronized.xml');
avifname='E:/video/fullmovies/American beauty.(1h56mn38s).avi';
avsfname='American Beauty_overlayed.avs';
overlaymoviescript(mscr,avsfname,avifname);
