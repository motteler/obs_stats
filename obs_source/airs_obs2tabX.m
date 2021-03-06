%
% airs_obs2map2 - take AIRS 16-day obs lists to 16-day maps
% 

addpath ../source
addpath /asl/packages/ccast/source
addpath ../obs_16day_airs_c3

nLat = 24;  dLon = 4;
dlist = [];

% loop on years
% for year = 2002 : 2018
for year = 2018

  % annual tabulation
  ytot = [];
  yavg = [];
  yvar = [];
  sind = [];

  % loop on 16-day sets
  for i = 1 : 23

    % load the next 16-day set
    afile = sprintf('airs_c03y%ds%0.2d.mat', year, i);
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

%   % convert rad to BT
%   bt_list = real(rad2bt(c1.vlist, c1.rad_list));

%   profile clear
%   profile on
    [latB, lonB, gtot, gavg, gvar] = ...
       equal_area_bins(nLat, dLon, c1.lat_list, c1.lon_list, c1.rad_list);
%   profile report

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
  mfile = sprintf('airsX_c03_%d_tab.mat', year);
  fprintf(1, 'saving %s\n', mfile);
  save(mfile, 'ytot', 'yavg', 'yvar', 'sind', 'latB', 'lonB', ...
              'nLat', 'dLon', 'year', 'vlist', 'ixt', 'adir');

% fprintf(1, '\n')
end

