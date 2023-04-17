function [Sol3, Var3] = computeDefragmentedSolution(Sim3, solverparam)
import scheduler.con5.*;
import scheduler.util5.*;

 Var3 = getVarParam(Sim3);

    [A1, b1, nCon1, descr1, eq1] = getCon1(Sim3,Var3);
    [A2, b2, nCon2, descr2, eq2] = getCon2(Sim3,Var3);
    [A3, b3, nCon3, descr3, eq3] = getCon3(Sim3,Var3);
    [A4, b4, nCon4, descr4, eq4] = getCon4(Sim3,Var3);
    [A5, b5, nCon5, descr5, eq5] = getCon5(Sim3,Var3);
    [A6, b6, nCon6, descr6, eq6] = getCon6(Sim3,Var3);
    [A7, b7, nCon7, descr7, eq7] = getCon7(Sim3,Var3);
    [A8, b8, nCon8, descr8, eq8] = getCon8(Sim3,Var3);
    [A9, b9, nCon9, descr9, eq9] = getCon9(Sim3,Var3);
    [A10, b10, nCon10, descr10, eq10] = getCon10(Sim3,Var3);
    obj = getObj(Sim3,Var3);

    vtype = [Var3.bType; ...
        Var3.isUsedAndFragmentedType; ...
        Var3.ptType; ...
        Var3.p15Type; ...
        Var3.routeEnergyType; ...
        Var3.demandType; ...
        Var3.facilitiesType; ...
        Var3.eOnType; ...
        Var3.eOffType; ...
        Var3.hType;];
    A = [A1; A2; A3; A4; A5; A6; A7; A8; A9; A10];
    b = [b1; b2; b3; b4; b5; b6; b7; b8; b9; b10];
    eq = [eq1; eq2; eq3; eq4; eq5; eq6; eq7; eq8; eq9; eq10];
    model.vtype = vtype;
    model.obj = obj;
    model.A = A;
    model.rhs = b;
    model.sense = eq;
    Sol3 = gurobi(model,struct(solverparam{:}));

    if Sol3.status == "INFEASIBLE"
        error("Model infeasible: computeDefragmentedSolution");
    end
end