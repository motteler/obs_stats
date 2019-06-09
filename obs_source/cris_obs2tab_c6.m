%
% cris_obs2tab - take CrIS 16-day obs lists to annual map tables
% 
% annual map variables
%   yavg  - bin mean, nchan x nlat x nlon x nset
%   yvar  - bin variance, nchan x nlat x nlon x nset
%   ytot  - bin obs count, nlat x nlon x nset
%   latB  - bin latitude boundaries, nlat+1 vector
%   lonB  - bin longitude boundaries, nlon+1 bector
%   dLon  - longitude bin step size, degrees
%   nLat  - number of latitude bands, equator to pole
%   sind  - 16-day set indices, nset vector
%   vlist - channel frequency list
%   year  - year for this table
%
% this version is for the c6 channel set, with radiance mean as the
% last channel variable, with length(vlist) one less than nchan.
%
% beware "N20" is hard-coded in a couple of places, below
%

addpath ../source
addpath /asl/packages/ccast/source

nLat = 24;  dLon = 4;
dlist = [];

% loop on years
  for year = 2018 : 2019

  % annual tabulation 
  ytot = [];
  yavg = [];
  yvar = [];
  sind = [];

  % loop on 16-day sets
  for i = 1 : 23

    % load the next 16-day set
    cfile = sprintf('N20_c06y%ds%0.2d.mat', year, i);
    if exist(cfile) == 2
      c1 = load(cfile);
      if isempty(c1.rad_list)
        fprintf(1, 'no radiance data in %s\n', cfile)
        continue
      end
    else
      fprintf(1, 'missing file %s\n', cfile)
      continue
    end

    % convert rad to BT
    bt_list = real(rad2bt(c1.vlist, c1.rad_list));

    % append radiance mean to obs list
    obs_list = [bt_list; c1.rin_list'];

    % generate the equal area map
    [latB, lonB, gtot, gavg, gvar] = ...
       equal_area_bins(nLat, dLon, c1.lat_list, c1.lon_list, obs_list);

    % tabulate map data
    ytot = cat(3, ytot, gtot);
    yavg = cat(4, yavg, gavg);
    yvar = cat(4, yvar, gvar);
    sind = [sind, i];

    fprintf(1, '.')
  end
  fprintf(1, '\n')

  % save annual tabulation
  vlist = c1.vlist;
  mfile = sprintf('N20_c06_%d_tab.mat', year);
  fprintf(1, 'saving %s\n', mfile);
  save(mfile, 'ytot', 'yavg', 'yvar', 'sind', 'latB', 'lonB', ...
              'nLat', 'dLon', 'year', 'vlist');
end

