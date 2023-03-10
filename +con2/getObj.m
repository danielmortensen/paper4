function [A, obj] = getObj(Sim, Var)
% obj = zeros([Var.nVar,1]);
% iB = Var.b(:);
% iB = iB(~isnan(iB));
% iF = Var.f(:);
% iF = iF(~isnan(iF));
% obj(iB) = 1;
% obj(iF) = -1;
A = nan([2*sum(Sim.nRoute,'omitnan'),3]);
nAllRoute = sum(Sim.nRoute);
nAllRouteSqrt = sqrt(nAllRoute);
scaleFactor = 650; 
scaleFactorSqrt = sqrt(scaleFactor);
obj = zeros([Var.nVar,1]);
counter = 1;
for iBus = 1:Sim.nBus
    for iRoute = 1:Sim.nRoute(iBus)
        a = Sim.tStart(iBus,iRoute);
        d = Sim.tFinal(iBus,iRoute);
        ib = Var.b(iBus,iRoute);
        if0 = Var.f(iBus,iRoute);
        A(counter + 0,:) = [ib ib scaleFactorSqrt/nAllRouteSqrt];
        A(counter + 1,:) = [if0 if0 scaleFactorSqrt/nAllRouteSqrt];
        obj(ib) = -2*a*scaleFactor/nAllRoute;
        obj(if0) = -2*d*scaleFactor/nAllRoute;
        counter = counter + 2;
    end
end
A = sparse(A(:,1),A(:,2),A(:,3),Var.nVar,Var.nVar);
end