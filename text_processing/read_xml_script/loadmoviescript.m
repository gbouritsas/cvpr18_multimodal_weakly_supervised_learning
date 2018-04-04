function mscr=loadmoviescript(scrfname)

% mscript=loadmoviescript(scrfname)
%
%  Loads formatted movie script from the xml file
%


[scr,videofname,fps,ascoreread,scrfnameread]=parsexmlscript(scrfname);
mscr.items=scr;
mscr.mind=findcellstr({scr(:).tagname},{'monologue'});
mscr.dind=findcellstr({scr(:).tagname},{'description'});
mscr.sind=findcellstr({scr(:).tagname},{'speaker'});
mscr.scind=findcellstr({scr(:).tagname},{'scene'});
mscr.uind=findcellstr({scr(:).tagname},{'unknown'});
mscr.ascore=0;
mscr.scrfname=[];
mscr.videofname='';
mscr.fps=-1;

if ~isempty(ascoreread)
    mscr.ascore=ascoreread;
else
    if ~isempty(mscr.mind)
        mscr.ascore=mean([scr(mscr.mind).ascore]);
    end
end

if ~isempty(scrfnameread)
    mscr.scrfname=scrfnameread;
else
    fname=scrfname;
    [str,i1]=regexp(scrfname,'\\|/','match','start');
    if ~isempty(i1) 
        fname=scrfname((i1(end)+1):end); 
    end
    mscr.scrfname=fname;
end

if ~isempty(videofname) 
    mscr.videofname=videofname; 
end

if ~isempty(fps)
    mscr.fps=fps; 
end


end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% see doc on xml here http://xerces.apache.org/xerces-j/apiDocs/org/w3c/dom/NamedNodeMap.html
function [scr,videofname,fps,ascoreread,scrfnameread]=parsexmlscript(scrfname)
xDoc=xmlread(scrfname);
allListItems = xDoc.getElementsByTagName('MovieScript');
allListItems.getLength;
xRoot = xDoc.getDocumentElement;

nt=0;
fps=[];
ascoreread=[];
scrfnameread=[];

clear scr;
videofname=[];
for i=0:xRoot.getLength-1
    thisListItem = xRoot.item(i);
    if length(thisListItem.getAttributes)
        tagname=[thisListItem.getTagName.toString.toCharArray]';
        
        if strcmp(tagname,'ascore')
            if length(thisListItem.getFirstChild)
                ascorestr=[thisListItem.getFirstChild.getData.toCharArray]';
                ascoreread=str2num(ascorestr);
            end
        end
        
        if strcmp(tagname,'ScriptFileName')
            if length(thisListItem.getFirstChild)
                scrfnameread=[thisListItem.getFirstChild.getData.toCharArray]';
            end
        end
        
        if strcmp(tagname,'VideoFileName')
            if length(thisListItem.getFirstChild)
                videofname=[thisListItem.getFirstChild.getData.toCharArray]';
            end
        end
        
        if strcmp(tagname,'FPS')
            if length(thisListItem.getFirstChild)
                %fpsstr=regexp([thisListItem.getFirstChild.getData.toCharArray]','\d*.\d+','match');
                fpsstr=[thisListItem.getFirstChild.getData.toCharArray]';
                fps=str2num(fpsstr);
            end
        end
        
        time1Attr=thisListItem.getAttributes.getNamedItem('begin_time');
        time2Attr=thisListItem.getAttributes.getNamedItem('end_time');
        time1=-ones(1,3); time2=-ones(1,3);
        if length(time1Attr) & length(time2Attr)
            %t1str=regexp([time1Attr.toString.toCharArray]','\d+:\d+:\d+','match');
            %t2str=regexp([time2Attr.toString.toCharArray]','\d+:\d+:\d+','match');
            t1str=getqstr([time1Attr.toString.toCharArray]');
            t2str=getqstr([time2Attr.toString.toCharArray]');
            time1=sscanf(t1str,'%d:%d:%d');
            time2=sscanf(t2str,'%d:%d:%d');
        end
        
        frame1Attr=thisListItem.getAttributes.getNamedItem('begin_frame');
        frame2Attr=thisListItem.getAttributes.getNamedItem('end_frame');
        frame1=-1; frame2=-1;
        if length(frame1Attr) & length(frame2Attr)
            %f1str=regexp([frame1Attr.toString.toCharArray]','\d+','match');
            %f2str=regexp([frame2Attr.toString.toCharArray]','\d+','match');
            f1str=getqstr([frame1Attr.toString.toCharArray]');
            f2str=getqstr([frame2Attr.toString.toCharArray]');
            frame1=str2num(f1str);
            frame2=str2num(f2str);
        end
        
        word1Attr=thisListItem.getAttributes.getNamedItem('begin_word');
        word2Attr=thisListItem.getAttributes.getNamedItem('end_word');
        word1=-1; word2=-1;
        if length(word1Attr) & length(word2Attr)
            %f1str=regexp([frame1Attr.toString.toCharArray]','\d+','match');
            %f2str=regexp([frame2Attr.toString.toCharArray]','\d+','match');
            w1str=getqstr([word1Attr.toString.toCharArray]');
            w2str=getqstr([word2Attr.toString.toCharArray]');
            word1=str2num(w1str);
            word2=str2num(w2str);
        end
        
        ascoreAttr=thisListItem.getAttributes.getNamedItem('ascore');
        ascore=0;
        if length(ascoreAttr)
            %ascorestr=regexp([ascoreAttr.toString.toCharArray]','\d.\d+','match');
            ascorestr=getqstr([ascoreAttr.toString.toCharArray]');
            ascore=str2num(ascorestr);
        end
        
        labelsAttr=thisListItem.getAttributes.getNamedItem('labels');
        labels='';
        if length(labelsAttr)
            %labels=regexp([labelsAttr.toString.toCharArray]','[~-!]*','match');
            labels=getqstr([labelsAttr.toString.toCharArray]');
        end
        
        if length(thisListItem.getFirstChild)
            str=[thisListItem.getFirstChild.getData.toCharArray]';
            scr(nt+1).tagname=tagname;
            scr(nt+1).begin_time=time1;
            scr(nt+1).end_time=time2;
            scr(nt+1).begin_frame=frame1;
            scr(nt+1).end_frame=frame2;
            scr(nt+1).begin_word=word1;
            scr(nt+1).end_word=word2;            
            scr(nt+1).ascore=ascore;
            scr(nt+1).labels=labels;
            %scr(nt+1).words=regexp(str,'[!-~]*','match');
            %scr(nt+1).words=regexp(str,'\w*','match');
            scr(nt+1).words=str;
            nt=nt+1;
        end
    end
    
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returns string in quotation
function str=getqstr(qstr)
ss=strfind(qstr,'"'); i1=ss(end-1)+1; i2=ss(end)-1;
if i1>i2 str=''; else str=qstr(i1:i2); end
end
