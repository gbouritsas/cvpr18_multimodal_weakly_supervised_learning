function results = evaluate(Z, Y,label_cardinality)

P = size(Y,2);

% getting the predicted classes and the associated confidence
[~, ygt]    = max(Y, [], 2);
[s, z]      = max(Z, [], 2);
[s, idx]    = sort(s, 'descend');
z           = z(idx, :);
ygt         = ygt(idx, :);

% computing the accuracy
acc = sum(z==ygt)/length(z);

% computing precision and recall
p       = zeros(length(s), 1);
r       = zeros(length(s), 1);
eval    = ones(length(ygt), 1);

for j = 1:length(s)
    p(j) = sum(z(1:j) == ygt(1:j) & eval(1:j)) / j;
    r(j) = sum(eval(1:j)) / sum(eval);
end

% computing the average precision
ap = 0;
for i = 2:length(r)
    ap = ap + (p(i)+p(i-1)) * (r(i)-r(i-1)) / 2;
end

% computing the per-class performance
class_p     = cell(P, 1);
class_r     = cell(P, 1);
class_ap    = zeros(P, 1);
class_recall   = zeros(P, 1);
class_precision   = zeros(P, 1);


%%%CHANGE THIS TO ALLOW Pgt>Ptext_labels
for i = 1:P
    if i<=size(Z,2)
        [class_r{i}, class_p{i}, class_ap(i)] = binary_pr(Z(:,i), Y(:,i));
    else
        [class_r{i}, class_p{i}, class_ap(i)] = binary_pr(zeros(size(Y,1),1), Y(:,i));
    end
    idx = ygt==i;
    class_recall(i) = sum(z(idx) == ygt(idx)) / sum(idx);
    idx = z==i;
    class_precision(i) = sum(z(idx) == ygt(idx)) / sum(idx);  

end

% storing everything in a structure
results = struct();
results.ap = ap;
results.p = p;
results.r = r;
results.class_r = class_r;
results.class_p = class_p;
results.class_ap = class_ap;
results.Z = Z;
results.Y = Y;
results.acc = acc;
results.class_acc = struct('class_recall',num2cell(class_recall),'class_precision',num2cell(class_precision));
[~, ygt]    = max(Y, [], 2);
[s, z]      = max(Z, [], 2);
results.z=z;
results.ygt=ygt;
results.label_card=label_cardinality;
confusionMat=confusionmat(ygt,z);
if isempty(confusionMat)~=1
precision = diag(confusionMat)./sum(confusionMat,2);
recall =diag(confusionMat)./sum(confusionMat,1)';
f1Scores = 2*(precision.*recall)./(precision+recall);
results.F1=mean(f1Scores);
results.confmat=confusionMat;
end

end