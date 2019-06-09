%
% cris_tab_stats -- annual map tables to map stats
%
% uses CrIS c06 channel set
%
% map table
%   dnum - time index as datenums
%   ntab - nlat x nlon x nset
%   utab - nchan x nlat x nlon x nset
%   vtab - nchan x nlat x nlon x nset
%
% summary maps
%   nmap - nchan x nlat x nlon
%   umap - nchan x nlat x nlon
%   vmap - nchan x nlat x nlon
%
% misc support variables
%   nchan - number of tabulated channels
%   vlist - tabulated channel frequencies
%   nlat  - number of latitude bins
%   nlon  - number of longitude bins
%   latB  - nlat+1 vector, latitude bin boundaries
%   lonB  - nlon+1 vector, longitude bin boundaries
%   nset  - total number of 16-day sets
%

addpath ../source
addpath /asl/packages/ccast/source

%-------------------------------------------
% combine annual tabulations of 16-day maps
%-------------------------------------------
dnum = []; % time index as datenums
ntab = []; % nlat x nlon x time bin count
utab = []; % nchan x nlat x nlon x time bin mean
vtab = []; % nchan x nlat x nlon x time bin variance

% loop on annual tabulations
for year = 2018 : 2019

  mfile = sprintf('N20_c06_%d_tab.mat', year);
  fprintf(1, 'loading %s\n', mfile);
  if exist(mfile) == 2
    c1 = load(mfile);
  else
    fprintf(1, 'missing %s\n', mfile)
    continue
  end

  % 16-day set midpoint day-of-year as datenums
  dlist = (c1.sind - 1) * 16 + 8;
  dtmp = datenum([c1.year, 1, 1]) + dlist;

  % check data
  if find(isnan(c1.yavg)), keyboard, end
  if find(isnan(c1.yvar)), keyboard, end

  % tabulate map data
  dnum = [dnum, dtmp];
  utab = cat(4, utab, c1.yavg);
  vtab = cat(4, vtab, c1.yvar);
  ntab = cat(3, ntab, squeeze(c1.ytot));
end

[nchan, nlat, nlon, nset] = size(utab);

% add 1's row to ntab to match utab and vtab
ntmp = ones(nchan, 1) * ntab(:)';
ntmp = reshape(ntmp, nchan, nlat, nlon, nset);

latB = c1.latB;
lonB = c1.lonB;
vlist = c1.vlist;

%----------------------
% summary mean and std
%----------------------

[nmap, umap, vmap] = merge_tree(ntmp, utab, vtab);

ic = 8;

utmp = squeeze(umap(ic,:,:));
tstr = 'CrIS LW integrated radiance mean';
equal_area_map(1, latB, lonB, utmp, tstr);
c = colorbar; c.Label.String = 'mw sr-1 m-2';

ic = 7;

utmp = squeeze(umap(ic,:,:));
tstr = sprintf('CrIS %.2f cm-1 mean', vlist(ic));
equal_area_map(2, latB, lonB, utmp, tstr);
c = colorbar; c.Label.String = 'degrees (K)';

return

vtmp = squeeze(vmap(ic,:,:));
tstr = sprintf('CrIS %.2f cm-1 std', vlist(ic));
equal_area_map(3, latB, lonB, sqrt(vtmp), tstr);
c = colorbar; c.Label.String = 'degrees (K)';

