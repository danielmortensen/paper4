function obj = getObj2(Sim,Var)
obj = zeros([Var.nVar,1]);
iM = Var.max;
obj(iM) = 1;
end