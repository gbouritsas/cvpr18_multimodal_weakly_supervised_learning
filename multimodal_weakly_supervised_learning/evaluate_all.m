function [acc,ap,p,r]=evaluate_all(ygt,s,z)

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

end