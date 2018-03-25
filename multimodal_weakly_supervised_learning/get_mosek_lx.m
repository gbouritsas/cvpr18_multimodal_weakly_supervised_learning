function [ lx ] = get_mosek_lx( n, P, nXi,probs )

lx1 = -inf(n*P, 1);
lx2 = zeros(n*P, 1);
%lx2=reshape(probs,[1 size(probs,1)*size(probs,2)])';
lx3 = zeros(nXi, 1);
%lower bound z-->0, î-->0, w-->-inf
lx = cat(1, lx2, lx3, lx1);

end