% movie_name='CRA';s1  =1;s2  =39929;
% movie_name='DEP';s1  =1;s2  =45709;
% movie_name='GLA';s1  =1;s2=45072;
% movie_name='LOR';s1  =1;s2  =56342;

% Moidfy these according to each movie - s1,s2= start,end frame
movie_name='BMI';s1  =1;s2  =46940;
% Paths need to be modified
vl_feat_path = '/rmt8/mobot/external_packages/vlfeat-0.9.19/toolbox/vl_setup';
dump_dir = ['/rmt9/pkoutras/gbouritsas_thesis/movies/' movie_name '/frames/'];
result_dir  = ['/rmt9/pkoutras/gbouritsas_thesis/movies/' movie_name '/results_face'];
model_dir   = 'models';
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('face-detection');
addpath('tracking');
addpath('features-speakers');
addpath('compute-kernels');

run(vl_feat_path);


dump_string = fullfile(dump_dir, 'image-%06d.png');
if ~exist(result_dir, 'dir')
    mkdir(result_dir);
end



face_detection(result_dir, model_dir, dump_string, s1, s2);

detect_shots(result_dir, dump_string, s1, s2);

track_in_shots(result_dir, -0.7, dump_string);

%changed the arguments from tracks_to_facedets:erased s1,s2
tracks_to_facedets(result_dir, model_dir, dump_string);

features_and_speakers(result_dir, model_dir,[], dump_string);
