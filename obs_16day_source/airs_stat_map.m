%
% airs_stat_map - take 16-day obs-lists to equal area mean and std
% 

addpath ../source
addpath ../map_source
addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/time
addpath /asl/packages/ccast/motmsc/utils
addpath ../airs_rad16

nLat = 24;  dLon = 4;

dlist = [];
total_obs = 0;
M1 = []; W1= []; N1 = [];
M2 = []; W2= []; N2 = [];

% loop on years
% for year = 2003 : 2017
for year = 2003

  % loop on 16-day sets
  for i = 1 : 23
    afile = sprintf('airs_c02y%ds%0.2d.mat', year, i);
    if exist(afile) == 2
      c1 = load(sprintf('airs_c02y%ds%0.2d.mat', year, i));
    else
      fprintf(1, 'missing %s\n', afile)
      continue
    end

    % option for subsetting
    nobs = length(c1.lat_list); 
    ix = logical(ones(1,nobs));
    lat_list = c1.lat_list(ix); 
    lon_list = c1.lon_list(ix); 

    % LW and SW window channel BT means
    bCO2 = real(rad2bt(c1.vlist(1), c1.rad_list(1, :)));
    b902 = mean(real(rad2bt(c1.vlist(2:3), c1.rad_list(2:3, :))));

    % equal area maps
    [latB1, lonB1, M1, W1, N1] = ...
      equal_area_var(nLat, dLon, lat_list, lon_list, bCO2, M1, W1, N1);

    [latB2, lonB2, M2, W2, N2] = ...
      equal_area_var(nLat, dLon, lat_list, lon_list, b902, M2, W2, N2);

%   dlist = [dlist, c1.dlist];
    total_obs = total_obs + nobs;
    fprintf(1, '.')
  end
  fprintf(1, '\n')
end

S1 = sqrt(W1 ./ (N1 - 1));
S2 = sqrt(W2 ./ (N2 - 1));

% clear c1
% save airs_15_year_stats

vlist = c1.vlist;
clear c1
save(sprintf('airs_c2_%d_stats', year))
return

tstr = 'AIRS LW window BT mean equal area bins';
equal_area_map(1, latB1, lonB1, M1, tstr);

tstr = 'AIRs LW window BT std equal area bins';
equal_area_map(2, latB1, lonB1, S1, tstr);

tstr = 'AIRS SW window BT mean equal area bins';
equal_area_map(3, latB2, lonB2, M2, tstr);

tstr = 'AIRs SW window BT std equal area bins';
equal_area_map(4, latB2, lonB2, S2, tstr);

