function obj = getObjConsumption(Sim, Var)
obj = zeros([Var.nVar,1]);
       for iTime = 1:Sim.nTime
            if Sim.S(iTime)
                obj(Var.pt) = Sim.muEOn;
            else
                obj(Var.)
            end
       end
fprintf('temp\n');
end