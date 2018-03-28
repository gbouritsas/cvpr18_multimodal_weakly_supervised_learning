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
% union passed through an increasing mapping function.

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
        
    end
    % applying mapping function f to probabilities. 
    map_f= 'gamma_rational';
    
    if strcmp(map_f,'gamma_rational')
        f_k=1000;thres=0;
        weights_new=(f_k*(weights-thres).^2)./(1+f_k*(weights-thres).^2);
        weights_new(weights<thres) = 0;
        weights = weights_new;
    elseif strcmp(map_f,'linear')
        weights = weights;
    elseif strcmp(map_f,'gamma_rational_shifted')
        f_k=1000;thres=0; map_1 = 1; shift = map_1 - (f_k*(1-thres)^2)/(1+f_k*(1-thres)^2);
        weights_new=(f_k*(weights-thres).^2)./(1+f_k*(weights-thres).^2)+ shift;
        weights_new(weights<thres) = 0;
        weights = weights_new;
    % 4) candidate labels: In the COGNIMUSE dataset candidate labels provides near optimal
    % results - similar to those of the gamma rational mapping function. This can be interpreted by the fact many labeled action
    % tracks do not appear in the text and by the fact that the semantic
    % similarity algorithm provides noisy probabilistc labels, hence noisy
    % "oracles" for the optimization algorithm
    elseif strcmp(map_f, 'candidate_labels')
        weights = ones(length(weights),1);
    elseif strcmp(map_f,'gamma_sigmoid')
        f_k=10;thres=0.1;
        weights=sigmf(weights,[f_k/thres,thres]);
    elseif strcmp(map_f,'step')
        thres = 0.1;
        if thres==1
            weights=weights>=membership_thres;
        else
            weights=weights>membership_thres;
        end
    end
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


end
