function obj = getObjConsumption(Sim, Var)
obj = zeros([Var.nVar,1]);
       for iTime = 1:Sim.nTime
            if Sim.isOnPeak(iTime)
                obj(Var.allpower(iTime)) = Sim.muEOn;
            else
                obj(Var.allpower(iTime)) = Sim.muEOff;
            end
       end
end