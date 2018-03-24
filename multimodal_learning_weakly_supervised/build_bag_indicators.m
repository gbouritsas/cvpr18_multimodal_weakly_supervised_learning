function [ A_ind, B_ind,weights ] = build_bag_indicators(A, S, T, B, S1)

global weight_choice
label_weights=[];
S_new=repmat(S~=0,size(S,2),1);
A=repmat(A,size(S,2),1);
S1=repmat(S1,size(S,2),1);

for i=1:size(S,2)
    S_new(setdiff(1:size(S_new,1),(i-1)*size(S,1)+1:i*size(S,1)),i)=0;
    label_weights=[label_weights; S(:,i)];
end
S=S_new;
nonempty =sum(S,2)>0;
A=A(nonempty,:);
S1=S1(nonempty,:);
label_weights=label_weights(nonempty);
S=S(nonempty,:);

N = size(A, 1);
P = size(S,2);
eA      = zeros(N, 1);
eB      = zeros(P, 1);
I       = size(A,1);

A_ind = cell(I, 1);
B_ind = cell(I, 1);

for i = 1:I
    A_ind{i} = eA;
    B_ind{i} = eB;
    y=find(S1(i,:)==1);
    temp = A(i,:)'.*(B*T(:,y))./sum(B,2);
    A_ind{i} = temp;
    B_ind{i}(:) = S(i,:)';

end

% A_ind = cell(I*P, 1);
% B_ind = cell(I*P, 1);
%
% for i = 1:I*P
%     A_ind{i} = eA;
%     B_ind{i} = eB;
%     temp = A(ceil(i/P),:)';
%     A_ind{i} = temp;
%     B_ind{i}(1+mod(i-1,P)) = S(ceil(i/P),1+mod(i-1,P));
%
% end


sA = cellfun(@sum, A_ind);
sB = cellfun(@sum, B_ind);
nonempty = sA>0 & sB>0;
A_ind = A_ind(nonempty);
B_ind = B_ind(nonempty);
%bag_time=bag_time(nonempty);
label_weights=label_weights(nonempty);


[temp,a1,a2]=uniquecell(cellfun(@(x,y) [x; y],A_ind,B_ind,'UniformOutput',false));
freq=tabulate(a2);
B_ind=cellfun(@(x) x(length(A_ind{1})+1:end),temp,'UniformOutput',false);
A_ind=cellfun(@(x) x(1:length(A_ind{1})),temp,'UniformOutput',false);

if strcmp(weight_choice,'weighted')==1
    weights=zeros(1,length(a1));
    for i=1:length(a1)
        weights(i)=sum(label_weights(a2==i));
    end
    weights=weights';
elseif strcmp(weight_choice,'equal')==1
    weights=ones(length(a1),1);
%   weights=zeros(1,length(a1));
%     for i=1:length(a1)
%         weights(i)=max(label_weights(a2==i));
%     end
    %weights=smooth(weights);
    %weights_new(weights<0.2)=0;
    %weights_new(weights>=0.2)=(1000*(weights(weights>=0.2)-0.2).^2)./(1+1000*(weights(weights>=0.2)-0.2).^2);
    %weights=weights_new;
end

% [temp,a1,a2]=uniquecell(cellfun(@(x,y,z) [x; y;z],A_ind,B_ind,mat2cell(label_weights,ones(1,size(label_weights,1))),'UniformOutput',false));
% freq=tabulate(a2);
% B_ind=cellfun(@(x) x(length(A_ind{1})+1:end-1),temp,'UniformOutput',false);
% A_ind=cellfun(@(x) x(1:length(A_ind{1})),temp,'UniformOutput',false);
% label_weights=cellfun(@(x) x(end),temp,'UniformOutput',false);
% label_weights=cell2mat(label_weights);
%
% weights=label_weights.*freq(:,2);
%weights=label_weights;


%weights=freq(:,2);
%weights=freq(:,2).*cat(1,[],bag_time(a1).ascore);
%weights=cat(1,[],bag_time(a1).ascore);

end
