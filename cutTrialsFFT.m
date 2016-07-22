function dataFFT = cutTrialsFFT(cfg,dataFFT)
if ~isfield(cfg,'parameter'), cfg.parameter = 'fourierspctrm'; end

%%
param   = cfg.parameter;
cum     = dataFFT.cumtapcnt-1;
sumCum  = [0;cumsum(cum)]+1;

trials = cfg.trials;
if isequal(length(trials),length(cum))
    trials = find(trials);
end
tmp = [];
for tr = 1 : numel(trials)
    trial = trials(tr);
    tempCum   = sumCum(trial+[0 1]);
    taps      = tempCum(1):tempCum(2);
    tmp       = cat(1,tmp,dataFFT.(param)(taps,:,:));
end

dataFFT = dataFFT;
dataFFT.fourierspctrm = tmp;
dataFFT.cumsumcnt = dataFFT.cumsumcnt(trials);
dataFFT.cumtapcnt = dataFFT.cumtapcnt(trials);
dataFFT.trialinfo = dataFFT.trialinfo(trials);
end
%{
clc
a =  numel(trials);
b = size(tmp,1);
c = cum(1)+1;

fprintf('trials      %f\nsize        %f\ntapers      %f\nsize/tapers %f\ntrials*tapers %f\n',a,b,c,b/c,a*c)
%}