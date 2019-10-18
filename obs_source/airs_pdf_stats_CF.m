%
% airs_pdf_stats -- stats from annual pdf map tables
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

addpath ../source
addpath /asl/packages/ccast/source
addpath ../map_16day_airs_c4

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

%------------
% sample map
%------------

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

figure(1); clf
tstr = 'AIRS 2002-2019 cloud forcing 4-12 K PDF map';
bin_sum = squeeze(sum(tbmap));
bin_span = squeeze(sum(tbmap(65:69,:,:)));
map_test = bin_span ./ bin_sum;
equal_area_map(1, latB, lonB, map_test, tstr);
fstr = 'AIRS_2002-2019_CF_4-12_K_PDF_map';
% saveas(gcf, fstr, 'png')

%---------------
% sample trends
%---------------

[nbin, nlat, nlon, nset] = size(tbtab);

% global summary for tbin subset x time
tx = squeeze(sum(tbtab(65:69,:,:,:)));
tx = reshape(tx, nlat * nlon, nset); 

% SST and CF flag land as NaNs
iOK = logical(ones(nlat*nlon, 1));
for i = 1 : nset-1
  iOK = iOK & ~isnan(tx(:,i));
end

% sum over ocean sets
tx = sum(tx(iOK, :));
P = polyfit(dnum, tx, 1);

% datetime axes for plots 
dax = datetime(dnum, 'ConvertFrom', 'datenum');

figure(2); clf
plot(dax, tx, dax, polyval(P, dnum), 'linewidth', 2)
title('AIRS global 2002-2019 CF 4-12K PDF trend')
legend('16-day sets', 'linear fit', 'location', 'southwest')
ylabel('bin count')
xlabel('year')
grid on; zoom on
fstr = 'AIRS_global_2002-2019_CF_4-12K_PDF_trend';
% saveas(gcf, fstr, 'png')

fprintf(1, 'trend = %.4f K/year\n', P(1)/365)

return

%---------------
% global summary
%---------------

figure(2); clf
tbins = -140 : 2 : 70;  % want to get this from the file

% reshape tbtab for easier ocean indexing
tbtab = reshape(tbtab, nbin, nlat*nlon, nset);

iL = cOR(cOR(isnan(tbtab))');  % boolean flags of land tiles
iW = find(~iL);                % index list of ocean tiles
tbOcean = tbtab(:,iW,:);       % ocean-only map tiles

tb_all_obs_ocean = sum(tbOcean(:,:),2);
semilogy(tbins,tb_all_obs_ocean, 'linewidth', 2)
title('AIRS 2002-2019 CF global counts');
xlabel('temperature bins (K)')
ylabel('bin counts')
grid on; zoom on
% saveas(gcf, 'AIRS_2002-2019_CF_global_counts', 'png')

