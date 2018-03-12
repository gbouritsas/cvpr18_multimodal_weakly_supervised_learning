% Moidfy this according to each movie
movie_name='BMI';
% Paths need to be modified
result_dir  = ['/Data/gbouritsas_thesis/movies/' movie_name '/results/'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('compute-kernels');
if ~exist(result_dir, 'dir')
    mkdir(result_dir);
end
facedets_kernel_no_pconf_check(result_dir);
