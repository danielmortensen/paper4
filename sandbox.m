import scheduler.*

% define simulation level variables
S = Scheduler();
set(S, 'objective','fiscal');
set(S, 'nBus', 10);
set(S, 'nCharger', 10);
set(S, 'exportPath','results');
set(S, 'verbose', true);
set(S, 'routeinfo', 'data/routesTable.csv');
set(S, 'uncontrolled', 'data/TPSS_Cov15.mat');
set(S, 'uncontrolledMultiplyFactor',5.0);
set(S, 'nSecondPerStep',20); % must evenly divide 15*60 (15-minutes)
set(S, 'batteryCapacity',450);
set(S, 'chargerCapacity',350);
set(S, 'minBatteryEnergy',90);
set(S, 'onPeakEnergyCost',0.058282);
set(S, 'offPeakEnergyCost',0.029624);
set(S, 'onPeakPowerCost',15.73);
set(S, 'overallPeakPowerCost',4.81);

% define variables for first problem (first schedule)
set(S, 'problem1','MIPGap',0.02);
set(S, 'problem1','OutputFlag',0);

% define variables for second problem (smooth schedule)
set(S, 'problem2','MIPGap',0.02);
set(S, 'problem2','OutputFlag',0);

% define variables for third problem (group separation)
set(S, 'problem3', 'nGroup',2); % must evenly divide number of buses and chargers
set(S, 'problem3', 'MIPGap',1.0);
set(S, 'problem3', 'OutputFlag',0);

% define variables for fourth problem (defragmentation)
set(S, 'problem4', 'threshold', 20);
set(S, 'problem4', 'MIPGap',0.02);
set(S, 'problem4', 'OutputFlag',0);

% define variables for fifth problem (charger assignment)
set(S, 'problem5', 'losstype','None'); % quadratic, None, max, difference
set(S, 'problem5', 'MIPGap',1.0);
set(S, 'problem5', 'OutputFlag',0);

% define variables for sixth problem (session optimization)
set(S, 'problem6', 'MIPGap',0.02);
set(S, 'problem6', 'OutputFlag',0);

% define variables for seventh problem (Optimized Non-Smooth)
set(S, 'problem7', 'MIPGap',0.02);
set(S, 'problem7', 'OutputFlag',0);

% define variables for eighth problem (Optimized Smooth)
set(S, 'problem8', 'MIPGap',0.02);
set(S, 'problem8', 'OutputFlag',0);

% compute charge plan
routes = S.makeplan();



