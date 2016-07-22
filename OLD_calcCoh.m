function C = calcCoh(F,G)

crossSpectrum  = sum(bsxfun(@times,permute(F,[1 4 2 3]),conj(permute(G,[4 1 2 3]))),4);

% AUTO-SPECTRUM REFERENCE
autoSpectrum1  = sum(sqrt(F.*conj(F)),3);
autoSpectrum2  = sum(sqrt(G.*conj(G)),3);

% CALCULATE COHERENCY
autoSpectra  = (bsxfun(@times,permute(autoSpectrum1,[1 3 2]),permute(autoSpectrum2,[3 1 2])));

C            = bsxfun(@rdivide,crossSpectrum,autoSpectra);