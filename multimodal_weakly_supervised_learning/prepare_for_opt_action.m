function [return_code]=prepare_for_opt_action(movies,similarity_threshold,label_method,membership_function,membership_thres,membership_k,number_of_classes,extend,kernel_name,localization,fps_face,fps_weird)
global label_set
global method_of_classes
global external_background
global similarity_method
global movies_folder
global categories_folder
global categories_extended_file

removed_categories = {'other'...
    'talk'...
    'cartwheel'...
    'dive'...
    'backhand flip'...
    'handstand'...
    'pull up'...
    'somersault'...
    'dribble'...
    'golf'...
    'kick ball'...
    'shoot ball'...
    'fencing'...
    'push up'...
    'sword exercise'...
    'swing baseball bat'...
    'pantomime'...
    'ride bike'...
    'brush hair'...
    'push something'...
    ...
    };


for movie_name=movies
    movie_name=cell2mat(movie_name);
    %Inputs...
    input_script_folder=fullfile([movies_folder movie_name '/results_script']);
    input_face_folder=fullfile([movies_folder movie_name '/results_face']);
    
    result_folder=fullfile([movies_folder movie_name '/results_optimization']);
    if ~exist(result_folder,'dir')
        mkdir(result_folder)
    end
    
    %set of action classes
    load(fullfile([categories_folder '/' categories_extended_file]));
    
    %method of localization
    if strcmp(localization,'manual localization')
        input_action_folder=fullfile([movies_folder movie_name '/results_action/manual_localization']);
        input_annotation_folder=fullfile([movies_folder movie_name '/annotation/manual_localization']);
        
        %action ground truth
        load(fullfile(input_annotation_folder,['annotation_' movie_name '.mat']));
        GTa=action+1;
        
        load(fullfile(input_action_folder,[movie_name  '_c3d_features.mat']))
        tframes=[cat(1,[],c3d_features.start_frame) cat(1,[],c3d_features.end_frame)];
  
    end
    
    %action kernel
    if strcmp(kernel_name,'linear_c3d')
        load(fullfile(input_action_folder,[movie_name '_fc6_linear_kernel.mat']));
    elseif strcmp(kernel_name,'chisquared_c3d')
        load(fullfile(input_action_folder,[movie_name '_fc6_chi_kernel.mat']));
        dist=load(fullfile(input_action_folder,[movie_name '_fc6_chi_dist.mat']));
        dist=dist.dist;
    elseif strcmp(kernel_name,'linear_trajectories')
    elseif strcmp(kernel_name,'chisquared_trajectories')
    end
      
    %text entities-bags
    load(fullfile([input_script_folder '/' movie_name '_final_action_labels_' similarity_method '.mat']));
    
    Ka=double(kernel);
    Koa=[];
    [~,b]=sort(tframes(:,1));
    tframes=tframes(b,:);
    Ka=Ka(b,b);
    if strcmp(kernel_name,'chisquared_c3d')
        dist=dist(b,b);
    end
    GTa=GTa(b);

    %% 
    S=cat(1,[],action_labels.similarity);
    embeddings = cat(1,[],action_labels.embeddings);
    newcat=cat(1,[],{categories_ids.categories});
    
    if strcmp(method_of_classes,'ground truth')
        t=tabulate(action);
        [~,b]=sort(t(:,3),'descend');
        kpidx=t(b(1:number_of_classes),1)';
    elseif strcmp(method_of_classes,'text')
        S_temp=S;
        S_temp(S_temp<similarity_threshold)=0;
        S_temp=S_temp(sum(S_temp,2)~=0,:);
        [~,mind]=max(S_temp,[],2);
        t=tabulate(mind);
        [~,b]=sort(t(:,3),'descend');
        kpidx=t(b(1:number_of_classes),1)';
    end
    keep_categories=newcat(kpidx)
    
    for i=1:length(GTa)
        if isempty(find(GTa(i)-1==kpidx))
            GTa(i)=1;
        end
    end
    
    [kpidx,ikpidx]=sort(kpidx);
    keep_categories=[keep_categories(ikpidx);num2cell(kpidx)];
    S=S(:,kpidx);
    GTa=sparse(1:length(GTa),GTa,1);
    GTa=GTa(:,[1 kpidx(kpidx+1<=size(GTa,2))+1]);
    [~,i]=max(GTa,[],2);
    GTa=i;
    
    S(S<similarity_threshold)=0;
    if sum(sum(S))==0
        S=zeros(1,size(S,2));
        embeddings=zeros(1,size(embeddings,2));
        action_labels=action_labels(1);
    else
        action_labels=action_labels(sum(S,2)~=0);
        embeddings = embeddings(sum(S,2)~=0,:);
        S=S(sum(S,2)~=0,:);
        prob=bsxfun(@(x,y) x/y,S',sum(S'));
        S=double(prob');
    end
    

    
    %%   
    begin_frame=zeros(1,length(action_labels));
    end_frame=zeros(1,length(action_labels));
    for i=1:length(action_labels)
        begin_frame(i)=action_labels(i).items.begin_frame;
        end_frame(i)=action_labels(i).items.end_frame;
        bags(i).f=round([begin_frame(i) end_frame(i)]*fps_face/fps_weird);
        bags(i).ascore=action_labels(i).items.ascore;
        bags(i).person= action_labels(i).subject_classes;
        bags(i).similarity=S(i,:);
        bags(i).embeddings=embeddings(i,:);
    end
    [~,b]=sort(begin_frame);
    bags=bags(b);
    action_labels=action_labels(b);
    S=cat(1,[],bags.similarity);
    embeddings=cat(1,[],bags.embeddings);
    
    %% 
    f=cat(1,[],bags.f);
    tw=f(:,2)-f(:,1)+1;
    tu=tframes(:,2)-tframes(:,1)+1;
    %ratio=(tu*(1./tw)')';
    %ratio=[ratio;zeros(1,size(ratio,2))];
    extend=extend/mean(tw);
    
    [A,overlap,probabilities ]  = tracks_in_bag(f, tframes,extend);
    A=probabilities;
    A=A';
    A_bg=A(end,:)==1;%no fuzzy operator appllied to background
    A=A(1:end-1,:);
    
    if strcmp(membership_function,'gamma_sigmoid')
        A=sigmf(A,[membership_k/membership_thres,membership_thres]);
    end
    if strcmp(membership_function,'gamma_linear')
        A_new=A;
        A_new(A<membership_thres)=0;
        A_new(A>=membership_thres)=(A(A>=membership_thres)-membership_thres)./(1-membership_thres);
        A=A_new;
    end
    if strcmp(membership_function,'gamma_rational')
        A_new=A;
        A_new(A<membership_thres)=0;
        A_new(A>=membership_thres)=(membership_k*(A(A>=membership_thres)-membership_thres).^2)./(1+membership_k*(A(A>=membership_thres)-membership_thres).^2);
        A=A_new;
    end
    if strcmp(membership_function,'gamma_s')
        A=smf(A,[membership_thres,membership_k]);
    end
    if strcmp(membership_function,'gamma_cubic')
        A=interp1([0 membership_thres membership_k 1],[0 0 1 1],A,'pchip');
    end
    if strcmp(membership_function,'normalize')
        prob=bsxfun(@(x,y) x/y,A',sum(A'));
        prob(isnan(prob))=0;
        A=double(prob');
    end
    if strcmp(membership_function,'gamma_pchip')
        A=interp1([0 membership_thres 1],[0 membership_k 1],A,'pchip');
    end
    
    if strcmp(membership_function,'step')
        if membership_thres==1
            A=A>=membership_thres;
        else
            A=A>membership_thres;
        end
        
    elseif strcmp(membership_function,'linear')
    elseif strcmp(membership_function,'concave_pchip')
        A=interp1([0 membership_thres 1],[0 0.8 1],A,'pchip');
    elseif strcmp(membership_function,'convex_pchip')
        A=interp1([0 membership_thres 1],[0 0.2 1],A,'pchip');
    end
    A=[A;A_bg];

    
    other_similarities=zeros(size(S,1),1);
    S=[other_similarities S;ones(size(A,1)-length(bags),1) zeros((size(A,1)-length(bags)),size(S,2))];
    embeddings = [embeddings; zeros(1,size(embeddings,2))];
    S(isnan(S))=0;
    l=length(bags);
    for i=1:size(A,1)-length(bags)
        bags(l+i).ascore=1;
        bags(l+i).similarity=S(l+i,:);
        bags(l+i).embeddings=embeddings(l+i,:);
    end
    %%      8)
    if strcmp(label_set,'open')==1
        toeval=GTa~=1;
    elseif strcmp(label_set,'closed')==1
        GTa=GTa-1;
        GTa(GTa==0)=max(GTa)+1;
        
        S=S(1:end-1,2:end);
        embeddings=embeddings(1:end-1,:);
        bags=bags(1:end-1);
        
        A=A(1:end-1,:);
        
        toeval=GTa~=max(GTa);
        
        Ka=Ka(GTa~=max(GTa),GTa~=max(GTa));
        if strcmp(kernel_name,'chisquared_c3d')
            dist=dist(GTa~=max(GTa),GTa~=max(GTa));
        end
        
        tframes=tframes(GTa~=max(GTa),:);
        A=A(:,GTa~=max(GTa));
        toeval=toeval(GTa~=max(GTa));
        GTa=GTa(GTa~=max(GTa));
    end
    if strcmp(kernel_name,'chisquared_c3d')
        Ka=exp(-dist/(mean(dist(:)+ eps)));
    end
    
    if sum(sum(S))~=0
        return_code(1)=sum(sum(A));
        return_code(2)=sum(sum(A))/(size(A,1)*size(A,2));
        return_code(3)=mean(tw);  
    else 
        return_code(1)=0;
        return_code(2)=0;
        return_code(3)=0;
    end
    
    %%     9)
    if strcmp(label_method,'maximum')
        for i=1:size(S,1)
            [~,mind]=max(S(i,:)');
            if max(S(i,:)')~=0
                S(i,mind) = 1;
                S(i,setdiff(1:size(S,2),mind))=0;
            end
        end
    elseif strcmp(label_method,'probabilities')
        S=S;
    end
    
    %% The following are not mentioned in the paper
    % This variable can be used to add information from pre-trained
    % classifier
    probs=zeros(size(Ka,1),size(S,2));
    % These variables can be used to incorporate information from the face
    % recognition system - ignore this
    B= ones(size(Ka,1),1);
    T= 1;
    S1=ones(size(A,1),1);
    norms = sqrt(sum(embeddings.^2,2));
    embeddings_normalized = bsxfun(@rdivide,embeddings,norms(:));
    K_embeddings = embeddings_normalized*embeddings_normalized';
    save(fullfile(result_folder,'data_new_experiment.mat'),'GTa','Ka','Koa','tframes','toeval','S','A','T','B','S1','probs','action_labels','keep_categories','K_embeddings');
    
    
end
end

function [bags_temp, similarity]=uniquebags(bags_temp,similarity)
temp=cat(1,[],bags_temp.f);
temp1=similarity;
temp=[temp temp1];
temp1=cat(1,[],bags_temp.ascore);
temp=[temp temp1];
temp1=cat(1,[],{bags_temp.person})';
temp1(cellfun(@isempty,(cat(1,[],{bags_temp.person}))))={-100};
temp1=cell2mat(temp1);
temp=[temp temp1];
temp=mat2cell(temp,ones(1,size(temp,1)));
[~,itemp,~]=uniquecell(temp);
bags_temp=bags_temp(sort(itemp));
similarity=similarity(sort(itemp),:);
end


function [bags,S]=create_bags(S,action_labels,person_labels,fps_face,fps_weird)
begin_frame=zeros(size(action_labels));
end_frame=zeros(size(action_labels));

bags=struct();
bags2=struct();
act_sentence=cat(1,[],action_labels.sentences);
pers_sentence=cat(1,[],person_labels.sentences);
map=bsxfun(@eq, act_sentence,pers_sentence(:)');
k=1;
for i=1:size(action_labels,2)
    i
    
    begin_frame(i)=action_labels(i).items.begin_frame;
    end_frame(i)=action_labels(i).items.end_frame;
    bags(i).f=round([begin_frame(i) end_frame(i)]*fps_face/fps_weird);
    bags(i).ascore=action_labels(i).items.ascore;
    bags(i).person=-100;
    bags(i).similarity=S(i,:);
    if isempty(find(map(i,:)==1))
        if k==1
            bags2=bags;
        else
            bags2(k)=bags(i);
        end
        begin_frame1(k)=action_labels(i).items.begin_frame;
        end_frame1(k)=action_labels(i).items.end_frame;
        k=k+1;
    else
        for j=find(map(i,:)==1)
            if k==1
                bags2=bags;
            else
                bags2(k)=bags(i);
            end
            bags2(k).person=person_labels(j).classes;
            begin_frame1(k)=action_labels(i).items.begin_frame;
            end_frame1(k)=action_labels(i).items.end_frame;
            k=k+1;
        end
    end
end
bags=bags2;
begin_frame=begin_frame1;
[~,b]=sort(begin_frame);
bags=bags(b);
S=cat(1,[],bags.similarity);
%[bags, S]=uniquebags(bags,S);

end