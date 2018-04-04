function savemoviescript(mscr,scrfname)
  

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
    if strcmp(tagname,'description') | strcmp(tagname,'monologue') | strcmp(tagname,'videoannotation') | strcmp(tagname,'speaker') | strcmp(tagname,'scene') | strcmp(tagname,'unknown')
      textElement.setAttribute('begin_time',sprintf('%02d:%02d:%02d',item.begin_time));
      textElement.setAttribute('end_time',sprintf('%02d:%02d:%02d',item.end_time));
      textElement.setAttribute('begin_frame',sprintf('%d',item.begin_frame));
      textElement.setAttribute('end_frame',sprintf('%d',item.end_frame));
      textElement.setAttribute('ascore',sprintf('%1.3f',item.ascore));
      labels=''; if isfield(item,'labels') labels=item.labels; end
      textElement.setAttribute('labels',labels);
      
    end
    textElement.setAttribute('begin_word',sprintf('%d',item.begin_word));
    textElement.setAttribute('end_word',sprintf('%d',item.end_word));
    textElement.appendChild(docNode.createTextNode(sprintf('%s',item.words)));
    docRootNode.appendChild(textElement);
  end
end

str=xmlwrite(docNode);
%fprintf('save movie script to %s\n',scrfname);
%savewarning('save movie script to ',scrfname)
fd=fopen(scrfname,'w');
fprintf(fd,'%c',str);
fclose(fd);
