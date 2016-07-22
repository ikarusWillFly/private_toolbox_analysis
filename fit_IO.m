function IO = fit_IO(IO,autoPlot)
%IO.in;               1XM Vector containing the x-values  of the IO curve (IE: intensities used) 
% 
%IO.out;              NXM Matrix containing the responses of the IO curve <intensities X prepetitions> (mep sizes)
% 
%IO.pred_in;          1XM Vector containing the new x-values to predict the IO curve
% 
% 
%additional parameters: 
%IO.fun;              function handle containing the function to fit the data
%                             default value = @(param,xval)0+(param(1)-0)./(1+exp((param(2)-xval)*param(3)));                    3 parameters sigmoid function with the lower boundary fixed at 0
%                             other entries = @(param,xval)param(1) +(param(2)-param(1))./(1+exp((param(3)-xval)*param(4)))      4 parameters sigmoid function
%                             
%IO.fit_opt;          structure containing the fitting options: see help nlinfit
%                             default value = []
%                             other entries = IO.fit_opt.RobustWgtFun = 'bisquare'; IO.fit_opt.MaxIter = 1000;
% 
%IO.init_prm;         initial parameters for the fitting function 
%                             default value  = [quantile(IO.out(:),0.95) IO.in(IO.out(:)==quantile(IO.out(:),0.5)) 1];                  for 3 parameters sigmoid function
%                             other entries  = [quantile(y,0.05) quantile(IO.out(:),0.95) IO.in(IO.out(:)==quantile(IO.out(:),0.5)) 1]; for 4 parameters sigmoid function
%                                 
%fit_IO automatically calls the function "sample_IO" to find the best intensities to sample the IO curve
%sample_IO takes the IO.fit structure of fit_IO function and requires the following parameters
%
%IO.sampling_alpha;   how wide is the sampling of the IO curve (smallest alpha wider sampling over the sigmoid plateaus)
%                             default value = 0.05;     
%                             
%                             
%IO.sampling_method; the method to use to sample the IO curve
%                            default value = 'threhsold'         it only returns the threshold value of the IO curve
%                            other entries = 'classic'           taking samples from 90% of the threshold to 140% 
%                                            'diff'              over sampling of the IO_curve threshold and plateaus * it samples the IO curve with a multiple of 3 n of intensities
%                                            'linear'            linear sampling uning withing the two plateaus                  
%                                            'minStep'           linear sampling of minimum step from the thresold
%
%IO.n_samples;       number of intensities to sample the IO curve
%                             default value = 1;                 sampling only at the threshold  
%IO.sampling_res;    number of intensities to sample the IO curve
%                             default value = 1;                 resolution of the sampling intensities (minimum step of the stimulator)  
%
%IO.sampling_width;  ratio of the curve to oversample (below and above the two plateaus) 
%                             default value = .1;                10% of the size of the curve is sampled outiside the plateaus
%                             
% 
%autoPlot                                                       flag for plotting
%                             default value = 0                  not plotting the results
%                             default value = 1                  plotting the IO curve and the sampling
%
% HOW TO USE THE FUNCTION:
%     IO         = [];
%     IO.in      = X(:);
%     IO.out     = y(:);
%     IO.pred_in = newX(:);
%     IO.fit_opt.RobustWgtFun   = 'bisquare';
%     IO.fit_opt.MaxIter        = 1000;
% 
%     IO.sampling_alpha         = .05;
%     IO.sampling_method        = 'diff';
%     IO.n_samples              = 15;
%     IO.sampling_res           = .1;
%     IO.sampling_width         = .1;
% 
%     IO.fun   = @(param,xval) 0 + (param(1)-0)./(1+exp((param(2)-xval)*param(3)));
%     IO       = fit_IO(IO,1);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        


%%% INPUT CHECKING
field = 'pred_in';          value = linspace(IO.in(1),IO.in(end,1),size(IO.in,1)*10); 
if ~isfield(IO,field); IO.(field) = value; end
field = 'fun';              value = @(param,xval)0+(param(1)-0)./(1+exp((param(2)-xval)*param(3))); 
if ~isfield(IO,field); IO.(field) = value; end
field = 'fit_opt';          value = [];                 % fitting options. IE: IO.fit_opt.RobustWgtFun = 'bisquare'; IO.fit_opt.MaxIter = 1000;
if ~isfield(IO,field); IO.(field) = value; end
field = 'init_prm';         value = [];                 % 1st parameter: quantile(y,0.05)
if ~isfield(IO,field); IO.(field) = value; end
field = 'fit_method';       value = 'nln';              % 1st parameter: quantile(y,0.05)
if ~isfield(IO,field); IO.(field) = value; end
field = 'varargin';         value = {};                 % 1st parameter: quantile(y,0.05)
if ~isfield(IO,field); IO.(field) = value; end

% the function automatically calls the function "sample_IO" to find the best intensities to sample the IO curve
field = 'sample_IO';                value = 0;          % flag to sampling the curve
if ~isfield(IO,field); IO.(field) = value; end
field = 'sampling_alpha';           value = 0.01;        % how large you want to sample your IO curve
if ~isfield(IO,field); IO.(field) = value; end
field = 'sampling_method';          value = 'threshold'; % classic; diff; linear;
if ~isfield(IO,field); IO.(field) = value; end
field = 'n_samples';                value = 1;           % multiple of 3 for method == diff
if ~isfield(IO,field); IO.(field) = value; end
field = 'sampling_res';             value = 1;           % resolution of the stimulator
if ~isfield(IO,field); IO.(field) = value; end
field = 'sampling_width';           value = .1;          % ratio of the curve to oversample (below and above the two plateaus) 
if ~isfield(IO,field); IO.(field) = value; end

if nargin <2,            autoPlot = 0;     end

%%% find the initial parameters of the fitting function
if isempty(IO.init_prm)
    [~,thres]   = min(abs(IO.out(:)-quantile(IO.out(:),0.5)));
    thres       = IO.in(thres);
    IO.init_prm = [quantile(IO.out(:),0.95) thres .5];
end

%%% find mean values for each intensity
[IO.in_values,~, IND] = unique(IO.in(:));  IO.meanOut = nan(size(IO.in_values));
for j = 1 : numel(IO.in_values), IO.meanOut(j) = nanmean(IO.out(IND ==j)); end

lastwarn('')
%%% IO CURVE FITTING
switch IO.fit_method
    case 'minbnd'
        lo_bnd = IO.bnd_prm(1,:);
        up_bnd = IO.bnd_prm(2,:);
        fun = @(prm) sqrt(sum((IO.fun(prm,IO.in) - IO.out).^2)); % low_bnd = [ -inf -inf 0]; up_bnd = [ inf inf inf];
        [IO.BETA,IO.er,IO.mess,IO.minbnd_info,IO.paramCI,IO.grad] = fmincon(fun,IO.init_prm,[],[],[],[],lo_bnd,up_bnd,[],IO.fit_opt);
        IO.RESID  = IO.fun(IO.BETA,IO.in) - IO.out;
        
        [IO.BETA2,IO.RESID,IO.J,IO.COVB,IO.MSE]       = nlinfit(IO.in(:),IO.out(:),IO.fun,IO.BETA,IO.fit_opt);
        IO.paramCI                                    = nlparci(IO.BETA,IO.RESID,'Jacobian',IO.J);
        tmp      = IO.BETA;
        IO.BETA  = max(min(IO.BETA,up_bnd),lo_bnd);
        IO.RESID = IO.fun(IO.BETA,IO.in);  
%       disp([IO.bnd_prm;first_guess;tmp;IO.BETA])
    case 'ls'
        [IO.BETA,~,IO.RESID,IO.warn,IO.OUTPUT,IO.paramCI,IO.J]  = lsqcurvefit(IO.fun,IO.init_prm,IO.in,IO.out);
        [~,~,~,IO.COVB,IO.MSE] = nlinfit(IO.in(:),IO.out(:),IO.fun,IO.init_prm,IO.fit_opt);
    case 'nln'
        % fitting the IO curve
        [IO.BETA,IO.RESID,IO.J,IO.COVB,IO.MSE] = nlinfit(IO.in(:),IO.out(:),IO.fun,IO.init_prm,IO.fit_opt);
        IO.paramCI            = nlparci(IO.BETA,IO.RESID,'Jacobian',IO.J);
end
% prediction of the IO curve and confidence intervals estimation
[IO.YPRED,IO.DELTA]   = nlpredci(IO.fun,IO.pred_in,IO.BETA,IO.RESID,'Covar',IO.COVB);
IO.YPREDLOWCI         = IO.YPRED - IO.DELTA;
IO.YPREDUPCI          = IO.YPRED + IO.DELTA;
IO.warn               = lastwarn;

%%% IO CURVE SAMPLING
if IO.sample_IO, IO                = sample_IO(IO); end
%%% PLOTTING
if autoPlot
    try
        lineV        = @(x,spec) plot(repmat(reshape(x,1,[]),2,1),repmat(ylim',1,numel(x)),spec{:}); % x has to be 1 x N_lines
        col = 'b';
        %%%%%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % handle = figure; set(handle,'windowstyle','docked');
        plot(IO.pred_in,IO.YPRED,col,'linewidth',2); hold on,                                  % plot IO
        plot(IO.in,IO.out,['.',col]);                                                               % plot MEP data
        scatter(IO.in_values,IO.meanOut,['o',col],'filled','MarkerEdgeColor',[0 0 0]);          % plot mean values
        spec = {col,'edgecolor',col,'edgealpha',0,'facealpha',.1};                             % patch specifications
        patch([IO.pred_in,fliplr(IO.pred_in)],[IO.YPREDLOWCI(:) ;flipud(IO.YPREDUPCI(:))],spec{:});  % patch CI
        axis tight; ylim(ylim +[-.1 .1]*range(ylim))                                           % set the axis tight
        lineV(IO.sampling_int,{'k'});                                                          % plot threshold
        lineV(IO.LO_plateau, {['--',col]});                                                    % plot threshold
        lineV(IO.UP_plateau, {['--',col]});                                                    % plot threshold
        lineV(IO.threshold,  {'--r'});                                                         % plot threshold
        xlim([IO.LO_plateau,IO.UP_plateau]+[-1 1]*(IO.threshold-IO.LO_plateau)/1.5);
        if ~isempty(lastwarn), text(max(xlim)*.8,max(ylim)*.9,'BAD FITTING!','fontweight','bold','fontsize',10,'color','r'), end % your fitting is bad and you should feel bad!
    catch er
        warning('PLOTTING ERROR')
        IO.er = er;
    end
end
end

function IO = sample_IO(IO)
% sample_IO takes the fit function from fit_IO function and determines the best intensities to stimulate to characterize the IO curve
% field = 'pred_in';            the x values of the function    
%
% field = 'alpha';            how wide is the sampling of the IO curve (smallest alpha wider sampling over the sigmoid plateaus)
%                             default value = 0.01;     
%                             
%                             
% field = 'Sampling_method'; the method to use to sample the IO curve
%                            default value = 'threhsold'                     it only returns the threshold value of the IO curve
%                            other entries = 'classic'                       taking samples from 90% of the threshold to 140% 
%                                            'diff'                          over sampling of the IO_curve threshold and plateaus * it samples the IO curve with a multiple of 3 n of intensities
%                                            'linear'                        linear sampling uning withing the two plateaus                  
% 
% field = 'n_samples';        number of intensities to sample the IO curve
%                             default value = 1;                             sampling only at the threshold       
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
field = 'sampling_alpha';           value = 0.01;        % how large you want to sample your IO curve
if ~isfield(IO,field); IO.(field) = value; end
field = 'sampling_method';          value = 'threshold'; % classic; diff; linear;
if ~isfield(IO,field); IO.(field) = value; end
field = 'n_samples';                value = 1;           % multiple of 3 for method == diff
if ~isfield(IO,field); IO.(field) = value; end
field = 'sampling_res';             value = 1;           % resolution of the stimulator
if ~isfield(IO,field); IO.(field) = value; end
field = 'sampling_width';           value = .1;          % ratio of the curve to oversample (below and above the two plateaus) 
if ~isfield(IO,field); IO.(field) = value; end

demean            = @(x) x-mean(x);
roundTo           = @(number,precision) round(number*(1/precision))*precision;


IO.diff1          = diff(IO.YPRED);
IO.threshold      = IO.pred_in(find(IO.diff1 == max(IO.diff1),1));
IO.cumProb        = cumsum(IO.diff1./sum(IO.diff1));
IO.LO_plateau     = IO.pred_in(abs(IO.cumProb-   IO.sampling_alpha/2)  == min(abs(IO.cumProb-   IO.sampling_alpha/2)));
IO.UP_plateau     = IO.pred_in(abs(IO.cumProb-(1-IO.sampling_alpha/2)) == min(abs(IO.cumProb-(1-IO.sampling_alpha/2))));
IO.width          = IO.UP_plateau-IO.LO_plateau;


if isempty(IO.width),           IO.width  = nan; end
if isempty(IO.LO_plateau), IO.LO_plateau  = nan; end
if isempty(IO.UP_plateau), IO.UP_plateau  = nan; end

th = IO.threshold;
ns = IO.n_samples;
sr = IO.sampling_res;
up = IO.UP_plateau;
lo = IO.LO_plateau;
ov = IO.width*IO.sampling_width;

switch IO.sampling_method
    case 'threshold'
        IO.sampling_int     = th;
    case 'classic'
        IO.sampling_int     = th.*linspace(.9,1.4,ns);
    case 'diff'
        if mod(ns,3)~=0, warning('select a multiple of 3 for IO_sampling method == "diff"'); end
        sampling_int        = demean(linspace(0,2*ov,(ns./3)));
        IO.sampling_int     = reshape(bsxfun(@plus,round([lo,th,up]),sampling_int'),[],1);
    case 'linear'
        IO.sampling_int     = linspace(lo-ov/2,up+ov/2,ns);
    case 'minStep'
        IO.sampling_int     = th + fix(linspace(-ns/2,ns/2,ns)*sr*(1/sr))*sr;
end
IO.sampling_int = roundTo(IO.sampling_int,IO.sampling_res);
end