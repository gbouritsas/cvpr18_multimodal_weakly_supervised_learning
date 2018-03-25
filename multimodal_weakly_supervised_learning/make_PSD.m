function [K, Kothers] = make_PSD(K, Kothers)

Kpp = K;

N = size(Kpp, 1);

if isempty(Kothers)==0
	Kpn = Kothers(:, 1:N);
	Knn = Kothers(:, N + 1: end);
	bigK = [Kpp, Kpn'; Kpn, Knn];
else
	bigK=Kpp;
end
bigK = (bigK+bigK')/2;
[V,D] = eig(bigK);
bigK = V * abs(D) * V';
bigK = (bigK+bigK')/2;

K = bigK(1:N, 1:N);

if isempty(Kothers)==0
	Kothers = bigK(N+1:end, :);
else
	Kothers=[];
end

end