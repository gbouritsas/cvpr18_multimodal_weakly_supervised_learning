
function [lines,word_id_begin,word_id_end]=readlines(fname,s)

fd=fopen(fname, 'r', 'n', 'UTF-8');
lines={};
notEOF=1;
count=0;
word_id_begin={};
word_id_end={};
offset=s.offset_begin;
word=s.word_id;
flag_final_word=0;
while (notEOF),
  line=fgetl(fd);
  notEOF=ischar(line);
  if (notEOF),
    count=count+length(line)+2;
    if count>offset(end)
        word_id_begin{end+1}=word(1);
        word_id_end{end+1}=word(end);
        flag_final_word=1;
    end
    ind=find(offset>=count,1);
    if flag_final_word==0
        word_ids=word(1:ind-1);
        if isempty(word_ids)==0
            word_id_begin{end+1}=word_ids(1);
            word_id_end{end+1}=word_ids(end);
        else
            word_id_begin{end+1}=[];
            word_id_end{end+1}=[];
        end
    end
    lines{end+1}=line;
    offset=offset(ind:end);
    word=word(ind:end);
  end
  if isempty(offset)
    break;
  end
end
fclose(fd);
