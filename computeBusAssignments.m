function [Sol4, Var4] = computeBusAssignments(Sim4, lossType, MIPGap)
   Var4 = util2.getVarParam(Sim4);

    [A1, b1, nCon1, descr1, eq1] = con2.getCon1(Sim4,Var4);
    [A2, b2, nCon2, descr2, eq2] = con2.getCon2(Sim4,Var4);
    [A3, b3, nCon3, descr3, eq3] = con2.getCon3(Sim4,Var4);
    [A4, b4, nCon4, descr4, eq4] = con2.getCon4(Sim4,Var4);
    [A5, b5, nCon5, descr5, eq5] = con2.getCon5(Sim4,Var4);

    A = [A1; A2; A3; A4; A5];
    b = [b1; b2; b3; b4; b5];
    eq = [eq1; eq2; eq3; eq4; eq5];
    vtype = [Var4.bType; Var4.fType; Var4.lType; Var4.sigmaType; Var4.maxtype];
    model.A = A;
    model.rhs = b;
    model.sense = eq;
    model.vtype = vtype;
    if nargin > 1
        if strcmp(lossType,'quadratic')
            [Q, obj] = con2.getObj(Sim4,Var4);
            model.obj = obj;
            model.Q = Q;
        elseif strcmp(lossType,'max')
            obj = con2.getObj2(Sim4,Var4);
            model.obj = obj;
        elseif strcmp(lossType,'difference')
            obj = con2.getObj3(Sim4, Var4);
            model.obj = obj;
        end
    end
    if nargin == 1
        Sol4 = gurobi(model,struct('OutputFlag',0));
    else
        Sol4 = gurobi(model,struct('OutputFlag',0,'MIPGap',MIPGap)); ...,'DualReductions',0));
    end
    if Sol4.status == "INFEASIBLE"
        fprintf("MODEL WAS INFEASIBLE, DO NOT PASS GO, DO NOT COLLECT 200 DOLLARS\n");
        return;
    end
end