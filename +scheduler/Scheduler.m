classdef Scheduler < handle
properties(Access=private)
    problem1 struct {} = getDefaultStruct()
    problem2 struct {} = getDefaultStruct()
    problem3 struct {} = getDefaultStruct()
    problem4 struct {} = getDefaultStruct()
    problem5 struct {} = getDefaultStruct()
    problem6 struct {} = getDefaultStruct()
    problem7 struct {} = getDefaultStruct()
    problem8 struct {} = getDefaultStruct()
    objective string {isValidObj} = "fiscal";
    exportPath string {} = ""
    nBus double {} = 5;
    nCharger double {} = 5;
    routeinfo {} = ""
    uncontrolled {} = ""
    verbose logical {} = true
    nSecondPerStep double {} = 20
    batteryCapacity double {} = 450;
    chargerCapacity double {} = 350;
    initialBatteryEnergy double {} = 360;
    uncontrolledMultiplyFactor double {} = 1;
    minBatteryEnergy double {} = 100;
    onPeakEnergyCost double {} = 0.058282
    offPeakEnergyCost double {} = 0.029624;
    onPeakPowerCost double {} = 15.73;
    overallPeakPowerCost double {} = 4.81;
end
methods(Access=public)
    function set(obj, name, value1, value2)

        % define valid inputes
        problemvar = getValidVariables();
        validName = problemvar("all");
        problems = problemvar("problems");

        % error check for valid inputes
        if any(strcmp(validName,name))

            % if addressing problem solver value
            if any(strcmp(problems,name)) && nargin == 4

                % get desired problem
                problem = obj.(name);
                validparam = problemvar(name);
                if any(strcmp(validparam,value1))
                    problem.(value1) = value2;
                else
                    % find parameter if already in solver parameters
                    [~, idx] = find(strcmpi([problem.solverParams{:}],value1));

                    % if in solver paremters, replace with given, otherwise add
                    if ~isempty(idx)
                        problem.solverParams{idx + 1} = value2;
                    else
                        problem.solverParams{end + 1} = value1;
                        problem.solverParams{end + 1} = value2;
                    end
                end

                % reassign
                obj.(name) = problem;
            else
                obj.(name) = value1;
            end
        else
            error("Scheduler::set invalid parameter name");
        end
    end
    function result = get(obj, name, param)
        problems = ["problem1","problem2","problem3","problem4",...
                    "problem5","problem6","problem7","problem8"];
        validName = [problems "startPoint","objective","exportPath"];
        if any(strcmp(name,validName))
            if ~any(strcmp(name,problems))
                result = obj.(name);
            else
                problem = obj.(name);
                if nargin == 3
                    [~, idx] = find(strcmpi([problem.solverParams{:}],param));
                    result = problem.solverParams{idx + 1};
                else
                    result = problem;
                end
            end
        else
            error("Scheduler::add invalid parameter name");
        end
    end
    function plan = makeplan(obj)
        import scheduler.*

        % compute non-smooth, unconstrained solution (problem 1)
        if obj.verbose
            fprintf("Starting: Unconstrained Solution\n");
        end
        [Sim1, Var1, Sol1] = computeIdeal(obj.nBus,                       ...
                                          obj.nCharger,                   ...
                                          obj.nSecondPerStep,             ...
                                          obj.objective,                  ...
                                          obj.chargerCapacity,            ...
                                          obj.batteryCapacity,            ...
                                          obj.initialBatteryEnergy,       ...
                                          obj.uncontrolledMultiplyFactor, ...
                                          obj.minBatteryEnergy,           ...
                                          obj.problem1.solverParams,      ...
                                          obj.onPeakEnergyCost,           ...
                                          obj.offPeakEnergyCost,          ...
                                          obj.onPeakPowerCost,            ...
                                          obj.overallPeakPowerCost);

        % package metadata
        if isfield(Sol1,'mipgap')
            obj.problem1.gap = Sol1.mipgap;
        else
            obj.problem1.gap = 0;
        end
        obj.problem1.solveTime = Sol1.runtime;

        % progress report
        if obj.verbose
            fprintf("Finished: Unconstrained Solution\n");
        end

        % compute smoothed unconstrained solution (problem 2)
        if obj.verbose
            fprintf("Starting: Pre-Smoothing\n");
        end
        [Sim2, Var2, Sol2] = computeSmooth(Sim1, Var1, Sol1, obj.problem2.solverParams);
        if isfield(Sol2,'mipgap')
            obj.problem2.gap = Sol2.mipgap;
        else
            obj.problem2.gap = 0;
        end
        obj.problem2.solveTime = Sol2.runtime;
        
        % progress report
        if obj.verbose
            fprintf("Finished: Pre-Smoothing\n");
        end

        % separate buses into groups (problem 3)
        if obj.verbose
            fprintf("Starting: Group Separation\n");
        end
        [groups, Simg, Varg, Solg] = computeGroups(Sim2, Var2, Sol2.x, obj.problem3.nGroup, obj.problem3.solverParams);
        if isfield(Solg,'mipgap')
            obj.problem3.gap = Solg.mipgap;
        else
            obj.problem3.gap = 0;
        end
        if isfield(Solg,'runtime')
            obj.problem3.solveTime = Solg.runtime;
        else
            obj.problem3.solveTime = 0;
        end
        if obj.verbose
            fprintf("Finished: Group Separation\n");
        end

        % preallocate for group processing
        nSim = groups.nGroup;
        Sims3 = util5.getAllSimParam(Sim2, Var2, Sol2.x, groups, obj.problem4.threshold);
        Sols3 = cell([nSim,1]);
        Vars3 = cell([nSim,1]);
        Sims4 = cell([nSim,1]);
        Sols4 = cell([nSim,1]);
        Vars4 = cell([nSim,1]);
        Sims5 = cell([nSim,1]);
        Sols5 = cell([nSim,1]);
        Vars5 = cell([nSim,1]);
        u = Sim1.u;

        for iSim = 1:numel(Sims3)

            % Defragment charge schedule (problem 4)
            Sim3 = Sims3{iSim}; Sim3.u = u;
            if obj.verbose
                fprintf("Starting: de-fragmenting sub-problem %i of %i\n",iSim,nSim);
            end
            [Sols3{iSim}, Vars3{iSim}] = computeDefragmentedSolution(Sim3, obj.problem4.solverParams);
            if isfield(Sols3{iSim},'mipgap')
                obj.problem4.gap(iSim) = Sols3{iSim}.mipgap;
            else
                obj.problem4.gap(iSim) = 0;
            end
            obj.problem4.solveTime(iSim) = Sols3{iSim}.runtime;
            if obj.verbose
                fprintf("Finished: de-fragmenting sub-problem %i of %i\n",iSim,nSim);
            end

            % update uncontrolled loads to reflect new solution
            u = u + sum(Sols3{iSim}.x(Vars3{iSim}.b),1);

            % assign buses to chargers (problem 5)
            Sim4 = util2.getSimParam(Sims3{iSim}, Vars3{iSim}, Sols3{iSim}.x);
            Sims4{iSim} = Sim4;
            Sim4.mWidth = Sim4.mWidth + 1e-3;
            if obj.verbose
                fprintf("Starting: Charger Scheduling for sub-set %i of %i\n",iSim,numel(Sims3));
            end
            [Sols4{iSim}, Vars4{iSim}] = computeBusAssignments(Sim4, obj.problem5.losstype, obj.problem5.solverParams);
            if isfield(Sols4{iSim},'mipgap')
                obj.problem5.gap(iSim) = Sols4{iSim}.mipgap;
            else
                obj.problem5.gap(iSim) = 0;
            end
            obj.problem5.solveTime(iSim) = Sols4{iSim}.runtime;
            if obj.verbose
                fprintf("Finished: Charger Scheduling for sub-set %i of %i\n",iSim,numel(Sims3));
            end

            % compute charge intervals (problem 6)
            if obj.verbose
                fprintf("Starting: Optimizing Schedule Window...\n");
            end
            Sims5{iSim} = util7.getSimParam(Sims4{iSim}, Vars4{iSim}, Sols4{iSim});
            [Sols5{iSim}, Vars5{iSim}] = computeChargeIntervals(Sims5{iSim}, obj.problem7.solverParams);
            if isfield(Sols5{iSim},'mipgap')
                obj.problem6.gap(iSim) = Sols5{iSim}.mipgap;
            else
                obj.problem6.gap(iSim) = 0;
            end
            obj.problem6.solveTime(iSim) = Sols5{iSim}.runtime;
            if obj.verbose
                fprintf("Finished: Optimizing Schedule Window\n")
            end

            % apply optimized start/stop times to schedule from solution 4
            Sols4{iSim} = applyScheduleTimes(Sols4{iSim}, Vars4{iSim}, Sims4{iSim}, ...
                Sols5{iSim}, Vars5{iSim}, Sims5{iSim});
        end

        % fine tune step-by-step power use (problem 7)
        if obj.verbose
            fprintf('Starting: Variable Charge Rates\n');
        end
        Sim6 = util4.getSimParam(Sim2, Var2, Sol2, Sims4, Vars4, Sols4, groups);
        [Sol6, Var6] = computeReOptimizedSolution(Sim6, obj.objective, obj.problem7.solverParams);
        if isfield(Sol6,'mipgap')
            obj.problem7.gap = Sol6.mipgap;
        else
            obj.problem6.gap = 0;
        end
        obj.problem7.solveTime = Sol6.runtime;
        if obj.verbose
            fprintf('Finished: Variable Charge Rates\n');
        end

        % add smoothing for hardware (problem 8)
        if obj.verbose
            fprintf('Starting: Post-Smoothing\n');
        end
        Sim7 = util8.getSimParam(Sim6, Var6, Sol6);
        [Sol7, Var7] = computeSmoothReOptimization(Sim7, obj.problem8.solverParams);
        if isfield(Sol7,'mipgap')
            obj.problem8.gap = Sol7.mipgap;
        else
            obj.problem8.gap = 0;
        end
        obj.problem8.solveTime = Sol7.runtime;
        if obj.verbose
            fprintf('Finished: Post-Smoothing.\n');
        end

        % package results
        schedule = Sol7.x(Var7.schedule);
        nRoute = Sim6.nSession;
        plan = cell([obj.nBus,max(nRoute)]);
        time = (0:Sim1.nTime - 1)/Sim1.nTime*3600*24;
        for iBus = 1:obj.nBus
            for iRoute = 1:nRoute(iBus)
                chargerIdx = Sim6.chargerIdx(iBus,iRoute);
                iSession = logical(squeeze(Sim6.routeIdx(iBus,iRoute,:)));
                sessionPower = schedule(iBus,iSession);
                tStart = (find(iSession,1,'first') - 1)*obj.nSecondPerStep;
                tFinal = (find(iSession,1,'last'))*obj.nSecondPerStep;
                plan{iBus,iRoute} = struct('iCharger',chargerIdx,...
                    'power',sessionPower,'time',time(iSession),...
                    'tStart',tStart,'tFinal',tFinal);
            end
        end
    end
end
end
function result = isValidObj(objective)
    objectives = ["busDemand","fiscal","energy","baseline"];
    result = any(strcmp(objective,objectives));
end
function problemvar = getValidVariables()
problems = ["problem1","problem2","problem3","problem4",...
    "problem5","problem6","problem7","problem8"];
problemvar = containers.Map();
problemvar("problems") = problems;
problemvar("all") = [problems, "exportPath","objective","startPoint",...
    "nBus","nCharger","routeinfo","uncontrolled","verbose",...
    "nSecondPerStep","batteryCapacity","chargerCapacity", ...
    "initialBatteryEnergy","uncontrolledMultiplyFactor","minBatteryEnergy", ...
    "onPeakEnergyCost", "offPeakEnergyCost", "onPeakPowerCost", ...
    "overallPeakPowerCost"];
problemvar("problem1") = "";
problemvar("problem2") = "";
problemvar("problem3") = ["nGroup"];
problemvar("problem4") = ["threshold"];
problemvar("problem5") = ["losstype"];
problemvar("problem6") = "";
problemvar("problem7") = "";
problemvar("problem8") = "";
end
function default = getDefaultStruct()
    s = struct();
    s.solverParams = {"MIPGap",0.02,"OutputFlag",0};
    s.solution = struct();
    s.gap = nan;
    s.solveTime = nan;
    s.constraint = nan;
    default = s;
end