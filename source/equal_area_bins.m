%
% NAME
%   equal_area_bins - count and mean for equal area trapezoids
%
% SYNOPSIS
%   [latB, lonB, gtot, gavg, gsqr] = ...
%          equal_area_bins(nLat, dLon, lat, lon, obs)
%
% INPUTS
%   nLat  - number of latitude bands from equator to pole
%   dLon  - longitude band size in degrees, should divide 180
%   lat   - k-vector, latitude list, values -90 to 90
%   lon   - k-vector, longitude list, values -180 to 180
%   obs   - optional k-vector, associated data values
%
% OUTPUTS
%   latB  - m+1 vector, latitude bin boundaries
%   lonB  - n+1 vector, longitude bin boundaries
%   gtot  - m x n array, obs counts
%   gavg  - m x n array, obs means
%   gsqr  - m x n array, obs^2 means
%
% DISCUSSION
%   equal_area_bins takes a list of lat, lon, and data values and
%   returns count and mean for equal area bins.  Data values and
%   means are optional.  The bins are trapezoids obtained by slicing
%   up equal area latitude bands, which gives pie-shaped wedges at
%   the poles.
%
%   The grid for the bins is specified with nLat, the number of
%   latitude bands from equator to the pole, and dLon, the longitude
%   band width in degrees.  The output parameters latB and lonB are
%   the grid boundaries. 
%
% AUTHOR
%  H.  Motteler, 20 June 2017
%

function [latB, lonB, gtot, gavg, gsqr] = ...
          equal_area_bins(nLat, dLon, lat, lon, obs)

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
gtot = zeros(mlat, nlon);  % binned obs count
gavg = zeros(mlat, nlon);  % binned obs mean
gsqr = zeros(mlat, nlon);  % binned mean of obs^2

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
    gtot(ilat, ilon) = gtot(ilat, ilon) + 1;
    gavg(ilat, ilon) = gavg(ilat, ilon) + obs(i);
    gsqr(ilat, ilon) = gsqr(ilat, ilon) + obs(i) * obs(i);
  else
    [ilat, ilon]
    error('latitude or longitude index out of range')
  end

% if mod(i, 1e6) == 0, fprintf(1, '.'), end
end
% fprintf(1, '\n')

% take the means
gavg = gavg ./ gtot;
gsqr = gsqr ./ gsqr;

