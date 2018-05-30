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
% A few results in the paper might differ. The reasons are the following:

% 1) The Text + MIL method might have various optimal points.
% 2) If there are no constraints (no similarity exceeds the similarity
% threshold), then the optimization returns a trivial solution, assigning
% all tracks to the same class. We chose this class at random and report
% this result at the paper (LOR/2 classes, GLA/2,4 classes, MIL(modified)).
% 3) In the case of the feasibility problem, the absence of constraints
% leads to complete absence of information. Hence we choose each track class at random (LOR/2 classes, GLA/2,4 classes, TEXT + MIL).

accuracy=zeros(6,5,7);
optflag='feas';

multiWaitbar( 'CloseAll' );
multiWaitbar( 'methods', 0 );
multiWaitbar( 'classes', 0, 'Color', 'g' );
multiWaitbar( 'movies', 0, 'Color', 'b' );

%1
for k=2:2:10
    ygt=[];
    s=[];
    z=[];
    for j=1:length(movies)
        movie_name=movies{j};
        return_code=prepare_for_opt_action({movie_name}, similarity_threshold(end), label_method(1),...
                    membership_function(2), membership_threshold{2}(1), 0,...
                    k, extend(1), kernel(1), localization(1), fps, fps_weird);
        if return_code(1)==0
            datapath = [movies_folder movie_name '/results_optimization/data_new_experiment.mat'];
            load(datapath);
            Z=randi(max(GTa),[length(GTa),1]);
            Y=sparse(1:length(GTa),GTa,1);
            Z=sparse(1:length(Z),Z,1);
            result=evaluate(Z, Y,[]);
            accuracy(1,k/2,j)=result.ap;
            result_temp = result;
        else
            result = main (movie_name, coordinate);
            accuracy(1,k/2,j)=result{1,1}.ap;
            result_temp = result{1,1};
        end
        Z=result_temp.Z;
        ygt=[ygt; result_temp.ygt];
        [s1, z1]      = max(Z, [], 2);
        z=[z;z1];
        s=[s;s1];
        r(1,k/2,j)={result_temp.r};
        p(1,k/2,j)={result_temp.p};
        multiWaitbar( 'movies', j/5, 'Color', 'b' );
    end
    multiWaitbar( 'classes', 'Value', k/10 );
    multiWaitbar( 'movies', 'Reset' );
    [maccuracy(1,k/2),map(1,k/2),mp{1,k/2},mr{1,k/2}]=evaluate_all(ygt,s,z);
end
multiWaitbar( 'classes', 'Reset' );
multiWaitbar( 'methods', 'Value', 1/6 );

optflag='min';
%2
for k=2:2:10
    ygt=[];
    s=[];
    z=[];
    for j=1:length(movies)
        movie_name=movies{j};
        return_code=prepare_for_opt_action({movie_name}, similarity_threshold(end), label_method(1),...
                    membership_function(2),membership_threshold{2}(1), 0,...
                    k, extend(1), kernel(1), localization(1), fps, fps_weird);
        if return_code(1)==0
            datapath = [movies_folder movie_name '/results_optimization/data_new_experiment.mat'];
            load(datapath);
            randint = randi(max(GTa));
            Z=randint*ones(length(GTa),1);
            Y=sparse(1:length(GTa),GTa,1);
            Z=sparse(1:length(Z),Z,1);
            result=evaluate(Z, Y,[]);
            accuracy(2,k/2,j)=result.ap;
            result_temp = result;
        else
            result = main (movie_name, coordinate);
            accuracy(2,k/2,j)=result{1,1}.ap;
            result_temp = result{1,1};
        end
        Z=result_temp.Z;
        ygt=[ygt; result_temp.ygt];
        [s1, z1]      = max(Z, [], 2);
        z=[z;z1];
        s=[s;s1];
        r(2,k/2,j)={result_temp.r};
        p(2,k/2,j)={result_temp.p};
        multiWaitbar( 'movies', j/5, 'Color', 'b' );
    end
    multiWaitbar( 'classes', 'Value', k/10 );
    multiWaitbar( 'movies', 'Reset' );
    [maccuracy(2,k/2),map(2,k/2),mp{2,k/2},mr{2,k/2}]=evaluate_all(ygt,s,z);
end
multiWaitbar( 'classes', 'Reset' );
multiWaitbar( 'methods', 'Value', 2/6 );

%3
for k=2:2:10
    ygt=[];
    s=[];
    z=[];
    for j=1:length(movies)
        movie_name=movies{j};
        return_code=prepare_for_opt_action({movie_name}, 0.4, label_method(1),...
                    membership_function(2), membership_threshold{2}(1), 0,...
                    k, extend(1), kernel(1), localization(1), fps, fps_weird);
        if return_code(1)==0
            datapath = [movies_folder movie_name '/results_optimization/data_new_experiment.mat'];
            load(datapath);
            randint = randi(max(GTa));
            Z=randint*ones(length(GTa),1);
            Y=sparse(1:length(GTa),GTa,1);
            Z=sparse(1:length(Z),Z,1);
            result=evaluate(Z, Y,[]);
            accuracy(3,k/2,j)=result.ap;
            result_temp = result;
        else
            result = main (movie_name, coordinate);
            accuracy(3, k/2, j)=result{1,1}.ap;
            result_temp = result{1,1};
        end
        Z=result_temp.Z;
        ygt=[ygt; result_temp.ygt];
        [s1, z1]      = max(Z, [], 2);
        z=[z;z1];
        s=[s;s1];
        r(3,k/2,j)={result_temp.r};
        p(3,k/2,j)={result_temp.p};
        multiWaitbar( 'movies', j/5, 'Color', 'b' );
    end
    multiWaitbar( 'classes', 'Value', k/10 );
    multiWaitbar( 'movies', 'Reset' );
    [maccuracy(3,k/2),map(3,k/2),mp{3,k/2},mr{3,k/2}]=evaluate_all(ygt,s,z);
end
multiWaitbar( 'classes', 'Reset' );
multiWaitbar( 'methods', 'Value', 3/6 );

%4
for k=2:2:10
    ygt=[];
    s=[];
    z=[];
    for j=1:length(movies)
        movie_name=movies{j};
        return_code=prepare_for_opt_action({movie_name}, 0.4, label_method(2),...
                    membership_function(2), membership_threshold{2}(1), 0,...
                    k, extend(1), kernel(1),localization(1),fps,fps_weird);
        if return_code(1)==0
            datapath = [movies_folder movie_name '/results_optimization/data_new_experiment.mat'];
            load(datapath);
            randint = randi(max(GTa));
            Z=randint*ones(length(GTa),1);
            Y=sparse(1:length(GTa),GTa,1);
            Z=sparse(1:length(Z),Z,1);
            result=evaluate(Z, Y,[]);
            accuracy(4,k/2,j)=result.ap;
            result_temp = result;
        else
            result = main (movie_name, coordinate);
            accuracy(4,k/2,j)=result{1,1}.ap;
            result_temp = result{1,1};
        end
        Z=result_temp.Z;
        ygt=[ygt; result_temp.ygt];
        [s1, z1]      = max(Z, [], 2);
        z=[z;z1];
        s=[s;s1];
        r(4,k/2,j)={result_temp.r};
        p(4,k/2,j)={result_temp.p};
        multiWaitbar( 'movies', j/5, 'Color', 'b' );
    end
    multiWaitbar( 'classes', 'Value', k/10 );
    multiWaitbar( 'movies', 'Reset' );
    [maccuracy(4,k/2),map(4,k/2),mp{4,k/2},mr{4,k/2}]=evaluate_all(ygt,s,z);
end
multiWaitbar( 'classes', 'Reset' );
multiWaitbar( 'methods', 'Value', 4/6 );

%5
for k=2:2:10
    ygt=[];
    s=[];
    z=[];
    for j=1:length(movies)
        movie_name=movies{j};
        return_code=prepare_for_opt_action({movie_name}, 0.4, label_method(1),...
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
            accuracy(5,k/2,j)=result.ap;
            result_temp = result;
        else
            result = main (movie_name, coordinate);
            accuracy(5, k/2, j)=result{1,1}.ap;
            result_temp = result{1,1};
        end
        Z=result_temp.Z;
        ygt=[ygt; result_temp.ygt];
        [s1, z1]      = max(Z, [], 2);
        z=[z;z1];
        s=[s;s1];
        r(5,k/2,j)={result_temp.r};
        p(5,k/2,j)={result_temp.p};
        multiWaitbar( 'movies', j/5, 'Color', 'b') ;
    end
    multiWaitbar( 'classes', 'Value', k/10 );
    multiWaitbar( 'movies', 'Reset' );
    [maccuracy(5,k/2),map(5,k/2),mp{5,k/2},mr{5,k/2}]=evaluate_all(ygt,s,z);
end
multiWaitbar( 'classes', 'Reset' );
multiWaitbar( 'methods', 'Value', 5/6 );

%6
for k=2:2:10
    ygt=[];
    s=[];
    z=[];
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
            result_temp = result;
        else
            result = main (movie_name, coordinate);
            accuracy(6, k/2, j)=result{1,1}.ap;
            result_temp = result{1,1};
        end
        Z=result_temp.Z;
        ygt=[ygt; result_temp.ygt];
        [s1, z1]      = max(Z, [], 2);
        z=[z;z1];
        s=[s;s1];
        r(6,k/2,j)={result_temp.r};
        p(6,k/2,j)={result_temp.p};
        multiWaitbar( 'movies', j/5, 'Color', 'b' );
    end
    multiWaitbar( 'classes', 'Value', k/10 );
    multiWaitbar( 'movies', 'Reset' );
    [maccuracy(6,k/2),map(6,k/2),mp{6,k/2},mr{6,k/2}]=evaluate_all(ygt,s,z);
end
multiWaitbar( 'classes', 'Reset' );
multiWaitbar( 'methods', 'Value', 6/6 );

multiWaitbar( 'classes', 'Close' );
multiWaitbar( 'movies', 'Close' );
multiWaitbar( 'methods', 'Close' );

accuracy_test=mean(accuracy(:,:,[3,4,5]),3);
accuracy_dev=mean(accuracy(:,:,[1,2]),3);

accuracy(:,:,6)=map;
accuracy(:,:,7)=mean(accuracy(:,:,1:5),3);
r(:,:,6)=mr;
p(:,:,6)=mp;

%%
j=6;
for i=1:5
    figure, clf;
    plot(r{1,i,j}, p{1,i,j}, 'LineWidth', 2);
    hold on
    plot(r{2,i,j}, p{2,i,j}, 'LineWidth', 2, 'Color', 'red');
    plot(r{3,i,j}, p{3,i,j}, 'LineWidth', 2, 'Color', 'green');
    plot(r{4,i,j}, p{4,i,j}, 'LineWidth', 2, 'Color', 'blue');
    plot(r{5,i,j}, p{5,i,j}, 'LineWidth', 2);
    plot(r{6,i,j}, p{6,i,j}, 'LineWidth', 2, 'Color', 'magenta');

    axis equal;
    axis([0 1 0 1]);
    grid;
    xlabel('proportion of total instances');
    ylabel('accuracy');

    L{1} = ['Text+MIL ' sprintf('(AP=%3.3f)', accuracy(1,i,j))];
    L{2} = ['Bojanowski et al. 2013 (modified) ' sprintf('(AP=%3.3f)', accuracy(2,i,j))];
    L{3} = ['Sim + MIL' sprintf('(AP=%3.3f)', accuracy(3,i,j))];
    L{4} = sprintf('Sim + PLMIL (AP=%3.3f)', accuracy(4,i,j));
    L{5} = sprintf('Sim + FSMIL (AP=%3.3f)', accuracy(5,i,j));
    L{6} = sprintf('Sim + PLMIL+FSMIL (Ours) (AP=%3.3f)', accuracy(6,i,j));

    h=legend(L, 'Location', 'northEast','FontSize',22);
    set(h,'interpreter','tex')
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
end
