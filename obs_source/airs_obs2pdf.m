%
% airs_obs2pdf - 16-day obs lists to annual pdf map tables
% 
% one output file per year, with variables
%   tbtab - nbin x nlat x nlon x nset pdf map table
%   tbins - nbin vector, pdf temperature bins
%   sind  - nset vector, list of 16 day set indices
%   latB  - nlat+1 vector, latitude bin boundaries
%   lonB  - nlon+1 vector, longitude bin boundaries
%   cfrq  - channel frequency (nan for CF & SST)
%

addpath ../source
addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/time
addpath /home/motteler/shome/obs_stats/sst_source
addpath ../obs_16day_airs_c4

% nLat = 24;  dLon = 4;
  nLat = 32;  dLon = 3;

% loop on years
% for year = 2002 : 2019
for year = 2017 : 2018

  % annual tabulation
  tbtab = [];
  sind = [];

  % loop on 16-day sets
  for i = 1 : 23

    % load the next 16-day set
    afile = sprintf('airs_c04y%ds%0.2d.mat', year, i);  % AIRS c4
%   afile = sprintf('NPP_c07y%ds%0.2d.mat', year, i);   % CrIS c7
    if exist(afile) == 2
      c1 = load(afile);
      if isempty(c1.rad_list)
        fprintf(1, 'empty file %s\n', afile)
        continue
      end
    else
      fprintf(1, 'missing %s\n', afile)
      continue
    end

    % check that data is in time order
    if ~issorted(c1.tai_list)
      fprintf(1, 'warning: year %d set %d data not sorted\n', year, i)
      [c1.tai_list, jx] = sort(c1.tai_list);
      c1.lat_list = c1.lat_list(jx);
      c1.lon_list = c1.lon_list(jx);
      c1.rad_list = c1.rad_list(:,jx);
    end

    % convert rad to BT
    bt_list = real(rad2bt(c1.vlist, c1.rad_list));

    % add SST data
    try
      sst_list = oisst_match(c1.tai_list, c1.lat_list, c1.lon_list);
    catch
      fprintf(1, 'warning: no SST data for set %d\n', i)
      continue
    end
    sst_list = sst_list + 273.15;  % convert C to K
    sst_list = sst_list';          % need a row vector

    % add cloud forcing 
    BT1228 = squeeze(bt_list(7,:));   % AIRS c4
    BT1231 = squeeze(bt_list(8,:));   % AIRS c4
%   BT1228 = squeeze(bt_list(1,:));   % CrIS c7
%   BT1231 = squeeze(bt_list(2,:));   % CrIS c7
    P = [-0.17 -0.15 -1.66  1.06];            % AIRS CF
%   P = [-0.2761 -0.4112 -2.3116 -0.0760];    % CrIS CF 2015
%   P = [-0.3534 -0.7227 -2.6887 -0.2027];    % CrIS CF 2016
    CF = BT1231 - (sst_list - polyval(P, BT1228 - BT1231));

%   % basic window channel
%   ic = 6;
%   cfrq = c1.vlist(ic);
%   obs = squeeze(bt_list(ic,:));
%   tbins = 200 : 2 : 340;

%   % sea surf temp
%   cfrq = nan;
%   obs = sst_list;
%   tbins = 268 : 1 : 315;

    % cloud forcing
    cfrq = nan;
    obs = CF;
    tbins = -140 : 2 : 70;

    % build the PDF map
    [latB, lonB, tbmap] = ...
       equal_area_pdfs(nLat, dLon, c1.lat_list, c1.lon_list, obs, tbins);

    % add to annual tabulation
    tbtab = cat(4, tbtab, tbmap);
    sind = [sind, i];

%   fprintf(1, '.')
  end

  % save annual tabulation
% adir = c1.adir;
  vlist = c1.vlist;
% mfile = sprintf('airs_c4-%d_g2_%d_pdf.mat', ic, year);
  mfile = sprintf('airs_CF_g2_%d_pdf.mat', year);  % AIRS CF
% mfile = sprintf('npp_CF_g2_%d_pdf.mat', year);   % CrIS CF
  fprintf(1, 'saving %s\n', mfile);
  save(mfile, 'tbtab', 'sind', 'latB', 'lonB', 'nLat', 'dLon', ...
              'year', 'cfrq', 'tbins', 'vlist');

% fprintf(1, '\n')
end

