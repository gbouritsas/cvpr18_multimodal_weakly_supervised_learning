function [resultA] = joint_optimisation(datapath,coordinate)
global optflag
load(datapath);

resultA=[];
if strcmp(coordinate,'face')==1
    params = init_face_params();
elseif strcmp(coordinate,'action')==1
    params = init_action_params();
end
% computing with projected face matrix
params.neg_bag = false;
if strcmp(optflag,'min')
    params.opt_flag = 'MOSEK_NORM';
elseif strcmp(optflag,'feas')
    params.opt_flag = 'feasibility';
end
restemp = weak_square_loss(params,Ka, Koa, GTa, A, S, T, B, S1, probs);
resultA{1} = evaluate(restemp.Z(toeval, :), restemp.Y(toeval, :),restemp.label_card);
%resultA{1}.obj=restemp.obj;
resultA{2} = evaluate(restemp.Z, restemp.Y,restemp.label_card);
resultA{3} = evaluate(restemp.Z(~toeval, :), restemp.Y(~toeval, :),restemp.label_card);
%resultA{3}.obj=restemp.obj;


end