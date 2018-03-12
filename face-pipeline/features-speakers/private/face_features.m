function [ fd ] = face_features( fd , dumpfile,model_dir )
%FACE_FEATURES Extracts all facial features
% Given the global variable avifile, this function extracts all facial
% features for all detections stored in structure fd. It calls the
% function GET_LANDMARKS for every face detection. Frames are loaded by
% groups of 500.
%
%       The input arguments are :
%               - fd  : the face-detection structure used everywhere
%
%       The resulting feature locations are added to the fd
%       structure. The following fields are created :
%               - P         : the landmark locations
%               - pconf     : global features confidence
%               - PCONF     : landmark-wise confidence
%               - mirror    : a deprecated flag


[fd.P] = deal([]);
[fd.pconf] = deal([]);
[fd.PCONF] = deal([]);
[fd.mirror] = deal([]);


%from now on we changed the function so that no violations are done for parfor


frame   = cat(1, fd.frame);


figure(1), clf;
set(1, 'Name', 'Facial Landmarks');

fprintf('Extracting Facial Features...\n' );
parfor i = 1:length(frame)
    fprintf('working on frame %06d... \n', frame(i));

    impath = sprintf(dumpfile, frame(i));
    I = imread(impath);
    [P, pconf, PCONF, mirror] = get_landmarks(I, fd(i),model_dir);
    fd(i).P = P;
    fd(i).pconf = pconf;
    fd(i).PCONF = PCONF;
    fd(i).mirror = mirror;
end
fprintf('Done.\n');


end
