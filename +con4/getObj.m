function [Q, obj] = getObj(Sim, Var)
Q = nan([Sim.nTime,3]);
Q(:,1) = Var.allpower;
Q(:,2) = Var.allpower;
Q(:,3) = 1;
Q = sparse(Q(:,1),Q(:,2),Q(:,3),Var.nVar,Var.nVar);
obj = zeros([Var.nVar,1]);
obj(Var.allpower) = -2*Sim.optProfile;
end