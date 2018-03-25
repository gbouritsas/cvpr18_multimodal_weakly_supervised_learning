function [return_code,unique_classes]=prepare_for_opt_face(movies,membership_function,membership_thres,membership_k,extend,kernel,fps_face,fps_weird)
global label_set
global external_background;
global movies_folder

for movie_name=movies
    movie_name=cell2mat(movie_name);
    % Modify these paths if needed.
    input_script_folder=fullfile([movies_folder movie_name '/results_script']);
    input_face_folder=fullfile([movies_folder movie_name '/results_face']);
    input_annotation_folder=fullfile([movies_folder movie_name '/annotation']);
    result_folder=fullfile([movies_folder movie_name '/results_optimization']);
    if ~exist(result_folder,'dir')
        mkdir(result_folder)
    end


    %face kernel
    if strcmp(kernel,'sift_38')
        load(fullfile(input_face_folder,'kernel_sift_no_pconf.mat'));
        Kav=Ks;
    elseif    strcmp(kernel,'vgg_2')
        load(fullfile(input_face_folder,'kernel_vgg_frontal_profile_no_pconf.mat'));
        Kav=Kv;
    elseif    strcmp(kernel,'vgg_1')
        load(fullfile(input_face_folder,'kernel_vgg_all_no_pconf.mat'));
    end
    %text entities-bags
    load(fullfile([input_script_folder '/' movie_name '_final_person_labels.mat']));
    %face ground truth
    if ~exist(fullfile(input_annotation_folder,'face.mat'))
        face=zeros(size(Kav,1),1);
    else
        load(fullfile(input_annotation_folder,'face.mat'));
        face=cell2mat(face(:,2));
    end

    %set of person classes
    load(fullfile([input_script_folder '/' movie_name '_init_person_labels.mat']));
    %save the person set to inspect the results
    [uc,iuc,~]=unique(cat(1,[],person_names.classes));
    up=cat(1,[],{person_names(iuc).tags});
    person_text_set=struct('names',up','ids',num2cell(uc));
    save(fullfile(input_script_folder,[movie_name '_person_text_set.mat']),'person_text_set');
    %
    
    %1)
    Ka=double(Kav);
    %2)
    GTa=face+1;

    %3)
    if ~exist(fullfile(input_face_folder,'tframes.mat'),'file')
        [tframes,track_id] = strend_frames(input_face_folder);
        save(fullfile(input_face_folder,'tframes.mat'),'tframes','track_id');
    else
        load(fullfile(input_face_folder,'tframes.mat'))
    end
    %4)
    Koa=[];
    [~,b]=sort(tframes(:,1));
    tframes=tframes(b,:);
    Ka=Ka(b,b);
    GTa=GTa(b);
    %%      5)

    classes=cat(1,[],person_labels.classes);
    S=zeros(length(classes),max(classes));
    for i=1:length(classes)
        S(i,classes(i))=1;
    end
    unique_classes=unique(classes);
    unique_ids=cell(length(unique_classes),1);
    ids_temp=cat(1,[],person_text_set.ids);
    for i=1:length(unique_classes)
        unique_ids(i)={person_text_set(find(ids_temp==unique_classes(i))).names};
    end
    S=S(:,unique_classes);
    GTa=sparse(1:length(GTa),GTa,1);
    GTa=GTa(:,[1 unique_classes(unique_classes+1<=size(GTa,2))'+1]);
    [~,i]=max(GTa,[],2);
    GTa=i;

    %%      6)

    begin_frame=zeros(1,length(person_labels));
    end_frame=zeros(1,length(person_labels));
    for i=1:length(person_labels)
        begin_frame(i)=person_labels(i).items.begin_frame;
        end_frame(i)=person_labels(i).items.end_frame;
        bags(i).f=round([begin_frame(i) end_frame(i)]*fps_face/fps_weird);
        bags(i).ascore=person_labels(i).items.ascore;

    end
    [~,b]=sort(begin_frame);
    bags=bags(b);
    S=S(b,:);
    %%		7)
    f=cat(1,[],bags.f);
    tw=f(:,2)-f(:,1)+1;
    tu=tframes(:,2)-tframes(:,1)+1;
    ratio=(tu*(1./tw)')';
    ratio=[ratio;zeros(1,size(ratio,2))];
    extend=extend/mean(tw);
    [ A,overlap,probabilities ]  = tracks_in_bag(f, tframes,extend);
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
        if membership_thres>0.8
            return_code=0;
            return;
        end
        A=interp1([0 membership_thres 1],[0 0.8 1],A,'pchip');
    elseif strcmp(membership_function,'convex_pchip')
        if membership_thres<0.2
            return_code=0;
            return;
        end
        A=interp1([0 membership_thres 1],[0 0.2 1],A,'pchip');
    end
    A=[A;A_bg];



    other_similarities=zeros(size(S,1),1);
    S=[other_similarities S;ones(size(A,1)-length(bags),1) zeros((size(A,1)-length(bags)),size(S,2))];
    S(isnan(S))=0;
    l=length(bags);
    for i=1:size(A,1)-length(bags)
        bags(l+i).ascore=1;
        bags(l+i).similarity=S(l+i,:);
    end
    %%     8)
    if strcmp(label_set,'open')==1
        toeval=GTa~=1;
    elseif strcmp(label_set,'closed')==1
        GTa=GTa-1;
        GTa(GTa==0)=max(GTa)+1;
        S=S(1:end-1,2:end);
        bags=bags(1:end-1);
        A=A(1:end-1,:);
        toeval=GTa~=max(GTa);

        Ka=Ka(GTa~=max(GTa),GTa~=max(GTa));
        tframes=tframes(GTa~=max(GTa),:);
        A=A(:,GTa~=max(GTa));
        toeval=toeval(GTa~=max(GTa));
        GTa=GTa(GTa~=max(GTa));
    end
    %%     9)
    probs=zeros(size(Ka,1),size(S,2));
    bag_time=bags;
    B= ones(size(Ka,1),1);
    T= 1;
    S1=ones(size(A,1),1);
    save(fullfile(result_folder,'data_new_experiment.mat'),'GTa','Ka','Koa','tframes','toeval','S','A', 'T', 'B', 'S1', 'bag_time','probs','unique_classes','unique_ids');
    return_code=1;
    % checking which track is in which bag



end
end

function [bags_temp, similarity]=uniquebags(bags_temp,similarity)
temp=cat(1,[],bags_temp.f);
temp1=similarity;
temp=[temp temp1];
temp1=cat(1,[],bags_temp.ascore);
temp=[temp temp1];
temp=mat2cell(temp,ones(1,size(temp,1)));
[~,itemp,~]=uniquecell(temp);
bags_temp=bags_temp(sort(itemp));
similarity=similarity(sort(itemp));
end
