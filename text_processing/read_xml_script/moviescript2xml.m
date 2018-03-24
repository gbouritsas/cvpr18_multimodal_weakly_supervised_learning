function [docNode,checkpassedflag]=moviescript2xml(scriptfname,wordfname)
  
% [docNode,checkpassedflag]=moviescript2xml(scriptfname)
%
%  Converts movie script 'scriptfname' in original txt format
%  to a xml format with tags separating the dialog/description
%  parts of the script.
  
% read the file
fprintf('processing %s\n',scriptfname)
temp=load(wordfname);
s=temp.word_ids;
[lines,word_id_begin,word_id_end]=readlines(scriptfname,s);

% classify the lines into classes
[lineclass,checkpassedflag]=classifylines(lines);
%for j=1:length(lines) fprintf('l%5d [%2d] %s\n',j,lineclass(j),lines{j}); end

% create xml document
docNode = com.mathworks.xml.XMLUtils.createDocument('MovieScript');
docRootNode = docNode.getDocumentElement;

% insert taged lines into xml
ind=1;
while ind<=length(lines)
  if lineclass(ind)~=0
    class=lineclass(ind);
    wbegin=word_id_begin{ind};
    wend=word_id_end{ind};
    words=regexp(lines{ind},'[!-~]*','match');
    if ind<length(lines)
      while lineclass(ind+1)==class | lineclass(ind+1)==0
        if lineclass(ind+1)==class
          addwords=regexp(lines{ind+1},'[!-~]*','match');
          wend=word_id_end{ind+1};
          words={words{:} addwords{:}};
        end
        ind=ind+1;
        if ind>=length(lines) break, end
      end
    end
    switch class
     case 1 
      tagname='description'; 
     case 2 
      tagname='scene'; 
     case 3 
      tagname='monologue'; 
     case 4 
      tagname='speaker'; 
     otherwise 
      tagname='unknown'; 
    end
    
    textElement=docNode.createElement(tagname);
    textElement.setAttribute('begin_word',num2str(wbegin));
    textElement.setAttribute('end_word',num2str(wend));
    if strcmp(tagname,'description') | strcmp(tagname,'monologue')
      textElement.setAttribute('begin_time','00:00:00');
      textElement.setAttribute('end_time','00:00:00');
    end
    textElement.appendChild(docNode.createTextNode(sprintf('%s ',words{:})));
    docRootNode.appendChild(textElement);
  end
  ind=ind+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lineclass,checkpassedflag]=classifylines(lines)
% Assign each line with the class label
%  0 : empty line
%  1 : description
%  2 : scene
%  3 : monologue
%  4 : speaker

% get offsets for every line
lineclass=-ones(length(lines),1);
offset=zeros(length(lines),1);
uppercaseflag=zeros(length(lines),1);
for i=1:length(lines)
  off=min(find(lines{i}~=' '));
  if ~length(off)
    lineclass(i)=0; % empty line
  else
    offset(i)=off;
    uppercaseflag(i)=1;
    if length(find(lines{i}>=97 & lines{i}<=122)) uppercaseflag(i)=0; end
  end
end

% we will trust the offsets for classifying the lines into
% "description" (c=1); "scene" (c=2); "monologue" (c=3); "speaker" (c=4)
% and "unknown" (c=-1)
% We expect: - monologue lines may be in upper case 
%            - description and scene lines have the least major offset
%            - scene lines are in upper case 
%            - monologue lines have the second least major offset
%            - speaker lines are in upper case and have the third least
%              major offset
% some consistency checks will be done to warn the vialations.

checkpassedflag=1;
% find the three largest offset clusters
h1=hist(offset(find(lineclass)),1:200); [vs1,is1]=sort(-h1);
h2=hist(offset(find(lineclass & uppercaseflag)),1:200); [vs2,is2]=sort(-h2);
h3=hist(offset(find(lineclass & ~uppercaseflag)),1:200); [vs3,is3]=sort(-h3);
[pks,locs,w,p] = findpeaks([0 h1],'MinPeakDistance',2,'SortStr','descend');
locs=locs-1;

if is1(1)==is3(1) fprintf('Check: 1st major offset for all/lower case -- OK\n');
else fprintf('WARNING: 1st major offset for all/lower case\n'); checkpassedflag=0; end

if is1(2)==is3(2) fprintf('Check: 2nd major offset for all/lower case -- OK\n');
else fprintf('WARNING: 2nd major offset for all/lower case\n'); checkpassedflag=0; end

if ismember(is2(1),is1(1:3)) & ismember(is2(2),is1(1:3))
  fprintf('Check: 2 major offsets for upper case -- OK\n');
else 
  fprintf('WARNING: 2 major offsets for upper case\n');
  checkpassedflag=0;
end

locs_new=sort(locs(1:3));
majoff_1=max(1,locs_new(1)-round((locs_new(2)-locs_new(1))/3)):min(locs_new(1)+round((locs_new(2)-locs_new(1))/3),200);
majoff_2=max(1,locs_new(2)-round((locs_new(2)-locs_new(1))/3)):min(locs_new(2)+round((locs_new(3)-locs_new(2))/3),200);
majoff_3=max(1,locs_new(3)-round((locs_new(3)-locs_new(2))/3)):min(locs_new(3)+round((locs_new(3)-locs_new(2))/3),200);
for i=1:length(lineclass) 
    % assign "scene" class
    if lineclass(i)==-1 & uppercaseflag(i) & any(offset(i)==majoff_1)
        lineclass(i)=2;
    end
    % assign "description" class
    if lineclass(i)==-1 & any(offset(i)==majoff_1)
        lineclass(i)=1;
    end

    % assign "monologue" class
    if lineclass(i)==-1 & any(offset(i)==majoff_2)
        lineclass(i)=3;
    end

    % assign "speaker" class
    if lineclass(i)==-1 & uppercaseflag(i) & any(offset(i)==majoff_3)
        lineclass(i)=4;
    end
end

