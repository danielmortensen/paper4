function obj = getObj1(Sim, Var)
obj = zeros([Var.nVar,1]);
obj(Var.g) = 1;
end