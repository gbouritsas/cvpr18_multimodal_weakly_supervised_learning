function synchronizemoviescript(synch,scrpath,videopath)

% synchronizemoviescript(synch,scrpath)
%
%  synchronizes movie script (with time information) with
%  video files provided information in 'synch' as:
%    synch.scrfname
%    synch.videofname
%    synch.a
%    synch.b
%    synch.fps
  
    
% load aligned movie script
scrfname=fullfile([scrpath '/' synch.scrfname]);
synchscrfname=fullfile([scrpath '/' synch.synchscrfname]);
mscr=loadmoviescript(scrfname);
mscr.fps=synch.fps;

% (re-)compute frame synchronization
for i=1:length(mscr.items)
  tvec=[60^2 60 1]';
  if ~length(find(mscr.items(i).begin_time<0)) & ~length(find(mscr.items(i).end_time<0))
    t1=reshape(mscr.items(i).begin_time,1,3)*tvec;
    t2=reshape(mscr.items(i).end_time,1,3)*tvec;
    mscr.items(i).begin_frame=round(synch.fps*(t1*synch.a+synch.b));
    mscr.items(i).end_frame=round(synch.fps*(t2*synch.a+synch.b));
  end
end
mscr.scrfname=synch.scrfname;
mscr.videofname=synch.videofname;

% save synchronized movie script
%xmlsynchscrfname=regexprep(scrfname,'_aligned.xml','_synchronized.xml');
htmlsynchscrfname=regexprep(synchscrfname,'.xml','.html');
fprintf('saving synchronized script to %s\n',synchscrfname)
%script2xml(mscr,xmlsynchscrfname);
savemoviescript(mscr,synchscrfname);
%script2html(mscr,htmlsynchscrfname,videopath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function docNode=script2xml(mscr,scroutfname)
% create xml document
docNode = com.mathworks.xml.XMLUtils.createDocument('MovieScript');
docRootNode = docNode.getDocumentElement;

textElement=docNode.createElement('ascore');
textElement.appendChild(docNode.createTextNode(sprintf('%1.3f',mscr.ascore)));
docRootNode.appendChild(textElement);

textElement=docNode.createElement('ScriptFileName');
textElement.appendChild(docNode.createTextNode(mscr.scrfname));
docRootNode.appendChild(textElement);

textElement=docNode.createElement('VideoFileName');
textElement.appendChild(docNode.createTextNode(mscr.videofname));
docRootNode.appendChild(textElement);

textElement=docNode.createElement('FPS');
textElement.appendChild(docNode.createTextNode(sprintf('%1.3f',mscr.fps)));
docRootNode.appendChild(textElement);

for i=1:length(mscr.items)
  item=mscr.items(i);
  tagname=item.tagname;
  if ~strcmp(tagname,'ascore') & ...
     ~strcmp(tagname,'ScriptFileName') & ...
     ~strcmp(tagname,'VideoFileName') & ...
     ~strcmp(tagname,'FPS')
    textElement=docNode.createElement(item.tagname);
    if strcmp(tagname,'description') | strcmp(tagname,'monologue')
      textElement.setAttribute('begin_time',sprintf('%02d:%02d:%02d',item.begin_time));
      textElement.setAttribute('end_time',sprintf('%02d:%02d:%02d',item.end_time));
      textElement.setAttribute('begin_frame',sprintf('%d',item.begin_frame));
      textElement.setAttribute('end_frame',sprintf('%d',item.end_frame));
      textElement.setAttribute('ascore',sprintf('%1.3f',item.ascore));
    end
    textElement.appendChild(docNode.createTextNode(sprintf('%s ',item.words)));
    docRootNode.appendChild(textElement);
  end
end

str=xmlwrite(docNode);
fprintf('saving aligned xml script to %s\n',scroutfname);
%savewarning('saving aligned xml script to ',scroutfname)
fd=fopen(scroutfname,'w');
fprintf(fd,'%c',str);
fclose(fd);


function script2html(mscr,htmlfname,videopath)

fp = htopen(htmlfname,'Transcript synchronization');
fprintf(fp,'<h1> Transcript - Video synchronization </h1>\n');
fprintf(fp,'Transcript source: <b>%s</b><br>\n',mscr.scrfname);
fprintf(fp,'Video source: <b>%s</b><br><br>\n',mscr.videofname);
fprintf(fp,'Subtitle alignment score: <b>%1.3f</b><br><br>\n',mscr.ascore);

fprintf(fp,'<table border="1">\n'); 
fprintf(fp,'  <tr align="left">\n');
fprintf(fp,'  <td> <h1> Frames </h1> </td>\n \n');   
fprintf(fp,'  <td> <h1> Transcript </h1> </td>\n  </tr>\n');   

tvec=[60^2 60 1]';

for i=1:length(mscr.items)
  
  item=mscr.items(i);
  tagname=item.tagname;
  if ~strcmp(tagname,'ascore') & ...
     ~strcmp(tagname,'ScriptFileName') & ...
     ~strcmp(tagname,'VideoFileName')
    
    fprintf(fp,'  <tr align="left">\n');
    if item.begin_frame>0 & item.end_frame>0
      %keyboard
      %fprintf(fp,'  <td> %d <br> %d </td>\n \n',item.begin_frame,item.end_frame);
      % make a link to ffmpeg
      ffplay='C:\ilaptev\proj\ffmpeg-win32builds\bin\ffplay.exe';
      videfname=fullfile([videopath '/' mscr.videofname]);
      batfname=sprintf('c:/temp/ffplay/ffplay%04d.bat',i);
      videotime=round(item.begin_frame/mscr.fps);
      videotime=videotime+2;
      bfh=fopen(batfname,'w');
      fprintf(bfh,'%s "%s" -ss %d',ffplay,videfname,videotime);
      fclose(bfh);
      fprintf(fp,'  <td> <a href = "%s"> %d <br> %d</a> </td>',...
	      batfname,item.begin_frame,item.end_frame);
    else
      fprintf(fp,'  <td> </td>\n \n');
    end
    
    if item.ascore>.7 fprintf(fp,'  <td bgcolor="#a0FFa0">\n');
    elseif item.ascore>.2 fprintf(fp,'  <td bgcolor="#FFc070">\n');
    else fprintf(fp,'  <td bgcolor="#FFa0a0">\n');
    end

    fprintf(fp,'    %s [ascore=%.3f][%d:%d:%d - %d:%d:%d] ',...
	    item.tagname,item.ascore,item.begin_time,item.end_time);
    fprintf(fp,'%s ',item.words);
    fprintf(fp,'\n  </td>\n  </tr>\n');   
  end
end

fprintf(fp,'</table>\n');
htclose_il(fp);

