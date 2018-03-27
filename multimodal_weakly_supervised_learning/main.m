function result = main(movie_name, coordinate)

    % path to the mosek licence folder
    %mosek_license = 'C:\Users\giorgos\mosek\';
    global mosek_path; addpath(mosek_path);
    global cvx_path; run(cvx_path);

   
    global movies_folder
    datapath = [movies_folder movie_name '/results_optimization/data_new_experiment.mat'];
    load(datapath);
    result = joint_optimisation(datapath,coordinate);
    % Z=result{1, 1}.Z;
    % Y=result{1, 1}.Y;
    % [~, z]= max(Z, [], 2);
    % Z_hat=sparse(1:length(z),z,1);
    % Z_hat=[Z_hat zeros(size(Z_hat,1),size(Y,2)-size(Z_hat,2))];
    % 
    % n=size(X,1);
    % d=size(X,2);
    % In = eye(n);
    % Id=eye(d);
    % Pn = In - ones(n)/n;
    % inv_centering=(X'*Pn*X+n*lambda*Id)\X';
    % 
    % w_weak=inv_centering*Pn*Z;
    % b_weak=1/n*ones(1,n)*(Z-X*w_weak);

end