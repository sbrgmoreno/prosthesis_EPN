function evalLogs = evaluateQRDQN(agentMatPath, numEpisodes)
% evaluateQRDQN
% Loads AgentFinal.mat or AgentEp_*.mat and evaluates with greedy policy.
%
% Usage:
%   evalLogs = evaluateQRDQN("C:\...\AgentFinal.mat", 50);

if nargin < 2
    numEpisodes = 50;
end

addpath(genpath('.\src'))
addpath(genpath('.\config'))
addpath(genpath('.\lib'))
addpath(genpath('.\agents'))

configs = configurables();

% Load agent networks
S = load(agentMatPath);

if isfield(S, "onlineNetFinal")
    onlineNet = S.onlineNetFinal;
elseif isfield(S, "onlineNetToSave")
    onlineNet = S.onlineNetToSave;
else
    error("No online network found in MAT file: %s", agentMatPath);
end

if isfield(S, "numQuantiles")
    numQuantiles = S.numQuantiles;
elseif isfield(S, "numQuantilesToSave")
    numQuantiles = S.numQuantilesToSave;
else
    numQuantiles = 51;
end

% Specs
obsInfo = Env.defineObservationInfo();
actInfo = Env.defineActionDiscreteInfo();
actionsSet = actInfo.Elements;
numActions = numel(actionsSet);

% Env
if configs.usePrerecorded
    [emg, glove] = getDataset(configs.dataset, configs.dataset_folder);
    env = Env("", true, emg, glove);
else
    env = Env("", false);
end

maxStepsEp = configs.RLtrainingOptions.MaxStepsPerEpisode;

% Eval
evalLogs.returns = zeros(1, numEpisodes);
evalLogs.actions = cell(1, numEpisodes);

for ep = 1:numEpisodes
    obs = reset(env);
    epRet = 0;
    actHist = zeros(1, maxStepsEp);

    for t = 1:maxStepsEp
        aIdx = selectActionQR(onlineNet, obs, numActions, numQuantiles);
        actionVec = actionsSet{aIdx};

        [nextObs, r, done, ~] = step(env, actionVec);
        epRet = epRet + r;

        actHist(t) = aIdx;
        obs = nextObs;

        if done
            actHist = actHist(1:t);
            break;
        end
    end

    evalLogs.returns(ep) = epRet;
    evalLogs.actions{ep} = actHist;

    fprintf("Eval Ep %d | Return %.4f\n", ep, epRet);
end

figure;
plot(evalLogs.returns, '-o');
xlabel('Evaluation Episode');
ylabel('Return');
title('QR-DQN Evaluation Returns (Greedy)');
grid on;

end

function aIdx = selectActionQR(net, obs, numActions, N)
dlX = dlarray(single(obs(:)), "CB");
Z = forward(net, dlX);
Z = extractdata(Z);
Z = reshape(Z, [N, numActions]);
Q = mean(Z, 1);
[~, aIdx] = max(Q);
aIdx = double(aIdx);
end
