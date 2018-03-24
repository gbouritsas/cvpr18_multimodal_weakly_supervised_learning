function [cast_list_original,tags_regex,tags,classes]=cast_list_extractor(id)
	global api_key
	credits=urlread(['https://api.themoviedb.org/3/movie/' num2str(id) '/credits?' api_key]);
	credits=parse_json(credits);
	for i=1:size(credits.cast,2)
		cast_list{i}=credits.cast{1,i}.character;
	end
	cast_list_original=cast_list;

	tags=[];
	classes=[];
	for i=1:size(cast_list,2)
		cast_list{i}=regexprep(cast_list{i},'^(?m)(.)+(U|u)ncredited(.)*(?m)$',cell(1));
		cast_list{i}=regexprep(cast_list{i},'^(?m)(.)+(V|v)oice(.)*(?m)$',cell(1));
		cast_list{i}=regexprep(cast_list{i},'(.*)(\()(.*)(\))(.*)','$1 $5' );
	end
	cast_list = cast_list(~cellfun('isempty',cast_list));
	cast_list_preprocessed=cast_list;
	for i=1:size(cast_list,2)
		cast_list_preprocessed{i}=regexprep(cast_list{i},'^(?m)(.)+''s(.)+(?m)$',cell(1));
		cast_list_preprocessed{i}=regexprep(cast_list_preprocessed{i},'^(?m)(.)+s''(.)+(?m)$',cell(1));
		cast_list_preprocessed{i}=regexprep(cast_list_preprocessed{i},'^(?m)(.)+[0-9]+(.)*(?m)$',cell(1));
		cast_list_preprocessed{i}=regexprep(cast_list_preprocessed{i},'^(?m)(.)+ at (.)*(?m)$',cell(1));
		cast_list_preprocessed{i}=regexprep(cast_list_preprocessed{i},'^(?m)(.)+ in (.)*(?m)$',cell(1));
		cast_list_preprocessed{i}=regexprep(cast_list_preprocessed{i},'^(?m)(.)+ by (.)*(?m)$',cell(1));
		cast_list_preprocessed{i}=regexprep(cast_list_preprocessed{i},'^(?m)(.)+ on (.)*(?m)$',cell(1));
		cast_list_preprocessed{i}=regexprep(cast_list_preprocessed{i},'^(?m)(.)+ with (.)*(?m)$',cell(1));
		cast_list_preprocessed{i}=regexprep(cast_list_preprocessed{i},'(.*)('')(.*)('')(.*)','$1 $3 $5' );
		cast_list_preprocessed{i}=regexprep(cast_list_preprocessed{i},'(.*)(")(.*)(")(.*)','$1 $3 $5' );
		cast_list_preprocessed{i}=regexprep(cast_list_preprocessed{i},',(.)+(?m)$',cell(1));
		cast_list_preprocessed{i}=regexprep(cast_list_preprocessed{i},'-(.)+(?m)$',cell(1));
		cast_list_preprocessed{i}=regexprep(cast_list_preprocessed{i},' of (.)+(?m)$',cell(1));
		cast_list_preprocessed{i}=regexprep(cast_list_preprocessed{i},'&(.)+(?m)$',cell(1));
		cast_list_preprocessed{i}=regexprep(cast_list_preprocessed{i},' the (.)+(?m)$',cell(1));
		cast_list_preprocessed{i}=regexprep(cast_list_preprocessed{i},'\<\w*(\.)\>',cell(1));


		temp=strsplit(cast_list_preprocessed{i});
		temp1=cell(0);
		for j=1:size(temp,2)
			if isempty(temp{j})==0
					tf = isstrprop(temp{j}(1),'upper');
					word_len=length(temp{j}) ;
					if tf & word_len >1
						temp1=[temp1 temp{j}];
					end
			end
		end
		tags=[tags temp1];
		classes=[classes i*ones(1,size(temp1,2))];
	end
	flags=[1*ones(1,size(cast_list,2)) zeros(1,size(tags,2))];
	tags=[cast_list(~cellfun(@isempty,cast_list)) tags];
	classes=[1:size(cast_list,2) classes];
	tags=cellfun(@(x)regexprep(x,'é','e'),tags,'UniformOutput' ,false);
	tags=cellfun(@(x)regexprep(x,'É','E'),tags,'UniformOutput' ,false);
	[tags,idx,idx2]=uniquecell(tags);
	classes=classes(idx);
	flags=flags(idx);
	tags_regex=tags;


	k=1;
	for i=1:size(tags,2)
		if flags(i)==1
			tags_regex{k}=regexprep(tags{i},'\<([a-zA-Z])','(${upper($1)}|${lower($1)})');
		else
			tags_regex{k}=regexprep(tags{i},'\<([a-zA-Z])','${upper($1)}');
		end

		tags_regex{k+1}=regexprep(tags{i},'^.*$','\t');
		tags_regex{k+2}='PERSON	ORGANIZATION,O,PERSON,MISC,LOCATION,MONEY,PERCENT,DATE,TIME,ORDINAL,NUMBER,DURATION,TIME';
		tags_regex{k+3}=regexprep(tags{i},'^.*$','\r\n');
		k=k+4;
	end
