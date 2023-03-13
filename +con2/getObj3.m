function obj = getObj3(Sim,Var)
obj = zeros([Var.nVar,1]);
obj(Var.b(~isnan(Var.b))) = 1;
obj(Var.f(~isnan(Var.f))) = -1;
end