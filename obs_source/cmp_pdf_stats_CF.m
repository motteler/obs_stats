%
% cmp_pdf_stats -- stats from annual pdf map tables
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

addpath ../source
addpath /asl/packages/ccast/source
addpath ../pdf_16day_airs

%-------------------------------------------
% combine annual tabulations of 16-day maps
%-------------------------------------------
dnum = [];   % nset index as datenums
tbtab = [];  % nbin x nlat x nlon x nset

% loop on annual tabulations
% for year = 2002 : 2019
for year = 2017 : 2018

% mfile = sprintf('airs_CF_g2_%d_pdf.mat', year); % AIRS
  mfile = sprintf('npp_CF_g2_%d_pdf.mat', year);  % CrIS
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

  tstr = 'CrIS 2017-2018 CF -140 to -6 K PDF map';
% tstr = 'AIRS 2002-2019 CF 4-12 K PDF map';
% tstr = 'AIRS 2017-2018 CF 4-8 K PDF map';
% tstr = 'CrIS 2017-2018 CF 4-8 K PDF map';
% tstr = 'AIRS 2002-2019 CF 50-100 K PDF map';
bin_sum = squeeze(sum(tbmap));
bin_span = squeeze(sum(tbmap(1:68,:,:)));

% bin_span = squeeze(sum(tbmap(65:69,:,:)));
% bin_span = squeeze(sum(tbmap(67:69,:,:))); % 4-8 K
% bin_span = squeeze(sum(tbmap(21:46,:,:)));
bin_rel = bin_span ./ bin_sum;
equal_area_map(1, latB, lonB, bin_rel, tstr);
% caxis([0.05, 0.5])
% saveas(gcf, t2fstr(tstr), 'png'

