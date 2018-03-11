function features_and_speakers(result_dir, model_dir, convNet, dump_string)

load(fullfile(result_dir, 'facedets.mat'));
load(fullfile(model_dir, 'mean_face.mat'));
if isempty(convNet)
	facedets = face_features(facedets, dump_string,model_dir);
	facedets = face_descriptors(facedets,convNet,mean_face, 101, dump_string, model_dir);
	facedets = mouth_motion(facedets, dump_string);
	facedets = declare_speakers(facedets);
else
	facedets = face_descriptors(facedets,convNet, mean_face, 101, dump_string, model_dir);
end

save(fullfile(result_dir, 'facedets.mat'),'facedets','mean_face');

end