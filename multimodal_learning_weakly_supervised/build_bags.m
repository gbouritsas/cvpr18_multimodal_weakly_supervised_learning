function [ Ka, Y, A_ind, B_ind, others_idx,label_cardinality,weights] = build_bags(params, K, Ko, GT, A, S, T, B, S1, label_set)
% the variable with the opposite latent variable is called here T but its
% true value depend on the direction of optimization

global external_background

% removing bags where there are too many tracks
if params.cut_crowds
    idx     = sum(A, 2) >= params.cut_threshold;
    if strcmp(label_set,'open') & ~external_background
        idx=setdiff(idx,size(A,1));%bg characters
    end
    A(idx, :)=0;
end

N = size(K, 1);
nothers=size(Ko,1);
%%%
%%%OTHER CLASS
%%%

if isempty(Ko)==0
	Kpn = Ko(:, 1:N);
	Knn = Ko(:, N+1:end);
else
	Kpn=[];
	Knn=[];
end
if isempty(Ko)==0
	% keep index of "others" samples
	others_idx = (1:nothers) + size(K, 1);
	% adding the label one to all the "OTHERS" tracks
	GT = cat(1, GT, ones(nothers, 1));
	Kpn = Ko(:, 1:N);
	Knn = Ko(:, N+1:end);
	% adding others to the kernel
	Ka = [K, Kpn'; Kpn, Knn];
	% adding others to the other latent variable
	%T = cat(1, T, 1/size(T, 2)*ones(nothers, size(T, 2)));
	% getting the number of others tracks
	% building the constraints for others
    I=size(A,1);
    for i = 1:nothers
        A(I+i,N+i) = 1;
        S(I+i,1)=1;
        S1(I+i)=1;
    end
    B(N+(1:nothers))=1;
else
	others_idx=[];
	Ka=K;
end

%%Ground truth matrix
Y = full(sparse(1:length(GT), GT, 1));

% building the constraint indicator vectors
[ A_ind, B_ind,weights ] = build_bag_indicators(A, S, T, B, S1);
if length(B_ind)>0
    label_cardinality=zeros(1,size(B_ind{1},1));
else
    label_cardinality=0;
end
for i=1:length(B_ind)
    [~,j]=max(B_ind{i});
    label_cardinality(j)=label_cardinality(j)+1;
end
