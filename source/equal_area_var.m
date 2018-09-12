%
% NAME
%   equal_area_var - mean and variance for equal area trapezoids
%
% SYNOPSIS
%   [latB, lonB, M1, W1, N1] = ...
%          equal_area_var(nLat, dLon, lat, lon, obs, M1, W1, N1)
%
% INPUTS
%   nLat  - number of latitude bands from equator to pole
%   dLon  - longitude band size in degrees, should divide 180
%   lat   - k-vector, latitude list, values -90 to 90
%   lon   - k-vector, longitude list, values -180 to 180
%   obs   - k-vector, associated data values
%   M1    - m x n array, previous recursive mean
%   W1    - m x n array, previous sum((x - mean(x))^2)
%   N1    - m x n array, previous recursive count
%
% OUTPUTS
%   latB  - m+1 vector, latitude bin boundaries
%   lonB  - n+1 vector, longitude bin boundaries
%   M1    - m x n array, current recursive mean
%   W1    - m x n array, current sum((x - mean(x))^2)
%   N1    - m x n array, current recursive count
%
% DISCUSSION
%   equal_area_var takes a list of lat, lon, and obs values and
%   updates incremental mean and variance for a set of equal area
%   bins as specified by nLat and dLon.  The bins are trapezoids
%   obtained by slicing up equal area latitude bands, with pie-
%   shaped wedges at the poles.
%
%   The grid for the bins is specified with nLat, the number of
%   latitude bands from equator to the pole, and dLon, the longitude
%   band width in degrees.  The output parameters latB and lonB are
%   the grid boundaries.
%
% AUTHOR
%  H.  Motteler, 18 Jul 2018
%

function [latB, lonB, M1, W1, N1] = ...
         equal_area_var(nLat, dLon, lat, lon, obs, M1, W1, N1)

nobs = length(lat);

if nargin == 4
  obs = zeros(nobs, 1);
end

% latitude bands
latB = equal_area_spherical_bands(nLat);

% longitude bands
lonB = -180 : dLon : 180;

mlat = length(latB) - 1;   % number of latitude bands
nlon = length(lonB) - 1;   % number of longitude bands
% gtot = zeros(mlat, nlon);  % obs counts with pcolor buffer
% gavg = zeros(mlat, nlon);  % obs means with pcolor buffer

if isempty(N1)
  % initialize input bins
  M1 = zeros(mlat, nlon);
  W1 = zeros(mlat, nlon);
  N1 = zeros(mlat, nlon);
else
  % check bin sizes
  [m, n] = size(M1);
  if m ~= mlat | n ~= nlon
    error('M1 does not conform with nLat or dLon')
  end
  [m, n] = size(W1);
  if m ~= mlat | n ~= nlon
    error('W1 does not conform with nLat or dLon')
  end
  [m, n] = size(N1);
  if m ~= mlat | n ~= nlon
    error('N1 does not conform with nLat or dLon')
  end
end

% loop on lat/lon/obs values
for i = 1 : nobs

  % latitude bin index
  if lat(i) == 90
    ilat = mlat;
  else
    ilat = find(lat(i) < latB, 1) - 1;
  end

  % longitude bin index
  if lon(i) == 180
    ilon = nlon;
  else
    ilon = floor((lon(i) - lonB(1)) / dLon) + 1;
  end

  % check for valid ranges
  if 1 <= ilat & ilat <= mlat & 1 <= ilon & ilon <= nlon;
    [M1(ilat,ilon), W1(ilat,ilon), N1(ilat,ilon)] = ...
       rec_var(M1(ilat,ilon), W1(ilat,ilon), N1(ilat,ilon), obs(i));
%   gtot(ilat, ilon) = gtot(ilat, ilon) + 1;
%   gavg(ilat, ilon) = gavg(ilat, ilon) + obs(i);
  else
    [ilat, ilon]
    error('latitude or longitude index out of range')
  end

% if mod(i, 1e6) == 0, fprintf(1, '.'), end
end
% fprintf(1, '\n')

% take the mean 
% gavg = gavg ./ gtot;

