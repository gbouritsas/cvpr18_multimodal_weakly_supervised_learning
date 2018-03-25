function [ A ] = build_norm( K, lambda )
%BUILD_NORM Summary of this function goes here
%   Detailed explanation goes here

[n,d] = size(K);
In = eye(n);
Pn = In - ones(n)/n;

B = Pn * K * Pn + n * lambda * In;

[V,D] = eig(B);

A = 1000*sqrt(lambda) * sqrtm(inv(D)) * V' * Pn;
%A =1000*sqrt(lambda) * sqrtm(inv(B)) * Pn;
%A=A/(sum(sum(abs(A)))/(size(A,1)*size(A,2)));
%A=lambda*Pn*inv(B)*Pn;
end

