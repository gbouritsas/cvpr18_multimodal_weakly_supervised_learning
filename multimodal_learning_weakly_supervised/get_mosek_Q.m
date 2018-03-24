function [ qosubi, qosubj, qoval ] = get_mosek_Q(n,P, nXi, kapa,weights )

global v
Znx = sparse(n*P, nXi);
Znn2 = sparse(n*P, n*P);
Znn1 = v*1/(n)* sparse(1:(n*P), 1:(n*P), 1);


%edw to /2 einai lathos alla den ephreazei th lush giati einai stathera pou uparxei pantou. Kanonika tha eprepe
%na einai *2 me vash to objective function tou paper h alliws *1 gia na paroume to objective function pou perigrafw parakatw
IXi = kapa/2  * sparse(1:nXi, 1:nXi, weights);%%creates k/2*ξ'ξ
%IXi = kapa/2  * sparse(1:nXi, 1:nXi, 1);

%creates new variable wij with i,jε[1,n*P].The objective function Z*Z'*A moves to the constraints and gets minimized through tij 
IY = 1/2* sparse(1:(n*P), 1:(n*P), 1);

%Final objective function : 1/2*w'w + k/2*ξ'ξ
Q = [Znn1, Znx, Znn2; 
    Znx', IXi, Znx';
    Znn2, Znx, IY];

nQ = size(Q);

Q = Q + 10^(-7) * sparse(nQ, nQ, 1);

[qosubi, qosubj, qoval] = find(Q);

end

