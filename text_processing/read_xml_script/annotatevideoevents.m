function annotatevideoevents(videofname,scrfname,labels,scrfnameout)


%videofname='D:\video\fullmovies\the graduate (1967) english.avi';
%videofname='D:\video\fullmovies\American beauty.(1h56mn38s).avi';
%scrfname='C:\ilaptev\data\eventdetection\transcripts\alignedscripts\American Beauty_labeled_synchronized.xml';

if nargin<3 labels={}; end

if nargin<4
  fprintf('annotatevideoevents: will overwrite input script at saving!\n');
  scrfnameout=scrfname;
end

if ~length(labels)
  labels={'<ActionAnswerPhone>','<ActionGetOutCar>','<ActionHandShake>',...
	  '<ActionHugPerson>','<ActionKiss>','<ActionSitDown>',...
	  '<ActionSitUp>','<ActionStandUp>'};
end

if ~exist(videofname,'file') error(sprintf('cannot read %s',videofname)); end
if ~exist(scrfname,'file') error(sprintf('cannot read %s',scrfname)); end

% used these links to include media player into matlab
% http://www.codeproject.com/KB/COM/MatlabActivex.aspx
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=2901&objectType=File

fh=figure;
% setup window
wpos=get(fh,'Position');
set(fh,'Position',[wpos(1:2) 300 200])
wpos=get(fh,'Position');
mp=actxcontrol('MediaPlayer.MediaPlayer.1',[0 0 wpos(3:4)],fh);
fprintf('load video %s\n',videofname)
set(mp,'filename', videofname);
set(mp,'DisplayMode','mpFrames');
set(mp,'AutoStart',0);
Stop(mp);
duration=get(mp,'Duration');
frameid=get(mp,'CurrentPosition');

dw=300; dh=300;
vxsz=get(mp,'ImageSourceWidth');
vysz=get(mp,'ImageSourceHeight');
ww=vxsz+dw+100; wh=vysz+dh+100;

set(fh,'Position',[wpos(1) wpos(2)+wpos(4)-wh ww wh]);
move(mp,[0 dh vxsz+100 vysz+100]);

% initialize GUI parameters
global GUIDATA;
GUIDATA.scrfname=scrfname;
GUIDATA.videofname=videofname;
GUIDATA.scrfnameout=scrfnameout;
fprintf('load script %s\n',scrfname)
GUIDATA.scr=loadmoviescript(scrfname);
GUIDATA.mediaplayer=mp;
GUIDATA.playflag=0;
GUIDATA.ww=ww;
GUIDATA.wh=wh;
GUIDATA.dw=dw;
GUIDATA.dh=dh;

% player buttons
GUIDATA.handles.playvideo_h=    uicontrol('Style','togglebutton','Position',[140,dh-70,180,30],...
					  'String','Play / Stop','Callback',@playvideo_gui);

% slider
GUIDATA.handles.slider_h=       uicontrol('Style','slider','Position',[140,dh-30,vxsz-60,20],...
					  'SliderStep',[0.001 0.01],'Callback',@slider_gui);

% frame indicator
                                uicontrol('Style','text','Position',[20,dh-45,50,30],...
					  'FontSize',10,'HorizontalAlignment','left',...
					  'BackgroundColor',get(gcf,'Color'),'String','Frame:');
GUIDATA.handles.framenum_h=     uicontrol('Style','edit','Position',[75,dh-35,50,20],...
					  'FontSize',10,'HorizontalAlignment','right',...
					  'BackgroundColor',get(gcf,'Color'),'Callback',@framenum_gui);
% annotation disply
GUIDATA.handles.annotation_h=   uicontrol('Style','text','Position',[vxsz+120,20,dw-40,wh-50],...
					  'HorizontalAlignment','left');
                                uicontrol('Style','text','Position',[vxsz+120,wh-30,100,20],...
					  'FontSize',10,'HorizontalAlignment','left',...
					  'BackgroundColor',get(gcf,'Color'),...
					  'String','Annotation:');
% annotation control
                                uicontrol('Style','pushbutton','Position',[25,dh-110,90,30],...
					  'String','Set begin-frame','Callback',@setbeginframe_gui);
GUIDATA.handles.beginframe_h=   uicontrol('Style','text','Position',[125,dh-110,40,20],...
					  'FontSize',10,'HorizontalAlignment','right',...
					  'BackgroundColor',get(gcf,'Color'),'String','0');

                                uicontrol('Style','pushbutton','Position',[25,dh-150,90,30],...
					  'String','Set end-frame','Callback',@setendframe_gui);
GUIDATA.handles.endframe_h=     uicontrol('Style','text','Position',[125,dh-150,40,20],...
					  'FontSize',10,'HorizontalAlignment','right',...
					  'BackgroundColor',get(gcf,'Color'),'String','0');

                                uicontrol('Style','pushbutton','Position',[vxsz-20,20,120,80],...
					  'String','SAVE script','Callback',@savescript_gui);

				
GUIDATA.handles.labelspopup_h=  uicontrol('Style','popupmenu','Position',[25,dh-190,200,30],...
					  'String',labels);
GUIDATA.handles.addannotation_h=uicontrol('Style','pushbutton','Position',[25,dh-210,100,20],...
					  'String','Add Annotation','Callback',@addannotation_gui);
%

update;

%%%%%%%%%%%%%%%%%%%%
% main update function
function frameid=update
  global GUIDATA;
  frameid=get(GUIDATA.mediaplayer,'CurrentPosition');
  set(GUIDATA.handles.framenum_h,'String',sprintf('%6d',frameid));
  
  % update slider
  duration=get(GUIDATA.mediaplayer,'Duration');
  set(GUIDATA.handles.slider_h,'Value',frameid/duration);
  
  % update displayed script items
  itemind=findcurrentscriptitems(frameid);
  displayannotation(itemind);

%%%%%%%%%%%%%%%%%%%%
function framenum_gui(hObject,eventdata)
  global GUIDATA;
  frameid=str2num(get(GUIDATA.handles.framenum_h,'String'));
  if length(frameid)
    set(GUIDATA.mediaplayer,'CurrentPosition',frameid(1));
    update;
  end
  
%%%%%%%%%%%%%%%%%%%%
% Finds annotation items with time intervals overlapping with frameid
function itemind=findcurrentscriptitems(frameid)
  global GUIDATA;
  t1=transpose([GUIDATA.scr.items(:).begin_frame]);
  t2=transpose([GUIDATA.scr.items(:).end_frame]);
  itemind=find(frameid>=t1 & frameid<=t2);

%%%%%%%%%%%%%%%%%%%%
function playvideo_gui(hObject,eventdata)
  global GUIDATA;
  
  if GUIDATA.playflag
    GUIDATA.playflag=0;
    Stop(GUIDATA.mediaplayer)
    update;
  else
    GUIDATA.playflag=1;
    Play(GUIDATA.mediaplayer)
    while(GUIDATA.playflag)
      update;
      pause(.5)
    end
  end

%%%%%%%%%%%%%%%%%%%%
function slider_gui(hObject,eventdata)
  global GUIDATA;
  duration=get(GUIDATA.mediaplayer,'Duration');
  val=get(GUIDATA.handles.slider_h,'Value');
  frameid=round(val*duration);
  set(GUIDATA.mediaplayer,'CurrentPosition',frameid);
  update;

%%%%%%%%%%%%%%%%%%%%
function setbeginframe_gui(hObject,eventdata)
  global GUIDATA;
  frameid=round(get(GUIDATA.mediaplayer,'CurrentPosition'));
  set(GUIDATA.handles.beginframe_h,'String',num2str(frameid));

%%%%%%%%%%%%%%%%%%%%
function setendframe_gui(hObject,eventdata)
  global GUIDATA;
  frameid=round(get(GUIDATA.mediaplayer,'CurrentPosition'));
  set(GUIDATA.handles.endframe_h,'String',num2str(frameid));
  
%%%%%%%%%%%%%%%%%%%%
function addannotation_gui(hObject,eventdata)
  global GUIDATA;
  
  labelsall=get(GUIDATA.handles.labelspopup_h,'String');
  label=labelsall{get(GUIDATA.handles.labelspopup_h,'Value')};
  begin_frame=str2num(get(GUIDATA.handles.beginframe_h,'String'));
  end_frame=str2num(get(GUIDATA.handles.endframe_h,'String'));
  
  newitem=struct('tagname','videoannotation','begin_time',[-1 -1 -1],'end_time',[-1 -1 -1],...
		 'begin_frame',begin_frame,'end_frame',end_frame,'ascore',1,...
		 'labels',label,'words','---');
  
  % add new item to the script
  GUIDATA.scr.items(end+1)=newitem;
  update;
  
%%%%%%%%%%%%%%%%%%%%
function savescript_gui(hObject,eventdata)
  global GUIDATA;
  
  scrfnameout=GUIDATA.scrfnameout;
  fprintf('save script to %s\n',scrfnameout)
  savemoviescript(GUIDATA.scr,scrfnameout);

%%%%%%%%%%%%%%%%%%%%
function displayannotation(itemind)
  global GUIDATA;
  str={};
  for i=1:length(itemind)
    item=GUIDATA.scr.items(itemind(i));
    str{end+1}=sprintf('%s [%d-%d] %s',item.tagname,...
		       item.begin_frame,item.end_frame,...
		       item.labels);
    if length(item.words)
      str{end+1}=item.words;
    end
    str{end+1}='';
  end
  set(GUIDATA.handles.annotation_h,'String',str);
