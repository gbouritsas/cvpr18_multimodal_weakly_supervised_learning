function overlaymoviescript(mscr,avsfname,avifname,off1,off2)

% overlaymoviescript(mscr,avsfname,avifname,off1,off2)

if exist(avifname,'file')
  vinfo=aviinfo(avifname);
  %vinfo=aviinfo_yaai(avifname);
  xsz=vinfo.Width;
  ysz=vinfo.Height;
else
  ysz=240;
  xsz=360;
end

fprintf('oevrlaying synchronized script in %s\n',avsfname);
fp=fopen(avsfname,'w');

fprintf(fp,'AVISource("%s")\r\n',regexprep(avifname,'/','\\'));

% add borders and subsample to the standard size
fprintf(fp,'AddBorders(0,round((Width/1.333-Height)/2),0,round((Width/1.333-Height)/2))\r\n');
fprintf(fp,'BilinearResize(640,480)\r\n');
ysz=480; xsz=640;

mt1all=[mscr.items(mscr.mind(:)).end_frame];
dt1all=[mscr.items(mscr.dind(:)).end_frame];
ut1all=unique([mt1all dt1all]);


for i=1:length(ut1all)
  t1=ut1all(i);
  mi=mscr.mind(find(abs(mt1all-t1)<20));
  di=mscr.dind(find(abs(dt1all-t1)<20));
  
  ind=mi';
  for j=1:length(ind)
    item=mscr.items(ind(j));
    t1=item.begin_frame;
    t2=item.end_frame;
    % ensure descriptions are visible for a while
    dt21=50-(t2-t1); 
    if dt21>0 t1=t1-round(dt21/2); t2=t2+round(dt21/2); end
    
    ypos=320+j*20;
    subtext=regexprep(item.words,'"','*');
    indstr=[1:70:length(subtext) length(subtext)+1];
    for k=1:(length(indstr)-1)
      fprintf(fp,'Subtitle("%s", 10, %d, %d, %d, "Arial", 20, $00FF00)\r\n',...
	      subtext(indstr(k):(indstr(k+1)-1)),ypos+k*15,t1,t2);
    end
    %fprintf(fp,'Subtitle("%s", 10, %d, %d, %d, "Arial", 20, $00FF00)\r\n',subtext,ypos,t1,t2);
  end

  ind=di';
  for j=1:length(ind)
    item=mscr.items(ind(j));
    t1=item.begin_frame;
    t2=item.end_frame;
    % ensure descriptions are visible for a while
    dt21=75-(t2-t1); 
    if dt21>0 t1=t1-round(dt21/2); t2=t2+round(dt21/2); end
    
    ypos=380+j*20;
    subtext=regexprep(item.words,'"','*');
    indstr=[1:70:length(subtext) length(subtext)+1];
    for k=1:(length(indstr)-1)
      %k, indstr, size(subtext)
      fprintf(fp,'Subtitle("%s", 10, %d, %d, %d, "Arial", 20, $FFFF00)\r\n',...
	      subtext(indstr(k):(indstr(k+1)-1)),ypos+k*15,t1,t2);
    end
  end
end



if 0 % old part
for i=1:length(ut1all)
  t1=ut1all(i);
  mi=mscr.mind(find(abs(mt1all-t1)<10));
  di=mscr.dind(find(abs(dt1all-t1)<10));
  ccol=[ones(length(mi),1)*'00FF00'; ones(length(di),1)*'FFFF00'];
  ind=[mi' di'];
  linenum=1;
  for j=length(ind):-1:1
    item=mscr.items(ind(j));
    t1=item.begin_frame;
    t2=item.end_frame;
    % ensure descriptions are visible for a while
    dt21=75-(t2-t1); 
    if dt21>0 
      t1=t1-round(dt21/2);
      t2=t2+round(dt21/2);
    end
    indstr=[1:70:length(item.words) length(item.words)+1];
    for k=1:length(indstr)-1
      istr1=indstr(k); istr2=indstr(k+1);
      lnum=linenum+(length(indstr)-1)-k;
      ypos=max(20,ysz-20*lnum);
      subtext=regexprep(item.words(istr1:(istr2-1)),'"','*');
      if k==1 subtext=sprintf('%s',subtext); end
      %if k==1 subtext=sprintf('(%1.3f) %s',item.ascore,subtext); end
      fprintf(fp,'Subtitle("%s", 10, %d, %d, %d, "Arial", 20, $%s)\r\n',...
	      subtext,ypos,t1,t2,char(ccol(j,:)));
    end
    %fprintf(fp,'Subtitle("%s", 10, 20, %d, %d, "Arial", 18, $FF0000)\r\n',item.labels,t1,t2);
    %linenum=min(9,linenum+length(indstr)-1);
    linenum=linenum+length(indstr);
  end
end
end


if nargin>3
  fprintf(fp,'Trim(%d,%d)\r\n',off1,off2);
end

fclose(fp);
