movies={'DEP','LOR','BMI','CRA','GLA'}; coordinate='face';
global movies_folder;movies_folder = '/Users/giorgosmpouritsas/Documents/movies/';
global categories_folder;categories_folder='../manual_annotation';
global categories_extended_file;categories_extended_file='/categories_ids.mat';
global categories_small_file;categories_small_file='/categories_ids_47.mat';
global mosek_path; mosek_path = '~/Documents/mosek/8/toolbox/r2014aom';

global v; v=0; global weight_choice; weight_choice='equal';
global label_set; label_set='closed'; global optflag;optflag='min';
fps=25;fps_weird=24.9997500025000;
global alpha; alpha=2.5;
global kapa; kapa=20;
global lambda;lambda=0.0001;

kernel={'sift_38','vgg_2','vgg_1'};
membership_function={'linear','step','concave_pchip','convex_pchip','normalize','gamma_sigmoid','gamma_linear','gamma_rational','gamma_s','gamma_cubic','gamma_pchip'};
membership_threshold={1,0:0.1:1,[0.01 0.1:0.1:0.8],[0.2:0.1:0.9 0.99],1,0:0.1:1,0:0.1:1,0:0.1:1,0:0.1:1,0:0.1:1,0:0.1:1};
membership_k={0,0,0,0,0,5:5:30,0,1000:2000:10000,0:0.1:1,0:0.1:1,0:0.1:1};
extend=0:10:150;

cast_list_flag=1; %only names in cast list are chosen as labels.
person_tagnames={'speaker','description','unknown'};% extract labels only from these parts of the text
action_tagnames={'description','unknown'};% extract labels only from these parts of the text
similarity_method='word2vec';

%%
for j=1:length(movies)
    movie_name=movies{j};    
    if strcmp(movie_name,'BMI')
        cast_list_flag=0;
    else
        cast_list_flag=1;
    end
    final_labels_all({movie_name},cast_list_flag,person_tagnames,action_tagnames,similarity_method);
end

hwait=waitbar(0,'Please wait...');
accuracy_text=zeros(1,5);
optflag='feas';

for j=1:length(movies)
    
    movie_name=movies{j};
    return_code=prepare_for_opt_face({movie_name},membership_function(2),membership_threshold{2}(1),0,extend(1),kernel(3),fps,fps_weird);
    if return_code(1)==0
        continue;
    end
    main;
    accuracy_text(1,j)=result{1,1}.ap;
    
    waitbar(j/length(movies))
end
close(hwait)

hwait=waitbar(0,'Please wait...');
accuracy=zeros(4,5);
optflag='min';

for j=1:length(movies)
    movie_name=movies{j};
    
    return_code=prepare_for_opt_face({movie_name},membership_function(2),membership_threshold{2}(1),0, extend(1),kernel(1),fps,fps_weird);
    if return_code(1)==0
        continue;
    end
    main;
    accuracy(1,j)=result{1,1}.ap;

    return_code=prepare_for_opt_face({movie_name},membership_function(8),membership_threshold{8}(3),membership_k{8}(3), extend(1),kernel(1),fps,fps_weird);
    if return_code(1)==0
        continue;
    end
    main;
    accuracy(2,j)=result{1,1}.ap;    

    return_code=prepare_for_opt_face({movie_name},membership_function(2),membership_threshold{2}(1),0, extend(1),kernel(3),fps,fps_weird);
    if return_code(1)==0
        continue;
    end
    main;
    accuracy(3,j)=result{1,1}.ap;
    
    return_code=prepare_for_opt_face({movie_name},membership_function(8),membership_threshold{8}(3),membership_k{8}(3), extend(1),kernel(3),fps,fps_weird);
    if return_code(1)==0
        continue;
    end
    main;
    accuracy(4,j)=result{1,1}.ap;
    
    waitbar(j/length(movies))
end
close(hwait)

accuracy=[accuracy_text;accuracy];

accuract_final=zeros(5,8);
accuracy_final(:,3)=mean(accuracy(:,[1,2]),2);
accuracy_final(:,7)=mean(accuracy(:,[3,4,5]),2);
accuracy_final(:,8)=mean(accuracy,2);
accuracy_final(:,[1,2])=accuracy(:,[1,2]);
accuracy_final(:,[4,5,6])=accuracy(:,[3,4,5]);
