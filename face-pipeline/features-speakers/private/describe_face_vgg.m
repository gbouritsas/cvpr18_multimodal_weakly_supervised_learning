function vggVec = describe_face_vgg(K,convNet)
	%%%alignment:ABSOLUTELY NECESSARY SO THAT THE FACE IS IN THE CENTRE OF THE IMAGE
	global GPU_flag

	N       = size(K,1);
	rect    = [N/3+1  N/3+1 N/3*2 N/3*2];
	crop = faceCrop(K,rect);
	crop= single(crop) ; % note: 255 range
	%crop = imresize(crop, convNet.meta.normalization.imageSize(1:2)) ;
	crop= bsxfun(@minus,crop,convNet.meta.normalization.averageImage) ;
	if GPU_flag=true
		crop = gpuArray(crop);
	end
	res = vl_simplenn(convNet, crop) ;
	feats = squeeze(gather(res(end).x)) ;
	vggVec=feats/norm(feats);


end
