function [person_names,word_ids,dependencies,sentences_with_ids]=labels_extractor_simple(struct_name,person_tags_name,input_folder)
	load(fullfile([input_folder '/' struct_name]));
	load(fullfile([input_folder '/' person_tags_name]));
	person_sentences=[];
	person_tokens=[];
	person_mentions=cell(0);
	person_word_ids=[];


	pairs_neg=cell(0);
	pairs_subj=cell(0);
	pairs_obj=cell(0);
	pairs_verb=cell(0);
	pairs_phrasal=cell(0);
	pairs_adverb=cell(0);
	pairs_nmod=cell(0);
	pairs_prep_nmod=cell(0);
	sentence_id=cell(0);
	verb_word_id=cell(0);
	verb_token=cell(0);
    count=1;
    offset_begin=[];
	for i=1:size(root.document.sentences.sentence,2)
        
       	idx=cell(0);
		idx_word_id=[];
		idx_token=[];
        
		for j=1:size(root.document.sentences.sentence{1,i}.tokens.token,2)
            
			if size(root.document.sentences.sentence{1,i}.tokens.token,2)>1
                word_id(count)=count;
                offset_begin=[offset_begin str2num(root.document.sentences.sentence{1,i}.tokens.token{1,j}.CharacterOffsetBegin)+1];
                count=count+1;
                
                % find all the verbs
				if strcmp(root.document.sentences.sentence{1,i}.tokens.token{1,j}.POS,'VB')==1 ||...
				   strcmp(root.document.sentences.sentence{1,i}.tokens.token{1,j}.POS,'VBD')==1 ||...
				   strcmp(root.document.sentences.sentence{1,i}.tokens.token{1,j}.POS,'VBG')==1 ||...
				   strcmp(root.document.sentences.sentence{1,i}.tokens.token{1,j}.POS,'VBN')==1 ||...
				   strcmp(root.document.sentences.sentence{1,i}.tokens.token{1,j}.POS,'VBP')==1 ||...
				   strcmp(root.document.sentences.sentence{1,i}.tokens.token{1,j}.POS,'VBZ')==1;
				   idx=[idx root.document.sentences.sentence{1,i}.tokens.token{1,j}.word];
				   idx_word_id=[idx_word_id word_id(end)];
				   idx_token=[idx_token str2num(root.document.sentences.sentence{1,i}.tokens.token{1,j}.('@id'))];
                end
                
                % find all the person annotations
                if isfield(root.document.sentences.sentence{1,i}.tokens.token{1,j},'NER')
                    if strcmp(root.document.sentences.sentence{1,i}.tokens.token{1,j}.NER,'PERSON')==1
                        person_mentions=[person_mentions root.document.sentences.sentence{1,i}.tokens.token{1,j}.word];
                        person_tokens=[person_tokens str2num(root.document.sentences.sentence{1,i}.tokens.token{1,j}.('@id'))];
                        person_sentences=[person_sentences str2num(root.document.sentences.sentence{1,i}.('@id'))];    
                        person_word_ids=[person_word_ids word_id(end)];
                    end
                end
            else
                word_id(count)=count;
                offset_begin=[offset_begin str2num(root.document.sentences.sentence{1,i}.tokens.token.CharacterOffsetBegin)+1];
                count=count+1;
                
                % find all the verbs
				if strcmp(root.document.sentences.sentence{1,i}.tokens.token.POS,'VB')==1 ||...
				   strcmp(root.document.sentences.sentence{1,i}.tokens.token.POS,'VBD')==1 ||...
				   strcmp(root.document.sentences.sentence{1,i}.tokens.token.POS,'VBG')==1 ||...
				   strcmp(root.document.sentences.sentence{1,i}.tokens.token.POS,'VBN')==1 ||...
				   strcmp(root.document.sentences.sentence{1,i}.tokens.token.POS,'VBP')==1 ||...
				   strcmp(root.document.sentences.sentence{1,i}.tokens.token.POS,'VBZ')==1;
				   idx=[idx root.document.sentences.sentence{1,i}.tokens.token.word];
				   idx_word_id=[idx_word_id word_id(end)];
				   idx_token=[idx_token str2num(root.document.sentences.sentence{1,i}.tokens.token{1,j}.('@id'))];
                end
                
                % find all the person annotations
                if isfield(root.document.sentences.sentence{1,i}.tokens.token,'NER')
                    if strcmp(root.document.sentences.sentence{1,i}.tokens.token.NER,'PERSON')==1
                        person_mentions=[person_mentions root.document.sentences.sentence{1,i}.tokens.token.word];
                        person_tokens=[person_tokens str2num(root.document.sentences.sentence{1,i}.tokens.token.('@id'))];
                        person_sentences=[person_sentences str2num(root.document.sentences.sentence{1,i}.('@id'))]; 
                        person_word_ids=[person_word_ids word_id(end)];
                    end
                end
			end   
        end
        
		for k=1:size(idx,2)
            
			idx2=[]; 
			is_aux=0;
            
			for j=1:size(root.document.sentences.sentence{1,i}.dependencies{1,5}.dep,2)
				if  strcmp(idx{k},root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.governor.('#text'))==1
					idx2=[idx2 j];
                end
                
                % Ignore auxilliary verbs
				if  strcmp(idx{k},root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.dependent.('#text'))==1 &&...
						(strcmp('aux',root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.('@type'))==1 ||...
						strcmp('auxpass',root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.('@type'))==1)
					is_aux=1;
					break;
				end
            end
            
			if is_aux==0
                
                % Find dependencies of interest
				flag_subj=0;
				flag_obj=0;
				flag_adverb=0;
				flag_phrasal=0;
				flag_nmod=0;
				flag_neg=0;
				
				pairs_verb=[pairs_verb idx(k)];
				sentence_id=[sentence_id {i}];
				verb_word_id=[verb_word_id {idx_word_id(k)}];
				verb_token=[verb_token {idx_token(k)}];
				temp_subj=cell(1);
				temp_subj{1}=cell(1);
				temp_obj=cell(1);
				temp_obj{1}=cell(1);
				temp_adverb=cell(1);
				temp_adverb{1}=cell(1);
				temp_phrasal=cell(1);
				temp_phrasal{1}=cell(1);
				temp_nmod=cell(1);
				temp_nmod{1}=cell(1);
				temp_prep_nmod=cell(1);
				temp_prep_nmod{1}=cell(1);
				for j=idx2
                    
                    % add a negation flag to ignore these verbs as well
					if strcmp('neg',root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.('@type'))==1
						  flag_neg=1;
                    end
                    
                    % subject
					if strcmp('nsubj',root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.('@type'))==1
						  flag_subj=1;
						  temp_subj{1}=[temp_subj{1} root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.dependent.('#text')];
                    end
                    
                    % controlling subject
					if strcmp('nsubj:xsubj',root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.('@type'))==1
						  flag_subj=1;
						  temp_subj{1}=[temp_subj{1} root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.dependent.('#text')];
                    end
                    
                    % passive nominal subject
					if strcmp('nsubjpass',root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.('@type'))==1
						  flag_subj=1;
						  temp_subj{1}=[temp_subj{1} root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.dependent.('#text')];
                    end
                    
                    % direct object
					if strcmp('dobj',root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.('@type'))==1
						  temp_obj{1}=[temp_obj{1} root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.dependent.('#text')];
						  flag_obj=1;
                    end
                    
                    % phrasal verb particle
					if strcmp('compound:prt',root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.('@type'))==1
						temp_phrasal{1}=[temp_phrasal{1} root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.dependent.('#text')];
						flag_phrasal=1;
                    end
                    
                    % adverb modifier
					if strcmp('advmod',root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.('@type'))==1
						temp_adverb{1}=[temp_adverb{1} root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.dependent.('#text')];
						flag_adverb=1;
                    end
                    
                    % nominal modifier
					if isempty(regexp(root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.('@type'),'(nmod:).*'))~=1
						temp_nmod{1}=[temp_nmod{1} root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.dependent.('#text')];
						temp_prep_nmod{1}=[temp_prep_nmod{1} root.document.sentences.sentence{1,i}.dependencies{1,5}.dep{1,j}.('@type')(6:end)];
						flag_nmod=1;
					end
                end
                
				pairs_neg=[pairs_neg flag_neg];
				if flag_subj==0
					pairs_subj=[pairs_subj cell(1)];
				else
					temp_subj{1}=temp_subj{1}(2:end);
					pairs_subj=[pairs_subj temp_subj];
				end
				if flag_obj==0
					pairs_obj=[pairs_obj cell(1)];
				else
					temp_obj{1}=temp_obj{1}(2:end);
					pairs_obj=[pairs_obj temp_obj];
				end
				if flag_phrasal==0
					pairs_phrasal=[pairs_phrasal cell(1)];
				else
					temp_phrasal{1}=temp_phrasal{1}(2:end);
					pairs_phrasal=[pairs_phrasal temp_phrasal];
				end
				if flag_adverb==0
					pairs_adverb=[pairs_adverb cell(1)];
				else
					temp_adverb{1}=temp_adverb{1}(2:end);
					pairs_adverb=[pairs_adverb temp_adverb];
				end
				if flag_nmod==0
					pairs_nmod=[pairs_nmod cell(1)];
					pairs_prep_nmod=[pairs_prep_nmod cell(1)];    
				else
					temp_nmod{1}=temp_nmod{1}(2:end);
					pairs_nmod=[pairs_nmod temp_nmod];
					temp_prep_nmod{1}=temp_prep_nmod{1}(2:end);
					pairs_prep_nmod=[pairs_prep_nmod temp_prep_nmod];
				end
			end
		end

	 
    end
    
    % Create person labels
	person_classes=zeros(size(person_sentences));
	person_tags=cell(size(person_sentences));
	for i=1:size(tags,2)
		indices = find(strcmp(tags(i),person_mentions));
		person_classes(indices)=classes(i);
		person_tags(indices)=tags(i);
    end
    
    % Add labels not contained in the cast list - when other methods are
    % used, such as NER
    
	unknown_indices=find(person_classes==0);
	if length(unknown_indices)>1
		str=person_mentions(unknown_indices);
		numStr=size(str,2);
		D = zeros(numStr,numStr);
		for i=1:numStr
			for j=i+1:numStr
				D(i,j) = strdist(str{i},str{j})/max(length(str{i}),length(str{j}));
			end
		end
		D = D + D';
		D=D>0.2;%all the strings that have a dissimilarity below this number are categorized in the same cluster
		D = squareform(D, 'tovector');
		T = linkage(double(D), 'single');
		C = cluster(T,'cutoff',0.5);
		new_names=cell(1,numStr);
		for i=1:max(C)
			new_names(C==i)=str(find(C==i,1));
		end
		C=C+max(classes);
		person_classes(unknown_indices)=C;
		person_tags(unknown_indices)=new_names;
    elseif length(unknown_indices)==1
		person_classes(unknown_indices)=max(classes)+1;
		person_tags(unknown_indices)=person_mentions(unknown_indices);        
	end
	person_names=struct('tags',person_tags,'classes',num2cell(person_classes),'mentions',person_mentions,'sentences',num2cell(person_sentences),'tokens',num2cell(person_tokens),'word_ids',num2cell(person_word_ids));   
	
    
    word_ids=struct('word_id',word_id,'offset_begin',offset_begin);


	dependencies=struct('subj',pairs_subj,'verb',pairs_verb,'prep',pairs_phrasal,'adverb',pairs_adverb,'obj',pairs_obj,'prep_nmod',pairs_prep_nmod,'nmod',pairs_nmod,'negation_flag',pairs_neg,'sentence_id',sentence_id,'word_id',verb_word_id);
	
    % create short sentences - these will be used to calculate semantic
    % similarity
    
    sentences_to_process=cell(size(dependencies));
	for i=1:size(dependencies,2)
        
		if dependencies(i).negation_flag==0
			temp1=dependencies(i).verb;
			temp=[];
			if size(dependencies(i).prep,2)>1
				for j=1:size(dependencies(i).prep,2)
					temp=[temp ' ' dependencies(i).prep{j}];
				end
			else
				temp=[dependencies(i).prep];
			end
			temp1=[temp1 ' ' temp];
			temp=[];
			if size(dependencies(i).adverb,2)>1
				for j=1:size(dependencies(i).adverb,2)
					temp=[temp ' ' dependencies(i).adverb{j}];
				end
			else
				temp=[dependencies(i).adverb];
			end
			temp1=[temp1 ' ' temp];
			temp=[];
			if size(dependencies(i).obj,2)>1
				for j=1:size(dependencies(i).obj,2)
					temp=[temp ' ' dependencies(i).obj{j}];
				end
			else
				temp=[dependencies(i).obj];
			end
			temp1=[temp1 ' ' temp];
			temp=[];
			if size(dependencies(i).prep_nmod,2)>1
				for j=1:size(dependencies(i).prep_nmod,2)
                    if strcmp(dependencies(i).prep_nmod{j},'agent')==0
                        temp=[temp ' ' dependencies(i).prep_nmod{j} ' ' dependencies(i).nmod{j}];
                    else
                        temp=[temp ' by ' dependencies(i).nmod{j}];
                    end   
				end
			else
				temp=[dependencies(i).prep_nmod ' ' dependencies(i).nmod];
			end
			temp1=[temp1 ' ' temp];
			if iscell(temp1)
				sentences_to_process(i)={cell2mat(temp1)};
			else
				sentences_to_process(i)={temp1};
		
			end
		end
	end
	sentences_with_ids=struct('sentences',sentences_to_process,'ids',sentence_id,'neg',pairs_neg,'word_id',verb_word_id,'token',verb_token);
end
