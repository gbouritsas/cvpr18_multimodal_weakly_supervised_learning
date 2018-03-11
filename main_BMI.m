vl_feat_path = '/rmt8/mobot/external_packages/vlfeat-0.9.19/toolbox/vl_setup';

dump_dir = '/rmt9/pkoutras/gbouritsas_thesis/movies/BMI/frames/';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('face-detection');
addpath('tracking');
addpath('features-speakers');
addpath('compute-kernels');

run(vl_feat_path);


dump_string = fullfile(dump_dir, 'image-%06d.png');
model_dir   = 'models';
result_dir  = '/rmt9/pkoutras/gbouritsas_thesis/movies/BMI/results';

if ~exist(result_dir, 'dir')
    mkdir(result_dir);
end

s1  =1;
s2  =46940;

face_detection(result_dir, model_dir, dump_string, s1, s2);

detect_shots(result_dir, dump_string, s1, s2);

track_in_shots(result_dir, -0.7, dump_string);

%changed the arguments from tracks_to_facedets:erased s1,s2
tracks_to_facedets(result_dir, model_dir, dump_string);

vgg_flag=false;
useGPU=false;
useCudnn=false;


if vgg_flag==false
	features_and_speakers(result_dir, model_dir,[], dump_string);
else
	%extra: deep representation with vgg-face
	matconvnet_path='~/Downloads/matconvnet/matlab/vl_setupnn';
	run(matconvnet_path);
	config.paths.net_path = '~/Downloads/vgg_face_matconvnet/data/vgg_face.mat';
	convNet = lib.face_feats.convNet(config.paths.net_path);
	if useGPU==true;
		convNet.useGPU = true;
	end
	if useCudnn==true
		convNet.cudnn = {'CuDNN'} ; % If using CuDNN {'CuDNN'}
	end
	newnet=convNet.net;
	newnet.layers=newnet.layers(1:end-2);
	convNet.net=newnet;
	clear newnet
	
	features_and_speakers(result_dir, model_dir,convNet, dump_string);

end
	
%facedets_kernel(result_dir);


