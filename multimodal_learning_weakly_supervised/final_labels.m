function [person_names,action_labels]=final_labels(input_folder,scrfname,...
    person_names_file,cast_list_flag,original_tags_file,person_tagnames,...
    categories_file,similarities_file,sentences_file,dependencies_file,...
	action_tagnames)
	
	%%%CHARACTERS
	load(fullfile([input_folder '/' person_names_file]));

    if cast_list_flag
		load(fullfile([input_folder '/' original_tags_file]));
		indices=[];
		for i=1:size(tags,2)
			indices = [indices find(strcmp(tags(i),cat(1,[],{person_names.mentions})))];
		end
		person_names=person_names(indices);
    end
    
    [unique_mentions,ipa]=uniquecell(cat(1,[],{person_names.mentions}));
	unique_mentions_classes=cat(1,[],person_names.classes);
	unique_mentions_classes=unique_mentions_classes(ipa);
	unique_mentions_tags=cat(1,[],{person_names.tags});
	unique_mentions_tags=unique_mentions_tags(ipa);
    
    mscr=loadmoviescript(fullfile([input_folder '/' scrfname]));
    items=mscr.items;
    [~,b]=sort(cat(1,[],person_names.word_ids));
	person_names=person_names(b);
    [person_names(:).items]=deal(cell(0));
    for i=1:length(person_names)
		word=person_names(i).word_ids;
		for j=1:length(items)
			if word>=items(j).begin_word & word<=items(j).end_word
					person_names(i).items=items(j);
				break;
			end
		end
		items=items(j:end);
    end
    
    temp_items=cat(1,[],person_names.items);
	text_part_flag=false(size(person_names));
    for tagname=person_tagnames
        text_part_flag=text_part_flag+strcmp(extractfield(temp_items,'tagname'),cell2mat(tagname));
    end
    person_names=person_names(logical(text_part_flag));
    
	%%%ACTIONS
	load(categories_file)
	load(fullfile([input_folder '/' similarities_file]))
  	load(fullfile([input_folder '/' sentences_file]))
	load(fullfile([input_folder '/' dependencies_file]))
    
	
    
	items=mscr.items;
	[~,b]=sort(extractfield(sentences_with_ids,'word_id'));
	sentences_with_ids=sentences_with_ids(b);
	dependencies=dependencies(b);
	similarities_all=similarities_all(b);
    
    
    
	mentions=cell(0);
	sentences=cell(0);
	word_ids=cell(0);
    tokens=cell(0);
	subjects=cell(0);
	verb_items=[];	
	simil=cell(0);
    for i=1:length(sentences_with_ids)
        clear verb_item
        mention={sentences_with_ids(i).sentences};
        mentions=[mentions mention];
        sentence={sentences_with_ids(i).ids};
        sentences=[sentences sentence];
        word_id={sentences_with_ids(i).word_id};
		word_ids=[word_ids word_id];
        token={sentences_with_ids(i).token};
		tokens=[tokens token];
        subject={dependencies(i).subj};
		subjects=[subjects subject];	
		simil=[simil similarities_all(i)];
		word=sentences_with_ids(i).word_id;
        for j=1:length(items)
            if word>=items(j).begin_word & word<=items(j).end_word
                verb_item=items(j);
                break;
            end
        end
        i
        items=items(j:end);		
        verb_items=[verb_items verb_item];
    end
    action_labels=struct('subjects',subjects,'mentions',mentions,'sentences',sentences,'tokens',tokens,'word_ids',word_ids,'items',mat2cell(verb_items,1,ones(size(verb_items))),'similarity',simil);

	%action_labels=struct('word_ids',word_ids,'items',mat2cell(verb_items,1,ones(size(verb_items))),'similarity',simil);

    
    temp_items=cat(1,[],action_labels.items);
    text_part_flag=false(size(action_labels));
    for tagname=action_tagnames
        text_part_flag=text_part_flag+strcmp(extractfield(temp_items,'tagname'),cell2mat(tagname));
    end
    action_labels=action_labels(logical(text_part_flag));	

    
    
    action_labels_temp=action_labels;
    subjects_temp=cat(1,[],{action_labels.subjects});
    action_labels=[];
    subjects=cell(0);
	subject_classes=[];
	subject_tags=cell(0);
	for i=1:size(subjects_temp,2)
		i
        if length(subjects_temp{i})>1
            for j=1:length(subjects_temp{i})
                ind = find(strcmp(unique_mentions,subjects_temp{i}{j}));
                if isempty(ind)==0
                    action_labels=[action_labels action_labels_temp(i)];
                    subjects=[subjects {subjects_temp{i}(j)}];
                    subject_classes=[subject_classes unique_mentions_classes(ind)];
                    subject_tags=[subject_tags unique_mentions_tags(ind)];
                else
                    action_labels=[action_labels action_labels_temp(i)];
                    subjects=[subjects {subjects_temp{i}(j)}];
                    subject_classes=[subject_classes 0];
                    subject_tags=[subject_tags {[]}];
                end
            end
        else
            ind = find(strcmp(unique_mentions,subjects_temp{i}));
            if isempty(ind)==0
                action_labels=[action_labels action_labels_temp(i)];
                subjects=[subjects subjects_temp(i)];
                subject_classes=[subject_classes unique_mentions_classes(ind)];
                subject_tags=[subject_tags unique_mentions_tags(ind)];
            else
                action_labels=[action_labels action_labels_temp(i)];
                subjects=[subjects subjects_temp(i)];
                subject_classes=[subject_classes 0];
                subject_tags=[subject_tags {[]}];
            end
        end
    end
	action_labels=arrayfun(@(x,y) setfield(x,'subject_tags',cell2mat(y)),action_labels,subject_tags);
	action_labels=arrayfun(@(x,y) setfield(x,'subject_classes',y),action_labels,subject_classes);
    action_labels=arrayfun(@(x,y) setfield(x,'subjects',cell2mat(y{:})),action_labels,subjects);
end