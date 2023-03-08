function obj = getObj(Sim, Var)
    obj = zeros([Var.nVar,1]);
    idx = Var.v(~isnan(Var.v));    
    obj(idx(:)) = 1;
end