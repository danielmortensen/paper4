function obj = getObj2(Sim,Var)
    obj = zeros([Var.nVar,1]);
    obj(Var.maxOverall) = 1;
end