dirLoc = '\\wsl.localhost\ubuntu\home\dmortensen\paper4';
resultDir = fullfile(dirLoc,'results');
files = ["LossType_fiscal_nBus_60_nCharger_7_nGroup_1_dt_20_minEnergy_0.00_proCost",...
         "LossType_fiscal_nBus_60_nCharger_7_nGroup_1_dt_20_minEnergy_5.00_proCost",...
         "LossType_fiscal_nBus_60_nCharger_7_nGroup_1_dt_20_minEnergy_10.00_proCost",...
         "LossType_fiscal_nBus_60_nCharger_7_nGroup_1_dt_20_minEnergy_15.00_proCost",...
         "LossType_fiscal_nBus_60_nCharger_7_nGroup_1_dt_20_minEnergy_20.00_proCost",...
         "LossType_fiscal_nBus_60_nCharger_7_nGroup_1_dt_20_minEnergy_25.00_proCost",...
         "LossType_fiscal_nBus_60_nCharger_7_nGroup_1_dt_20_minEnergy_30.00_proCost",...
         "LossType_fiscal_nBus_60_nCharger_7_nGroup_1_dt_20_minEnergy_35.00_proCost",...
         "LossType_fiscal_nBus_60_nCharger_7_nGroup_1_dt_20_minEnergy_40.00_proCost",...
         
         ..."LossType_fiscal_nBus_40_nCharger_7_nGroup_1_dt_20_minEnergy_0.00_proTime",...
         ..."LossType_fiscal_nBus_60_nCharger_7_nGroup_1_dt_20_minEnergy_0.00_proTime",...
         ..."LossType_fiscal_nBus_80_nCharger_7_nGroup_1_dt_20_minEnergy_0.00_proCost",...
         ..."minEnergy/LossType_fiscal_nBus_40_nCharger_40_nGroup_1_dt_20_minEnergy_20.00_proTime",...
         ..."minEnergy/LossType_fiscal_nBus_40_nCharger_40_nGroup_1_dt_20_minEnergy_25.00_proTime",...
         ..."minEnergy/LossType_fiscal_nBus_40_nCharger_40_nGroup_1_dt_20_minEnergy_30.00_proTime",...
         ..."minEnergy/LossType_fiscal_nBus_40_nCharger_40_nGroup_1_dt_20_minEnergy_35.00_proTime",...
         ..."minEnergy/LossType_fiscal_nBus_40_nCharger_40_nGroup_1_dt_20_minEnergy_40.00_proTime",...
         ..."minEnergy/LossType_fiscal_nBus_40_nCharger_40_nGroup_1_dt_20_minEnergy_45.00_proTime",...
         ..."minEnergy/LossType_fiscal_nBus_40_nCharger_40_nGroup_1_dt_20_minEnergy_50.00_proTime",...
         ..."minEnergy/LossType_fiscal_nBus_40_nCharger_40_nGroup_1_dt_20_minEnergy_55.00_proTime",...
         ..."minEnergy/LossType_fiscal_nBus_40_nCharger_40_nGroup_1_dt_20_minEnergy_60.00_proTime",...
         ..."minEnergy/LossType_fiscal_nBus_40_nCharger_40_nGroup_1_dt_20_minEnergy_65.00_proTime",...
         ..."minEnergy/LossType_fiscal_nBus_40_nCharger_40_nGroup_1_dt_20_minEnergy_70.00_proTime",...
         ..."minEnergy/LossType_fiscal_nBus_40_nCharger_40_nGroup_1_dt_20_minEnergy_75.00_proTime",...
          ];
for iFile = 1:numel(files)
    data = load(fullfile(resultDir,files(iFile)));
    t1 = data.Sol1.runtime;
    t2 = data.Sol2.runtime;
    try
        t3 = data.Solg.runtime;
    catch
        t3 = 0;
    end
    t4 = 0;
    t5 = 0;
    t6 = 0;
    for iSol = 1:numel(data.Sols3)
    t4 = t4 + data.Sols3{iSol}.runtime;
    t5 = t5 + data.Sols4{iSol}.runtime;
    t6 = t6 + data.Sols5{iSol}.runtime;
    end
    t7 = data.Sol6.runtime;
    t8 = data.Sol7.runtime;
    tUnconstrain = t1 + t2;
    tAll = tUnconstrain + t3 + t4 + t5 + t6 + t7 + t8;
    cost = data.plan.cost;
    unCost = data.opt.cost;
    fprintf("total time: %0.2f, Unconstrained Time: %0.2f cost: %0.2f unconstrain cost: %0.2f no smooth time: %0.2f\n",tAll, tUnconstrain, cost, unCost, t1);

end
