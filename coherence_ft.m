
function [ c allvalues ] = coherence_ft( f, varargin )
% c = coherence_ft( fourier, from, to, method )
% Where:
%   fourier: FT (complex) of the channels [tapers x channels]
%   from   : index of channels to calculate from
%   to     : index of channels to calculate to
%   method : 'normbyavgpower' (default) or 'normbytaper'
% All arguments except 'fourier' are optional.

% by Erick Ortiz, 2014-05-14

% Set argument defaults, and say how many are not text options
defaultargs = { [] [] [] };
lastnonopt = 2;

% Adjust defaults, filling in non-optional arguments missing
firstopt = find( cellfun(@ischar,varargin), 1);
if ~isempty( firstopt ),
	varargin = [ varargin(1:firstopt-1) defaultargs(firstopt:lastnonopt) ...
		varargin(firstopt:end) ];
end

% Assign arguments to their rightful names
defaultargs(1:length(varargin)) = varargin;
[ from, to, method ] = defaultargs{:};

if isempty(method),
	method = 'normbyavgpower';
end

if isempty(from),
	% All to all
	from = 1:size(f,2);
	to = from;
end
if isempty(to),
	% Calculate coherence to all channels not in 'from'
	to = setdiff( 1:size(f,2), from );
end

f1 = f(:,from,:);
f2 = f(:,to,:);

switch method
	case 'normbyavgpower'
		% This calculation yields exactly the same result as Fieldtrip
		
		p1 = abs( f1 .* conj(f1) ); % the 'abs' is overkill
		p1 = sqrt( nanmean( p1 ) );

		p2 = abs( f2 .* conj(f2) ); % the 'abs' is overkill
		p2 = sqrt( nanmean( p2 ) );
		
		f1 = bsxfun( @rdivide, f1, p1 );
		f2 = bsxfun( @rdivide, f2, p2 );

	case 'normbytaper'
		% I think this result is different because:
		% 1) the power estimation gets better with many tapers
		% 2) the amplitude can vary quite much im comparison with
		% the avgpower: up to 6 or 8 times larger; i.e. 'normbytaper'
		% always has amplitude 1, while 'normbyavgpower' can have a scale
		% of 6 or more.
		
 		f1 = f1 ./ abs(f1);
 		f2 = f2 ./ abs(f2);

end

% Reorder dims as [ tapers from to frequencies ]
f1 = permute( f1, [1 2 4 3] );
f2 = permute( f2, [1 4 2 3] );
c = bsxfun( @times, f1, conj(f2) );

if nargout > 1,
	allvalues = c;
end

c = squeeze( nanmean( c ) );

return

%% Notes

% 'normbyavgpower' is equivalent to this:
% fdr = ft_freqdescriptives( [], freq );
% p1 = sqrt(fdr.powspctrm(to))';
% p2 = sqrt(fdr.powspctrm(from))';


