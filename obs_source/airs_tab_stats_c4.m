%
% airs_tab_stats -- annual map tables to map stats
%
%    airs c4 channel set
%  ind   freq      comments
% ---------------------------------------
%   1    830.47   Window, H2O Cont
%   2    843.91   CFC-11
%   3    899.62   Window, Edge M-08 small a/b drift there
%   4    921.64   CFC-12  (0.1K over 16 years)
%   5    968.23   Window, tiny CO2?
%   6    992.45   Window
%   7   1227.71   Weak water, used to get column water with 1520
%   8   1231.33   Window, lowest WV absorption
%   9   sea surface temperature
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
addpath ../map_16day_airs_c4

%-------------------------------------------
% combine annual tabulations of 16-day maps
%-------------------------------------------
dnum = []; % time index as datenums
ntab = []; % nlat x nlon x time bin count
utab = []; % nchan x nlat x nlon x time bin mean
vtab = []; % nchan x nlat x nlon x time bin variance

% loop on annual tabulations
for year = 2002 : 2019

  mfile = sprintf('airs_c04_g2_%d_tab.mat', year);
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
% if find(isnan(c1.yavg)), keyboard, end
% if find(isnan(c1.yvar)), keyboard, end

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

%---------------------
% mean and std trends
%---------------------

ic = 8; % choose a channel
ntmp1 = squeeze(ntmp(ic,:,:,:));
utab1 = squeeze(utab(ic,:,:,:));        % map table mean
stab1 = sqrt(squeeze(vtab(ic,:,:,:)));  % map table std

utabP = zeros(nlat,nlon,2);  % per tile mean poly fit
stabP = zeros(nlat,nlon,2);  % per tile std poly fit

for i = 1 : nlat
  for j = 1 : nlon
    utabP(i,j,:) = polyfit(dnum, squeeze(utab1(i,j,:))', 1);
    stabP(i,j,:) = polyfit(dnum, squeeze(stab1(i,j,:))', 1);
  end
end

% rescale K/day to K/year
dutab = 365 * squeeze(utabP(:,:,1));
dstab = 365 * squeeze(stabP(:,:,1));

% zero-centered colormap
load llsmap5

tstr = sprintf('AIRS %.2f cm-1 2002-2019 mean trends', vlist(ic));
equal_area_map(1, latB, lonB, dutab, tstr);
c = colorbar; c.Label.String = 'degrees K / year';
caxis([-0.21, 0.21])
colormap(llsmap5)
  saveas(gcf, t2fstr(tstr), 'png')

tstr = sprintf('AIRS %.2f cm-1 2002-2019 std dev trends', vlist(ic));
equal_area_map(2, latB, lonB, dstab, tstr);
c = colorbar; c.Label.String = 'degrees K / year';
caxis([-0.21, 0.21])
colormap(llsmap5)
  saveas(gcf, t2fstr(tstr), 'png')

return

%----------------------
% summary mean and std
%----------------------

[nmap, umap, vmap] = merge_tree(ntmp, utab, vtab);

ic = 8; % choose a channel
utmp = squeeze(umap(ic,:,:));
tstr = sprintf('AIRS %.2f cm-1 2002-2019 mean', vlist(ic));
equal_area_map(1, latB, lonB, utmp, tstr);
c = colorbar; c.Label.String = 'degrees (K)';

vtmp = sqrt(squeeze(vmap(ic,:,:)));
tstr = sprintf('AIRS %.2f cm-1 2002-2019 std', vlist(ic));
equal_area_map(2, latB, lonB, vtmp, tstr);
c = colorbar; c.Label.String = 'degrees (K)';

