function [ c ] = get_mosek_c(n,P, nXi ,probs)

global v
c=[-2*v*reshape(probs,[1 size(probs,1)*size(probs,2)])';zeros(nXi+n*P,1)];

end

