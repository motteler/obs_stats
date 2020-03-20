%
% airs_pdf_trends -- mapped trends from annual pdf map tables
%
% reads annual pdf map tables, with variables
%   tbtab - nbin x nlat x nlon x nset pdf map table
%   tbins - nbin vector, pdf temperature bins
%   sind  - nset vector, list of 16 day set indices
%   latB  - nlat+1 vector, latitude bin boundaries
%   lonB  - nlon+1 vector, longitude bin boundaries
%   cfrq  - channel frequency (nan for CF & SST)
%
% new or updated working variables
%   tbtab - nbin x nlat x nlon x nset, multi-year table
%   dnum  - nset vector, datenum values for set index
%
% this version is for CF and SST plots (NaNs for land)
% 
% The section "trends over all map tiles" computes a PDF at each map
% tile, for each 16-day set, takes 1-year moving average of these, and
% presents the data in various ways.  These includes a count of how
% may times the moving average exceeds some threshold, and trends at
% individual tiles.
%

addpath ../source
addpath /asl/packages/ccast/source
addpath ../pdf_16day_airs

%-------------------------------------------
% combine annual tabulations of 16-day maps
%-------------------------------------------
dnum = [];   % nset index as datenums
tbtab = [];  % nbin x nlat x nlon x nset

% loop on annual tabulations
for year = 2002 : 2019

  mfile = sprintf('airs_CF_g2_%d_pdf.mat', year);
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

  % tabulate pdf (tbin) data
  dnum = [dnum, dtmp];
  tbtab = cat(4, tbtab, c1.tbtab);

end

latB = c1.latB;
lonB = c1.lonB;
% cfrq = c1.cfrq;
% tbins = c1.tbins;
tbins = -140 : 2 : 70;

%---------------------------------
% summary map over all time steps
%---------------------------------

% sum bins over all time steps
[nbin, nlat, nlon, nset] = size(tbtab);
tbmap = zeros(nbin, nlat, nlon);
for k = 1 : nset
  for j = 1 : nlon
    for i = 1 : nlat
      tbmap(:,i,j) = tbmap(:,i,j) + tbtab(:,i,j,k);
    end
  end
end

% tstr = 'AIRS 2002-2019 CF 4-12 K PDF map';
  tstr = 'AIRS 2002-2019 CF 4-8 K PDF map';
% tstr = 'AIRS 2002-2019 CF 50-100 K PDF map';
bin_sum = squeeze(sum(tbmap));
% bin_span = squeeze(sum(tbmap(65:69,:,:)));
  bin_span = squeeze(sum(tbmap(67:69,:,:)));
% bin_span = squeeze(sum(tbmap(21:46,:,:)));
bin_rel = bin_span ./ bin_sum;

equal_area_map(1, latB, lonB, bin_rel, tstr);

% saveas(gcf, t2fstr(tstr), 'fig')

%---------------------------
% trends over all map tiles
%---------------------------

[nbin, nlat, nlon, nset] = size(tbtab);

% reduce tbtab along the tbin (first) dimension
% this leaves an nlat x nlon x nstep count array
tz = squeeze(sum(tbtab));
ty = squeeze(sum(tbtab(67:69,:,:,:)));  % 4-8K 

% nlat x nlon x nstep ocean flag;
% iOK = ~isnan(tz);

% moving average along the time (last) dimension
nsp = 11;       % half-span
pwt = ty./tz;   % normalize
pmv = zeros(nlat,nlon,nset);  % PDF moving avg
cmv = zeros(nlat,nlon,nset);  % PDF moving counts

% set up polynomial fit to moving averages
pd = 1;  % polynomial degree
P = zeros(pd+1,nlat,nlon);

for i = 1 : nlat
  for j = 1 : nlon
    for k = 1 : nset
      k1 = max(1, k-nsp);
      k2 = min(k+nsp, nset);
      pmv(i,j,k) = mean(pwt(i, j, k1:k2));
      cmv(i,j,k) = sum(ty(i, j, k1:k2));
    end
    P(:,i,j) = polyfit(dnum, squeeze(pmv(i,j,:))', pd);
  end
end

tstr = 'AIRS 2002-2019 CF 4-8 K PDF > 0.4 counts';
% tile_val = 23 * squeeze(P(1,:,:));
tile_val = sum(pmv > 0.4, 3);
equal_area_map(2, latB, lonB, tile_val, tstr);
% saveas(gcf, t2fstr(tstr), 'fig')

% find sample hot spot
% ix = find(tile_val > 380);
% [i,j] = ind2sub([64,120], ix)

% select a tile
% ilat = 22;  ilon = 63;
  ilat = 23;  ilon = 63;
% ilat = 21;  ilon = 64;
% ilat = 22;  ilon = 64;

tlat = latB(ilat); tlon = lonB(ilon);

% datetime axes for plots 
dax = datetime(dnum, 'ConvertFrom', 'datenum');

figure(3); clf
plot(dax, squeeze(pmv(ilat, ilon, :)), 'linewidth', 2);
tstr = sprintf('AIRS tile %.1f, %.1f CF 4-8K PDF trend', tlat, tlon); 
title(tstr)
ylabel('PDF weight')
xlabel('year')
grid on; zoom on

% saveas(gcf, t2fstr(tstr), 'fig')

return

