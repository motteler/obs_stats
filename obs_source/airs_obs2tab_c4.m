%
% airs_obs2tab_c4 - take AIRS 16-day obs lists to 16-day maps
% 

addpath ../source
addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/time
addpath /home/motteler/shome/obs_stats/sst_source
addpath ../obs_16day_airs_c4

nLat = 24;  dLon = 4;
dlist = [];

% loop on years
% for year = 2002 : 2016
for year = 2018 : 2019

  % annual tabulation
  ytot = [];
  yavg = [];
  yvar = [];
  sind = [];

  % loop on 16-day sets
  for i = 1 : 23

    % load the next 16-day set
    afile = sprintf('airs_c04y%ds%0.2d.mat', year, i);
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
      fprintf(1, 'warning year %d set %d data not sorted\n', year, i)
      [c1.tai_list, jx] = sort(c1.tai_list);
      c1.lat_list = c1.lat_list(jx);
      c1.lon_list = c1.lon_list(jx);
      c1.rad_list = c1.rad_list(:,jx);
    end

    % convert rad to BT
    bt_list = real(rad2bt(c1.vlist, c1.rad_list));

%   % add SST data
%   sst_list = oisst_match(c1.tai_list, c1.lat_list, c1.lon_list);
%   bt_list = [bt_list; sst_list'];

    [latB, lonB, gtot, gavg, gvar] = ...
       equal_area_bins(nLat, dLon, c1.lat_list, c1.lon_list, bt_list);

    % tabulate map data
    ytot = cat(3, ytot, gtot);
    yavg = cat(4, yavg, gavg);
    yvar = cat(4, yvar, gvar);
    sind = [sind, i];

%   fprintf(1, '.')
  end

  % save annual tabulation
  ixt = c1.ixt;
  adir = c1.adir;
  vlist = c1.vlist;
  mfile = sprintf('airs_c04_%d_tab.mat', year);
  fprintf(1, 'saving %s\n', mfile);
  save(mfile, 'ytot', 'yavg', 'yvar', 'sind', 'latB', 'lonB', ...
              'nLat', 'dLon', 'year', 'vlist', 'ixt', 'adir');

% fprintf(1, '\n')
end

