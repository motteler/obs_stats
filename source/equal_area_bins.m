%
% NAME
%   equal_area_bins - obs stats for equal area bins
%
% SYNOPSIS
%   [latB, lonB, gtot, gavg, gvar] = ...
%          equal_area_bins(nLat, dLon, lat, lon, obs)
%
% INPUTS
%   nLat  - number of latitude bands from equator to pole
%   dLon  - longitude band width in degrees, should divide 180
%   lat   - k-vector, latitude list, values -90 to 90
%   lon   - k-vector, longitude list, values -180 to 180
%   obs   - optional j x k-vector, j channels per obs 
%
% OUTPUTS
%   latB  - m+1 vector, latitude bin boundaries
%   lonB  - n+1 vector, longitude bin boundaries
%   gtot  - m x n array, bin obs counts
%   gavg  - j x m x n array, bin obs means
%   gvar  - j x m x n array, bin obs variance
%
% DISCUSSION
%   equal_area_bins takes a list of lat, lon, and obs and returns
%   count, mean, and variance for each bin in an equal area grid.
%   Bins are determined by dividing equal area latitude bands with
%   equally spaced longitude arcs.  This gives trapezoids and pie-
%   shaped wedges at the poles.
%
%   The bin grid is specified with nLat, the number of latitude
%   bands from equator to the pole, and dLon, the longitude band
%   width in degrees.  Output parameters latB and lonB are bin
%   boundaries, for maps.
%
%   obs can be either a vector or a j x k array.  When obs is a
%   vector, gavg and gsqr are returned as m x n arrays.  obs can 
%   be omitted if all that is desired is counts.
%
% REFERENCES
%   (1) Wikipedia: Algorithms for calculating variance.
%   (2) Donald E. Knuth (1998). The Art of Computer Programming,
%   volume 2: Seminumerical Algorithms, 3rd edn., p. 232. Boston:
%   Addison-Wesley.
%
% AUTHOR
%  H.  Motteler, 20 June 2017
%

function [latB, lonB, gtot, gavg, gvar] = ...
          equal_area_bins(nLat, dLon, lat, lon, obs)

% check inputs
if nargin == 4
  nchan = 1;
  nobs = length(lat);
  obs = zeros(1, nobs);
else
  [nchan, nobs] = size(obs);
  if nobs == 1
    obs = obs';
    [nchan, nobs] = size(obs);
  end
  if nobs ~= length(lat)
    error('obs must be an nobs vector or nchan x nobs array')
  end
end

% latitude bands
latB = equal_area_spherical_bands(nLat);

% longitude bands
lonB = -180 : dLon : 180;

mlat = length(latB) - 1;   % number of latitude bands
nlon = length(lonB) - 1;   % number of longitude bands
gtot = zeros(mlat, nlon);  % binned obs count
gavg = zeros(nchan, mlat, nlon);  % binned obs means
gvar = zeros(nchan, mlat, nlon);  % binned obs variance

% loop on [lat,lon,obs] values
for i = 1 : nobs

  % latitude bin index
  ilat = find(lat(i) < latB, 1) - 1;
  if ilat > mlat, ilat == mlat; end

  % longitude bin index
  ilon = floor((lon(i) - lonB(1)) / dLon) + 1;
  if ilon > nlon, ilon = nlon; end

  % check for valid ranges
  if 1 <= ilat & ilat <= mlat & 1 <= ilon & ilon <= nlon;

    % working variables
    x = obs(:, i);
    n2 = gtot(ilat, ilon) + 1;
    gtot(ilat, ilon) = n2;
    m1 = gavg(:, ilat, ilon);
    w1 = gvar(:, ilat, ilon);
 
    % update mean and variance
    d1 = x - m1;
    m2 = m1 + d1 ./ n2;
    w2 = w1 + d1 .* (x - m2);
    gavg(:, ilat, ilon) = m2;
    gvar(:, ilat, ilon) = w2;

  else
    [ilat, ilon]
    error('latitude or longitude index out of range')
  end

% if mod(i, 1e6) == 0, fprintf(1, '.'), end
end
% fprintf(1, '\n')

for i = 1 : nchan
  gvar(i,:,:) = squeeze(gvar(i,:,:)) ./ (gtot - 1);
end

gavg = squeeze(gavg);
gvar = squeeze(gvar);

