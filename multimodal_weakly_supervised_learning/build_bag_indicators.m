function [ A_ind, B_ind,weights ] = build_bag_indicators(A, S, T, B, S1)

global weight_choice
% remove duplicate constraints with same slack variable weight
A_S=[A S];
[~,ia,ic]=unique(A_S,'stable','rows');
A=A(ia,:);S=S(ia,:);S1=S1(ia,:);

repeat_weights=zeros(length(ia),1);
if strcmp(weight_choice,'weighted')==1
    for i=1:length(ia)
        repeat_weights(i)=sum(ic==i);
    end
elseif strcmp(weight_choice,'equal')==1
    for i=1:length(ia)
        repeat_weights(i)=1;
    end    
end

label_weights=[];
S_new=repmat(S~=0,size(S,2),1);
A=repmat(A,size(S,2),1);
S1=repmat(S1,size(S,2),1);
repeat_weights = repmat(repeat_weights,size(S,2),1);

for i=1:size(S,2)
    S_new(setdiff(1:size(S_new,1),(i-1)*size(S,1)+1:i*size(S,1)),i)=0;
    label_weights=[label_weights; S(:,i)];
end
S=S_new;
nonempty =sum(S,2)>0 & sum(A,2)>0;
A=A(nonempty,:);
S1=S1(nonempty,:);
label_weights=label_weights(nonempty);
repeat_weights=repeat_weights(nonempty);
label_weights = label_weights.*repeat_weights;
S=S(nonempty,:);

% remove duplicate constraints even if they have different slack variable
% weights. The final weight is computed below as the probability of the
% union and then passed through a non-linearity.

A_S=[A S];
[~,ia,ic]=unique(A_S,'stable','rows');
A=A(ia,:);S=S(ia,:);S1=S1(ia,:); 

if strcmp(weight_choice,'weighted')==1
    weights=zeros(length(ia),1);
    for i=1:length(ia)
        weights(i)=sum(label_weights(ic==i));
    end
elseif strcmp(weight_choice,'equal')==1
    weights=zeros(length(ia),1);
    for i=1:length(ia)
        weights(i)=1;
        %weights(i)=max(label_weights(ic==i));
        
        % compute union probability when multiple sentences have non zero
        % probability of belonging to the same action class and are aligned
        % to the same part of the video. The event of each sentence
        % belonging to a specific class is considered independent from the
        % class that the rest of the sentences belong to.
        
        idx=find(ic==i);
        weights(i)=0;
        for j=1:length(idx)
            weights(i) = weights(i) +(-1)^(j-1)* sum(prod(nchoosek(label_weights(ic==i),j),2));
        end
        
        % applying non-linearity to probabilities
        % mem_k=100;thres=0;
        % weights=(mem_k*(weights-thres).^2)./(1+mem_k*(weights-thres).^2);
    end
    %weights=smooth(weights);
    %weights_new(weights<0.2)=0;
    %weights_new(weights>=0.2)=(1000*(weights(weights>=0.2)-0.2).^2)./(1+1000*(weights(weights>=0.2)-0.2).^2);
    %weights=weights_new;
end



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
    y=find(S1(i,:)==1);  % allows incorporation of information from the recognition of different concept (for example face->action) - ignore this
    temp = A(i,:)'.*(B*T(:,y))./sum(B,2);
    A_ind{i} = temp;
    B_ind{i}(:) = S(i,:)';

end



% [temp,a1,a2]=uniquecell(cellfun(@(x,y,z) [x; y;z],A_ind,B_ind,mat2cell(label_weights,ones(1,size(label_weights,1))),'UniformOutput',false));
% freq=tabulate(a2);
% B_ind=cellfun(@(x) x(length(A_ind{1})+1:end-1),temp,'UniformOutput',false);
% A_ind=cellfun(@(x) x(1:length(A_ind{1})),temp,'UniformOutput',false);
% label_weights=cellfun(@(x) x(end),temp,'UniformOutput',false);
% label_weights=cell2mat(label_weights);
%
% weights=label_weights.*freq(:,2);
% weights=label_weights;




end
