function obj = getObj(Sim, Var)
obj = zeros([Var.nVar,1]);
iB = Var.b(:);
iB = iB(~isnan(iB));
iF = Var.f(:);
iF = iF(~isnan(iF));
obj(iB) = 1;
obj(iF) = -1;
end