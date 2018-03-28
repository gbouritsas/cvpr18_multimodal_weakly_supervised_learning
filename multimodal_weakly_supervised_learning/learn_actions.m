coordinate='action';

% Modify these paths
global movies; movies={'DEP','LOR','BMI','CRA','GLA'}; 
global movies_folder;movies_folder = '../movies/';
global categories_folder;categories_folder='../manual_annotation';
global categories_extended_file;categories_extended_file='/categories_ids.mat';
global categories_small_file;categories_small_file='/categories_ids_47.mat';
global mosek_path; mosek_path = '~/Documents/mosek/8/toolbox/r2014aom'; addpath(mosek_path);
global cvx_path; cvx_path = '~/Documents/cvx/cvx_setup.m'; run(cvx_path);

% approximate and exact fps: ignore this step
fps=25;fps_weird=24.9997500025000;

% Can be used when prior information is incorporated in the objective function: ignore this step
global v; v=0; 

% Weights slack variables according to the repetition of each constraint
global weight_choice; weight_choice='equal';

% discard ('closed') or keep ('open') background characters
global label_set; label_set='closed'; 

% run optimization on video+text ('min') or text only ('feas')
global optflag;optflag='min';

% Optimization hyperparameters
global alpha;alpha=2;
global kapa;kapa=1;
global lambda;lambda=0.000001;

% The method according to which the frequency of classes is calculated
global method_of_classes;method_of_classes='ground truth';

global bg_concept;bg_concept=false; global alpha_2;alpha_2   = 0.6; % Miech et al., ICCV 2017 background constraint
global external_background;external_background=false; % Bojanowski et al., ICCV 2013 background constraint using features computed on external characters

% The method used to compute similarities
global similarity_method; similarity_method='wordnet';

% Different representation methods
kernel={'linear_c3d','chisquared_c3d','linear_trajectories','chisquared_trajectories'};

% Here you can add other action localization methods
localization={'manual localization', 'facetrack localization'};

% Single or Probabilistic Label MIL
label_method={'maximum','probabilities'};
% Discard similarities below this thresold
similarity_threshold=0:0.1:1;
% Different membership functions and hyperparameters \alpha, k and \epsilon
membership_function={'linear','step','concave_pchip','convex_pchip','normalize','gamma_sigmoid','gamma_linear','gamma_rational','gamma_s','gamma_cubic','gamma_pchip'};
membership_threshold={1,0:0.1:1,[0.01 0.1:0.1:0.8],[0.2:0.1:0.9 0.99],1,0:0.1:1,0:0.1:1,0:0.1:1,0:0.1:1,0:0.1:1,0:0.1:1};
membership_k={0,0,0,0,0,5:5:30,0,1000:2000:10000,0:0.1:1,0:0.1:1,0:0.1:1};
extend=0:10:150;
%%

%
accuracy=zeros(6,5,5);
% optflag='feas';

multiWaitbar( 'CloseAll' );
multiWaitbar( 'methods', 0 );
multiWaitbar( 'classes', 0, 'Color', 'g' );
multiWaitbar( 'movies', 0, 'Color', 'b' );

% for k=2:2:10
%     for j=1:length(movies)
%         movie_name=movies{j};
%         return_code=prepare_for_opt_action({movie_name}, similarity_threshold(end), label_method(1),...
%                     membership_function(2), membership_threshold{2}(1), 0,...
%                     k, extend(1), kernel(1), localization(1), fps, fps_weird);
%         if return_code(1)==0
%             datapath = [movies_folder movie_name '/results_optimization/data_new_experiment.mat'];
%             load(datapath);
%             Z=randi(max(GTa),[length(GTa),1]);
%             Y=sparse(1:length(GTa),GTa,1);
%             Z=sparse(1:length(Z),Z,1);
%             result=evaluate(Z, Y,[]);
%             accuracy(1,k/2,j)=result.ap;
%         else
%             result = main (movie_name, coordinate);
%             accuracy(1,k/2,j)=result{1,1}.ap;
%         end
%         multiWaitbar( 'movies', j/5, 'Color', 'b' );
%     end
%     multiWaitbar( 'classes', 'Value', k/10 );
%     multiWaitbar( 'movies', 'Reset' );
% end
% multiWaitbar( 'classes', 'Reset' );
% multiWaitbar( 'methods', 'Value', 1/6 );
% 
% 
% optflag='min';
% 
% for k=2:2:10
%     for j=1:length(movies)
%         movie_name=movies{j};   
%         return_code=prepare_for_opt_action({movie_name}, similarity_threshold(end), label_method(1),...
%                     membership_function(2),membership_threshold{2}(1), 0,...
%                     k, extend(1), kernel(1), localization(1), fps, fps_weird);
%         if return_code(1)==0
%             datapath = [movies_folder movie_name '/results_optimization/data_new_experiment.mat'];
%             load(datapath);
%             randint = randi(max(GTa));
%             Z=randint*ones(length(GTa),1);
%             Y=sparse(1:length(GTa),GTa,1);
%             Z=sparse(1:length(Z),Z,1);
%             result=evaluate(Z, Y,[]);
%             accuracy(2,k/2,j)=result.ap;
%         else
%             result = main (movie_name, coordinate);
%             accuracy(2,k/2,j)=result{1,1}.ap;
%         end
%         multiWaitbar( 'movies', j/5, 'Color', 'b' );
%     end
%     multiWaitbar( 'classes', 'Value', k/10 );
%     multiWaitbar( 'movies', 'Reset' );
% end
% multiWaitbar( 'classes', 'Reset' );
% multiWaitbar( 'methods', 'Value', 2/6 );
% 
% for k=2:2:10
%     for j=1:length(movies)
%         movie_name=movies{j};   
%         return_code=prepare_for_opt_action({movie_name}, 0.4, label_method(1),...
%                     membership_function(2), membership_threshold{2}(1), 0,...
%                     k, extend(1), kernel(1), localization(1), fps, fps_weird);
%         if return_code(1)==0
%             datapath = [movies_folder movie_name '/results_optimization/data_new_experiment.mat'];
%             load(datapath);
%             randint = randi(max(GTa));
%             Z=randint*ones(length(GTa),1);
%             Y=sparse(1:length(GTa),GTa,1);
%             Z=sparse(1:length(Z),Z,1);
%             result=evaluate(Z, Y,[]);
%             accuracy(3,k/2,j)=result.ap;
%         else
%             result = main (movie_name, coordinate);
%             accuracy(3, k/2, j)=result{1,1}.ap;
%         end
%         multiWaitbar( 'movies', j/5, 'Color', 'b' );
%     end
%     multiWaitbar( 'classes', 'Value', k/10 );
%     multiWaitbar( 'movies', 'Reset' );
% end
% multiWaitbar( 'classes', 'Reset' );
% multiWaitbar( 'methods', 'Value', 3/6 );
% 
% for k=2:2:10
%     for j=1:length(movies)
%         movie_name=movies{j};   
%         return_code=prepare_for_opt_action({movie_name}, 0.4, label_method(2),...
%                     membership_function(2), membership_threshold{2}(1), 0,...
%                     k, extend(1), kernel(1),localization(1),fps,fps_weird);
%         if return_code(1)==0
%             datapath = [movies_folder movie_name '/results_optimization/data_new_experiment.mat'];
%             load(datapath);
%             randint = randi(max(GTa));
%             Z=randint*ones(length(GTa),1);
%             Y=sparse(1:length(GTa),GTa,1);
%             Z=sparse(1:length(Z),Z,1);
%             result=evaluate(Z, Y,[]);
%             accuracy(4,k/2,j)=result.ap;
%         else
%             result = main (movie_name, coordinate);
%             accuracy(4,k/2,j)=result{1,1}.ap;
%         end
%         multiWaitbar( 'movies', j/5, 'Color', 'b' );
%     end
%     multiWaitbar( 'classes', 'Value', k/10 );
%     multiWaitbar( 'movies', 'Reset' );
% end
% multiWaitbar( 'classes', 'Reset' );
% multiWaitbar( 'methods', 'Value', 4/6 );
% 
% for k=2:2:10
%     for j=1:length(movies)
%         movie_name=movies{j};   
%         return_code=prepare_for_opt_action({movie_name}, 0.4, label_method(1),...
%                     membership_function(8),membership_threshold{8}(2),membership_k{8}(3),...
%                     k, extend(11), kernel(1), localization(1), fps, fps_weird);
%         if return_code(1)==0
%             datapath = [movies_folder movie_name '/results_optimization/data_new_experiment.mat'];
%             load(datapath);
%             randint = randi(max(GTa));
%             Z=randint*ones(length(GTa),1);
%             Y=sparse(1:length(GTa),GTa,1);
%             Z=sparse(1:length(Z),Z,1);
%             result=evaluate(Z, Y,[]);
%             accuracy(5,k/2,j)=result.ap;
%         else
%             result = main (movie_name, coordinate);
%             accuracy(5, k/2, j)=result{1,1}.ap;
%         end
%         multiWaitbar( 'movies', j/5, 'Color', 'b') ;
%     end
%     multiWaitbar( 'classes', 'Value', k/10 );
%     multiWaitbar( 'movies', 'Reset' );
% end
% multiWaitbar( 'classes', 'Reset' );
% multiWaitbar( 'methods', 'Value', 5/6 );

for k=2:2:10
    for j=1:length(movies)
        movie_name=movies{j};   
        return_code=prepare_for_opt_action({movie_name}, 0.4, label_method(2),...
                    membership_function(8),membership_threshold{8}(2),membership_k{8}(3),...
                    k, extend(11), kernel(1), localization(1), fps, fps_weird);
        if return_code(1)==0
            datapath = [movies_folder movie_name '/results_optimization/data_new_experiment.mat'];
            load(datapath);
            randint = randi(max(GTa));
            Z=randint*ones(length(GTa),1);
            Y=sparse(1:length(GTa),GTa,1);
            Z=sparse(1:length(Z),Z,1);
            result=evaluate(Z, Y,[]);
            accuracy(6,k/2,j)=result.ap;
        else
            result = main (movie_name, coordinate);
            accuracy(6, k/2, j)=result{1,1}.ap;
        end
        multiWaitbar( 'movies', j/5, 'Color', 'b' );
    end
    multiWaitbar( 'classes', 'Value', k/10 );
    multiWaitbar( 'movies', 'Reset' );
end
multiWaitbar( 'classes', 'Reset' );
multiWaitbar( 'methods', 'Value', 6/6 );

multiWaitbar( 'classes', 'Close' );
multiWaitbar( 'movies', 'Close' );
multiWaitbar( 'methods', 'Close' );

accuracy_test=mean(accuracy(:,:,[3,4,5]),3);
accuracy_dev=mean(accuracy(:,:,[1,2]),3);