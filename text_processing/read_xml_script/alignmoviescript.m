function ascore=alignmoviescript(subfname,scrfname,scroutfname,wordtowordflag)

% ascore=alignmoviescript(subfname,scrfname,scroutfname,wordtowordflag)
%
%  Does alignment of a movie transcript saved in .xml file 'scrfname'
%  (see moviescript2xml function for producing an appropriate .xml)
%  with the subtitles in the .srt file 'subfname'. 
%  The resulting .xml file 'scroutfname' will contain the same script as
%  in the original 'scrfname' file but with the time information inserted
%  for 'monologue' and 'description' parts. The time information is
%  infered from the subtitle file by means of matching dialogs.
%  If 'wordtowordflag'=true (default) the word-to-word DTW alignment
%  will be used (slow). Otherwise a section-to-section alignment will
%  be used. Each text section in subtitles and monologue sections
%  in movie scripts will be represented by bag-of-words and matched
%  by DTW.
  
if nargin<4 wordtowordflag=1; end

%read input
fprintf('read subtitles from %s\n',subfname)
sub=parsesubtitles(subfname);
fprintf('read transcript from %s\n',scrfname)
%scr=parsexmlscript(scrfname);
mscr=loadmoviescript(scrfname);

if 0 % cut script: DEBUG
  mscr.items=mscr.items(1:602);
  sub=sub(1:250);
end

scr=mscr.items;

% convert script text to the cell array of unpunctuated low-case words
for i=1:length(scr)
  scr(i).origstring=scr(i).words;
  scr(i).words=regexp(lower(scr(i).words),'\w*','match');
end

% reset script alignment
for i=1:length(scr)
  scr(i).begin_time=[0 0 0];
  scr(i).end_time=[0 0 0];
end
% select monologues from the script
ind=findcellstr({scr(:).tagname},{'monologue'});
scrmono=scr(ind);

%keyboard

% align subtitles to transcript monologues
if wordtowordflag
  % word-to-word approach
  [p,q,subnew]=alignwordbyword(sub,scrmono);
  sub=subnew;
else
  %  bags-of-words approach
  [p,q]=alignbagsofwords(sub,scrmono);
end

%keyboard
%for i=1:length(p)
%  fprintf('%s\n%s\n\n',subnew(p(i)).origstring,scrmono(q(i)).origstring)
%  pause
%end

% transfer time from matched sub to scr and write .html
qscr=ind(q);
htmlfname=regexprep(scroutfname,'.xml','.html');
scraligned=subtime2script(sub,scr,p,qscr,htmlfname,subfname,scrfname);

% alignment score
ascore=mean([scraligned(:).ascore]);
fprintf('alignment completed: ascore=%1.3f\n',ascore)

% write aligned script to .xml
%script2xml(scraligned,scroutfname,ascore);
mscraligned=mscr;
mscraligned.ascore=ascore;
mscraligned.items=scraligned;
% get original script text
for i=1:length(mscraligned.items)
  mscraligned.items(i).words=mscr.items(i).words;
end
savemoviescript(mscraligned,scroutfname)

% save alignment to txt
%txtfname=regexprep(scroutfname,'.xml','.txt');
%savesubscralignmenttotext(sub,scrmono,p,q,txtfname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% many-to-one match from sub(:).words to scrmono(:).words
function [p,q]=alignbagsofwords(sub,scrmono);

% convert words to word-labels (numbers)
clear wordsall; nw=0;
fprintf('compute word index...\n')
for i=1:length(sub)
  for j=1:length(sub(i).words)
    wordsall(nw+1).word=sub(i).words{j};
    wordsall(nw+1).wordsource=1; % subtitle source
    wordsall(nw+1).wordgroup=i;
    wordsall(nw+1).wordnum=j;
    nw=nw+1;
  end
end
for i=1:length(scrmono)
  for j=1:length(scrmono(i).words)
    wordsall(nw+1).word=scrmono(i).words{j};
    wordsall(nw+1).wordsource=2; % transcript source
    wordsall(nw+1).wordgroup=i;
    wordsall(nw+1).wordnum=j;
    nw=nw+1;
  end
end
% assign weights to the words based on their inverse frequency
[wordsunique,i1,wordslabel]=unique({wordsall(:).word});
wordshist=hist(wordslabel,1:length(wordsunique));
wordsfreq=wordshist(wordslabel);
wordsweight=1./min(10,wordsfreq);

% make labeled word structures
wsubind=find([wordsall(:).wordsource]==1);
wscrind=find([wordsall(:).wordsource]==2);
n1=length(unique([wordsall(wsubind).wordgroup]));
n2=length(unique([wordsall(wscrind).wordgroup]));
clear sublab scrlab
for i=1:n1 
  wi=wsubind(find([wordsall(wsubind).wordgroup]==i));
  sublab(i).words={wordsall(wi).word};
  sublab(i).wlabels=wordslabel(wi);
  sublab(i).wweights=wordsweight(wi);
end
for i=1:n2
  wi=wscrind(find([wordsall(wscrind).wordgroup]==i));
  scrlab(i).words={wordsall(wi).word};
  scrlab(i).wlabels=wordslabel(wi);
  scrlab(i).wweights=wordsweight(wi);
end
% compute (diagonal) similarity matrix
smat=zeros(n1,n2);
fprintf('compute similarity matrix...     ')
for i=1:n1
  for j=max(1,round(i*n2/n1-100)):min(n2,round(i*n2/n1+100))
    % this should only be applied to small groups of words
    % with no or very few repetitions of words within any group
    [w,ia,ib]=intersect(sublab(i).wlabels,scrlab(j).wlabels);
    if length(ia)
      smat(i,j)=sum(sublab(i).wweights(ia));
    end
  end
  if ~mod(i,100)
    %fprintf('i:%d of %d\n',i,n1); 
    fprintf('\b\b\b\b%3d%%',round(100*i/n1));
  end
end
fprintf('\b\b\b\b%3d%%\n',round(100*i/n1));
fprintf('compute alignment with DP...\n')
% make smat less "peaky"
smat=smat.^.1;
[p,q,D]=dynprog(max(smat(:))-smat);
clf, showimage(smat); hold on, plot(q,p,'r');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p,q,subnew]=alignwordbyword(sub,scrmono);

wsub=cat(2,sub(:).words);
wscr=cat(2,scrmono(:).words);
wsubind=[];
for i=1:length(sub)
  wsubind=[wsubind i*ones(1,length(sub(i).words))];
end
wscrind=[];
for i=1:length(scrmono)
  wscrind=[wscrind i*ones(1,length(scrmono(i).words))];
end

% align words
[awsub,awscr]=alignwordstrings(wsub,wscr);
% result: wsub(awsub(i))==wscr(awscr(i))

% align subsections, split subtitles if necessary
asub=[]; ascr=[]; 
cursubsec=sub(1);
clear subnew; subnewind=1;
for i=2:length(awsub)
  subsecchangeflag=wsubind(awsub(i))~=wsubind(awsub(i-1));
  scrsecchangeflag=wscrind(awscr(i))~=wscrind(awscr(i-1));
  
  if (subsecchangeflag & scrsecchangeflag)
    % change in both sections
    subnew(subnewind)=cursubsec;
    asub=[asub subnewind];
    subnewind=subnewind+1;
    cursubsec=sub(wsubind(awsub(i)));
    ascr=[ascr wscrind(awscr(i-1))];
    %printf('case 1:\n %s\n %s\n',subnew(asub(end)).origstring,scrmono(ascr(end)).origstring)
    %pause
  elseif subsecchangeflag
    % change of subtitle section only
    ascr=[ascr wscrind(awscr(i-1))];
    subnew(subnewind)=cursubsec;
    asub=[asub subnewind];
    subnewind=subnewind+1;
    cursubsec=sub(wsubind(awsub(i)));
    %fprintf('case 2:\n %s\n %s\n',subnew(asub(end)).origstring,scrmono(ascr(end)).origstring)
    %pause
  elseif scrsecchangeflag
    % change of script section only: do split subtitles
    ascr=[ascr wscrind(awscr(i-1))];
    wordsplitnum=length(find(wsubind(1:awsub(i-1))==wsubind(awsub(i-1))));
    [cursubsec1,cursubsec2]=splitsubtitlesection(cursubsec,wordsplitnum);
    subnew(subnewind)=cursubsec1;
    asub=[asub subnewind];
    subnewind=subnewind+1;
    cursubsec=cursubsec2;  
    %fprintf('case 3:\n %s\n %s\n',subnew(asub(end)).origstring,scrmono(ascr(end)).origstring)  
    %pause
  end
end
p=[asub subnewind];
q=[ascr wscrind(awscr(i))];
subnew(subnewind)=cursubsec;


function [cursubsec1,cursubsec2]=splitsubtitlesection(cursubsec,wordsplitnum)
  cursubsec1=cursubsec;
  cursubsec2=cursubsec;
  if wordsplitnum<1 | wordsplitnum>length(cursubsec.words)
    fprintf('WARNING from subtitle splitting: something is wrong, will not split!\n')
  else
    % split the time, do not bother with the words
    r=wordsplitnum/length(cursubsec.words);
    sec1=cursubsec.begin*[60^2 60 1]';
    sec2=cursubsec.end*[60^2 60 1]';
    sec3=sec1+round(r*(sec2-sec1));
    s=mod(sec3,60); m=(mod(sec3,60^2)-s)/60; h=(sec3-60*m-s)/60^2;
    cursubsec1.end=round([h m s]);
    cursubsec2.begin=round([h m s]);
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sub=parsesubtitles(subfname)

lines=readlines(subfname);

ns=0;
li=1;
clear sub;
while li<length(lines)
  line=lines{li};
  if length(line)
    timestamp=regexp(line,'\d+:\d+:\d+,\d+\W*\d+:\d+:\d+,\d+','match');
    if length(timestamp)
      % extract time info
      time=regexp(timestamp,'\d+:\d+:\d+','match');
      ns=ns+1;
      sub(ns).begin=sscanf(time{1}{1},'%d:%d:%d')';
      sub(ns).end=sscanf(time{1}{2},'%d:%d:%d')';
      words={};
      origstring='';
      % extract subtitles
      while length(lines{li+1})>0 & ~length(regexp(lines{li+1},'\d+:\d+:\d+,\d+\W*\d+:\d+:\d+,\d+'))
	li=li+1;
	%addwords=regexp(lines{li},'[!-~]*','match');
	addwords=regexp(lower(lines{li}),'\w*','match');
	words={words{:} addwords{:}}; 
	origstring=[origstring ' ' lines{li}];
	if li>=length(lines) break, end
      end
      sub(ns).words=words;
      sub(ns).origstring=origstring;

    end
  end
  li=li+1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lines=readlines(fname)
lines={};
fd=fopen(fname);
notEOF=1;
while (notEOF),
  line=fgetl(fd);
  notEOF=ischar(line);
  if (notEOF),
    lines{end+1}=line;
  end
end
fclose(fd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function scraligned=subtime2script(sub,scr,p,qscr,htmlfname,subfname,scrfname)
 
fp = htopen(htmlfname,'Transcript alignment');
fprintf(fp,'<h1> Subtitles - Transcript alignment </h1>\n');
fprintf(fp,'Subtitle source: <b>%s</b><br>\n',subfname(max(regexp(subfname,'[\\/]'))+1:end));
fprintf(fp,'Transcript source: <b>%s</b><br><br>\n',scrfname(max(regexp(scrfname,'[\\/]'))+1:end));

fprintf(fp,'<table border="1">\n'); 
fprintf(fp,'  <tr align="left">\n  <td> <h1> Subtitles </h1> </td>\n');
fprintf(fp,'  <td> <h1> Transcript </h1> </td>\n  </tr>\n');   

ascore=0;
scraligned=scr;
t1=zeros(1,3); t2=zeros(1,3); t3=zeros(1,3);
for i=1:length(scr)
  fprintf(fp,'  <tr align="left">\n  <td>\n');
  isel=find(qscr==i);
  scraligned(i).ascore=ascore;
  if length(isel)
    % make sure this is a monologue
    if ~strcmp(scr(i).tagname,'monologue') 
      fprintf('Warning: monologue missmatch in alignmoviescript->subtime2script\n')
    end
    % transfer time
    t1=sub(p(isel(1))).begin;
    t2=sub(p(isel(end))).end;
    if length(p)>(isel(end)) t3=sub(p(isel(end)+1)).end; else t3=t2; end
    scraligned(i).begin_time=t1;
    scraligned(i).end_time=t2;
    % write subtitles to .html
    subwords={};
    for j=1:length(isel)
      fprintf(fp,'    %d [%d:%d:%d - %d:%d:%d] ',p(isel(j)),sub(p(isel(j))).begin,sub(p(isel(j))).end);
      for k=1:length(sub(p(isel(j))).words) fprintf(fp,'%s ',sub(p(isel(j))).words{k}); end
      fprintf(fp,'<br>\n');
      subwords={subwords{:} sub(p(isel(j))).words{:}};
    end
    % re-estimate alignment quality
    if length(unique(scr(i).words))
      scraligned(i).ascore=length(intersect(scr(i).words,subwords))/length(unique(scr(i).words));
      ascore=scraligned(i).ascore;
    else
      ascore==0;
    end
  else
    if strcmp(scr(i).tagname,'description')
      scraligned(i).begin_time=t2;
      scraligned(i).end_time=t3;
    end
  end
  fprintf(fp,'  </td>\n');
  % write script
  if ascore>.7 fprintf(fp,'  <td bgcolor="#a0FFa0">\n');
  elseif ascore>.2 fprintf(fp,'  <td bgcolor="#FFc070">\n');
  else fprintf(fp,'  <td bgcolor="#FFa0a0">\n');
  end
  %fprintf(fp,'  <td>\n');
  fprintf(fp,'    %s [ascore=%.3f][%d:%d:%d - %d:%d:%d] ',...
	  scraligned(i).tagname,scraligned(i).ascore,scraligned(i).begin_time,scraligned(i).end_time);
  for j=1:length(scraligned(i).words) fprintf(fp,'%s ',scraligned(i).words{j}); end
  fprintf(fp,'\n  </td>\n  </tr>\n');   
end

fprintf(fp,'</table>\n');
fprintf(fp,'<h2>Alignment score: %.3f</h2><br>\n',mean([scraligned(:).ascore]));
htclose_il(fp);

