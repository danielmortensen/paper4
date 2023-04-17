function [Sol4, Var4] = computeBusAssignments(Sim4, lossType, solverparam)
import scheduler.con2.*
import scheduler.util2.*

   Var4 = getVarParam(Sim4);

    [A1, b1, nCon1, descr1, eq1] = getCon1(Sim4,Var4);
    [A2, b2, nCon2, descr2, eq2] = getCon2(Sim4,Var4);
    [A3, b3, nCon3, descr3, eq3] = getCon3(Sim4,Var4);
    [A4, b4, nCon4, descr4, eq4] = getCon4(Sim4,Var4);
    [A5, b5, nCon5, descr5, eq5] = getCon5(Sim4,Var4);

    A = [A1; A2; A3; A4; A5];
    b = [b1; b2; b3; b4; b5];
    eq = [eq1; eq2; eq3; eq4; eq5];
    vtype = [Var4.bType; Var4.fType; Var4.lType; Var4.sigmaType; Var4.maxtype];
    model.A = A;
    model.rhs = b;
    model.sense = eq;
    model.vtype = vtype;
    if strcmp(lossType,'quadratic')
        [Q, obj] = getObj(Sim4,Var4);
        model.obj = obj;
        model.Q = Q;
    elseif strcmp(lossType,'max')
        obj = getObj2(Sim4,Var4);
        model.obj = obj;
    elseif strcmp(lossType,'difference')
        obj = getObj3(Sim4, Var4);
        model.obj = obj;
    elseif strcmp(lossType,'None')

    else
        error("computeBusAssignmnet: invalid loss type.");
    end
%     feasSol = zeros(size(vtype));
%     for iBus = 1:Sim4.nBus        
%         for iRoute = 1:Sim4.nRoute(iBus)
%             feasSol(Var4.sigma(iBus,iRoute,iBus)) = 1;
%             feasSol(Var4.b(iBus,iRoute)) = Sim4.tStart(iBus,iRoute);
%             feasSol(Var4.f(iBus,iRoute)) = Sim4.tFinal(iBus,iRoute);      
%         end
%     end
%     feasSol(Var4.max) = 24*3600;
        Sol4 = gurobi(model,struct(solverparam{:}));    
    if Sol4.status == "INFEASIBLE"
        fprintf("MODEL WAS INFEASIBLE, DO NOT PASS GO, DO NOT COLLECT 200 DOLLARS\n");
        return;
    end
end