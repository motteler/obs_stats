%
% NAME
%   equal_area_pdfs - PDFs for equal area tiles
%
% SYNOPSIS
%   [latB, lonB, tbmap] = ...
%          equal_area_pdfs(nLat, dLon, lat, lon, obs, tbins)
%
% INPUTS
%   nLat  - number of latitude bands from equator to pole
%   dLon  - longitude band width in degrees, should divide 180
%   lat   - k-vector, latitude list, values -90 to 90
%   lon   - k-vector, longitude list, values -180 to 180
%   obs   - k-vector, associated data values
%   tbins - j-vector, temperature bins, T1 : dT : T2
%
% OUTPUTS
%   latB  - m+1 vector, latitude tile boundaries
%   lonB  - n+1 vector, longitude tile boundaries
%   tbmap - j x m x n array, temp bin counts at each map tile
%
% DISCUSSION
%   equal_area_pdfs takes a list of lat, lon, and obs and returns
%   a 3D data structure, tbin x lat x lon, a map with a temperature
%   bin count vector for each map tile.  Map tiles are determined by
%   dividing equal area latitude bands with equally spaced longitude
%   arcs.  This gives trapezoids and pie-shaped wedges at the poles.
%
%   The tile grid is specified with nLat, the number of latitude
%   bands from equator to the pole, and dLon, the longitude band
%   width in degrees.  Output parameters latB and lonB are tile
%   boundaries, for maps.
%
% AUTHOR
%  H.  Motteler, 10 Sep 2019
%

function [latB, lonB, tbmap] = ...
          equal_area_pdfs(nLat, dLon, lat, lon, obs, tbins)

nobs = length(lat);

% latitude bands
latB = equal_area_spherical_bands(nLat);

% longitude bands
lonB = -180 : dLon : 180;

mlat = length(latB) - 1;   % number of latitude bands
nlon = length(lonB) - 1;   % number of longitude bands

% initialize temp bins
T1 = tbins(1);
dT = tbins(2) - tbins(1);
nbin = length(tbins);
tbmap = zeros(nbin, mlat, nlon);

% loop on [lat,lon,obs] values
for i = 1 : nobs

% if isnan(obs(i)), continue, end

  % latitude tile index
  ilat = find(lat(i) < latB, 1) - 1;
  if ilat > mlat, ilat == mlat; end

  % longitude tile index
  ilon = floor((lon(i) - lonB(1)) / dLon) + 1;
  if ilon > nlon, ilon = nlon; end

  % check for valid ranges
  if 1 <= ilat & ilat <= mlat & 1 <= ilon & ilon <= nlon;

    if isnan(obs(i))
      tbmap(:, ilat, ilon) = NaN;
      continue
    end

    ix = floor((obs(i) - T1) / dT) + 1;
    if ix < 1, ix = 1; end
    if nbin < ix, ix = nbin; end

    tbmap(ix, ilat, ilon) = tbmap(ix, ilat, ilon) + 1;

  else
    [ilat, ilon]
    error('latitude or longitude index out of range')
  end

% if mod(i, 1e6) == 0, fprintf(1, '.'), end
end
% fprintf(1, '\n')

