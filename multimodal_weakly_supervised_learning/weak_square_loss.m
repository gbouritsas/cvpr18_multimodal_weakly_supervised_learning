function results = weak_square_loss(params,K, Ko, GT, A, S, T, B, S1, probs)

global external_background
% making kernels PSD
[K, Ko] = make_PSD(K, Ko);

% building the bags - kernel, constraints
[ Ka, Y, A_ind, B_ind, others_idx,label_cardinality,weights] = build_bags(params, K, Ko, GT, A, S, T, B, S1, params.label_set);

alpha       = params.alpha;
alpha_2     = params.alpha_2;
kapa        = params.kapa;
lambda      = params.lambda;
label_set   = params.label_set;
bg_concept  = params.bg_concept;

% fixing parameters of the minimization program
n = size(K, 1)+length(others_idx); % number of tracks / number of classes
P = size(S,2);
if strcmp(label_set,'open') & ~external_background
    bg_idx=find(cellfun(@(x) x(1)==1,B_ind));
    B_ind_bg=B_ind{bg_idx};
    A_ind_bg=A_ind{bg_idx};
    weights_bg=weights(bg_idx);
    A_ind=A_ind(setdiff(1:length(A_ind),bg_idx));
    B_ind=B_ind(setdiff(1:length(B_ind),bg_idx));
    weights=weights(setdiff(1:length(weights),bg_idx));
end
nConst  = length(A_ind);  % number of script annotations
ep      = ones(P, 1);     % constant vector of ones

if strcmp(params.opt_flag, 'feasibility') % feasibility USING CVX
    
    A       = build_A(Ka, lambda);
    Ip      = eye(P);
    AI      = kron(Ip, A);
    if nConst==0
        Z= ones(n,1);
    else
        cvx_begin
        variable Z(n, P);
        variable xi1(nConst);

        %    minimize (kapa * norm(xi1))

            minimize (kapa * sum(weights.*xi1.^2))

        for j = 1:nConst
            A_ind{j}' * Z * B_ind{j} >= alpha - xi1(j);
        end

        Z * ep == 1;
        Z >= 0;
        cvx_end
    end

elseif strcmp(params.opt_flag, 'MOSEK_NORM') % EQUIVALENT NORM WITH MOSEK (FASTEST)
    
	%A       = build_A(Ka, lambda);
    A = build_norm(Ka, lambda);
    [prob.a, prob.blc, prob.buc]            = get_mosek_A(n, P, A_ind, B_ind, A, alpha); 
    [prob.qosubi, prob.qosubj, prob.qoval]  = get_mosek_Q(n,P, nConst, kapa, weights);
    [prob.blx]                              = get_mosek_lx(n, P, nConst,probs);
    %[prob.c]                                = get_mosek_c(n, P, nConst,probs);
    
    if strcmp(label_set,'open') & bg_concept==true & ~external_background
        aid = find(A_ind_bg);
        idx = aid;
        prob.a(end+1,idx)=1;
        prob.blc(end+1)=alpha_2*sum(A_ind_bg);
        prob.buc(end+1)=inf;
    end
    % solving the quadratic problem
    [~, res] = mosekopt('minimize', prob);
    
    % getting the result in the correct format
    vecz    = res.sol.itr.xx;
    Z       = reshape(vecz(1 : (n*P)), n, P);
    %results.obj=vecz(n*P+nConst+1:end)'*1/4* sparse(1:(n*P), 1:(n*P), 1)*vecz(n*P+nConst+1:end);

    
else
    
    error('Invalid OPT_FLAG!');
    
end

% removing others and evaluating
idx = setdiff(1:size(Y,1), others_idx);
results = evaluate(Z(idx, :), Y(idx, :),label_cardinality);
%results.obj=res.sol.itr.dobjval;
end