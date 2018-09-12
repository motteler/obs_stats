%
% airs_obs_map - equal area obs stats for AIRS and J1
%

addpath ../source
addpath ../map_source
addpath /asl/packages/ccast/motmsc/time
addpath /asl/packages/ccast/motmsc/utils
addpath ../map_data2

nLat = 24;  dLon = 4;

dlist = [];
M1 = []; W1= []; N1 = [];
M2 = []; W2= []; N2 = [];

% loop on 16-day sets
year = 2018;
% for i = [5:7 10:11]
  for i = 10
  c1 = load(sprintf('airs902y%ds%0.2d.mat', year, i));
  c2 = load(sprintf('NPP_902y%ds%0.2d.mat', year, i));

  lat_list1 = c1.lat_list;
  lon_list1 = c1.lon_list;
  obs_list1 = ones(length(c1.lon_list),1);

  lat_list2 = c2.lat_list;
  lon_list2 = c2.lon_list;
  obs_list2 = ones(length(c2.lon_list),1);

  [latB1, lonB1, M1, W1, N1] = ...
    equal_area_var(nLat, dLon, lat_list1, lon_list1, obs_list1, M1, W1, N1);

  [latB2, lonB2, M2, W2, N2] = ...
    equal_area_var(nLat, dLon, lat_list2, lon_list2, obs_list2, M2, W2, N2);

  dlist = [dlist, c1.dlist];
  fprintf(1, '.')
end
fprintf(1, '\n')

S1 = sqrt(W1 ./ (N1 - 1));
S2 = sqrt(W2 ./ (N2 - 1));

% overall mean obs per bin
mN = (sum(N1(:)) + sum(N2(:))) / (numel(N1) + numel(N2));

tstr = 'AIRS obs count/mean';
equal_area_map(1, latB1, lonB1, N1 / mN, tstr);

tstr = 'CrIS NPP obs count/mean';
equal_area_map(2, latB1, lonB1, N2 / mN, tstr);

tstr = 'AIRS minus NPP obs count / mean'
equal_area_map(3, latB1, lonB1, (N1 - N2) / mN, tstr);
load llsmap5; colormap(llsmap5)

% caxis([-0.025, 0.025])
  caxis([-0.1, 0.1])

