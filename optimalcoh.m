
function g = optimalcoh( signal )
% g = optimalcoh( signal )
%   signal: Nsamples x Nchan fourier coefficients
%   g: weights that elicit optimal coherence between the signals in
%   the Nchan-1 first channels and the last (reference) channel

% Normalize signals
p = abs( signal .* conj(signal) ); % Note: the 'abs' is overkill
p = sqrt( nanmean( p ) );
signal = bsxfun( @rdivide, signal, p );

% Solve equations
g = pinv( signal(:,1:end-1) ) * signal(:,end);

return

%% Example

% Pick one frequency from the ft_freqanalysis
% (multitaper, output: 'fourier')
% dimord: 'rpttap_chan_freq'
signal = freq.fourierspctrm(:,:,5);

% Gets filter from 
filt = peak.filter;

% Where should we do the SVD?
% 0) no SVD
% 1) SVD on the filter, then project data
% 2) SVD on the projected data, use all eigenvectors
% 3) SVD on the projected data, use only highest eigenvector

switch 2,
	case 0
		disp('No SVD');
		tmpdat = signal(:,1:end-1) * filt;
		tmpdat = [ tmpdat, signal(:,end) ];
		
	case 1
		disp('SVD on the filter, then project data');
		
		% Selects only the significant orientations
		[u,s,v] = svd(tmpdat,'econ');
		sel = diag(s)/s(1) > 1e-3;
		tmpdat = u(:,sel)*s(sel,sel);
		
		tmpdat(end+1,end+1) = 1;
		tmpdat = signal * tmpdat;

	case 2
		disp('SVD on the projected data, use all eigenvectors');

		tmpdat = signal(:,1:end-1) * filt;
		
		% Selects only the significant orientations
		[u,s,v] = svd(tmpdat,'econ');
		sel = diag(s)/s(1) > 1e-3;
		tmpdat = u(:,sel)*s(sel,sel);
		
		% Add EMG to the mix
		tmpdat = [ tmpdat, signal(:,end) ];

	case 3
		disp('SVD on the projected data, use only highest eigenvector');

		tmpdat = signal(:,1:end-1) * filt;
		
		% Selects only the significant orientations
		[u,s,v] = svd(tmpdat,'econ');
		tmpdat = u(:,1)*s(1,1);
		
		% Add EMG to the mix
		tmpdat = [ tmpdat, signal(:,end) ];
end

% If more than one eigenvector is used, try to find the optimal rotation
if size(tmpdat,2) > 2,
	g = optimalcoh( tmpdat );
else
	g = 1;
end

% Mount mixing matrix including EMG
g1 = abs(g/norm(g));
m = g;
m(end+1,end+1) = 1;

c = coherence_ft( dat * m );

fprintf( 'Optimal coherence found: %.5f\n', c(1,2) );
fprintf( 'Angular shift (deg.): %.1f\n', acosd( g1(1) ) );




