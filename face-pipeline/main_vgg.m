% Moidfy this according to each movie
movie_name='BMI';
% Paths need to be modified
dump_dir = ['/Data/gbouritsas_thesis/movies/' movie_name '/frames/'];
result_dir  = ['/Data/gbouritsas_thesis/movies/' movie_name '/results'];
matconvnet_path='/Data/gbouritsas_thesis/matconvnet-1.0-beta23/matlab/vl_setupnn';
modelPath = '/Data/gbouritsas_thesis/matconvnet-1.0-beta23/data/models/vgg-face.mat';
global GPU
GPU=true;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('face-detection');
addpath('tracking');
addpath('features-speakers');
addpath('compute-kernels');


dump_string = fullfile(dump_dir, 'image-%06d.png');
model_dir   = 'models';

if ~exist(result_dir, 'dir')
    mkdir(result_dir);
end


run(matconvnet_path);

if ~exist(modelPath)
  mkdir(fileparts(modelPath)) ;
  urlwrite(...
  'http://www.vlfeat.org/matconvnet/models/vgg-face.mat', ...
    modelPath) ;
end
net = load(modelPath) ;
net=vl_simplenn_tidy(net);
newnet=net;
newnet.layers=newnet.layers(1:end-2);
net=newnet;
clear newnet
if GPU==true
  net=vl_simplenn_move(net,'gpu');
end
features_and_speakers(result_dir, model_dir,net, dump_string);
