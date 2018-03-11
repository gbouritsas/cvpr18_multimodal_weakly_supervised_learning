function vggVec = describe_face_vgg(K,convNet)
	%%%alignment:ABSOLUTELY NECESSARY SO THAT THE FACE IS IN THE CENTRE OF THE IMAGE
	N       = size(K,1);
	rect    = [N/3+1  N/3+1 N/3*2 N/3*2];
	crop = lib.face_proc.faceCrop.crop(K,rect);
	crop= single(crop) ; % note: 255 range
	%crop = imresize(crop, convNet.meta.normalization.imageSize(1:2)) ;
	crop= bsxfun(@minus,crop,convNet.meta.normalization.averageImage) ;
	crop = gpuArray(crop);
	res = vl_simplenn(convNet, crop) ;
	feats = squeeze(gather(res(end).x)) ;
	vggVec=feats/norm(feats);
	
	
end
