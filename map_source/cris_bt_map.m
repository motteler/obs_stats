%
% cris_stats - equal area BT mean and std for CrIS NPP and J1
%
% note that CrIS asc is night, and ~asc is day
%

addpath source
addpath map_source
addpath /asl/packages/ccast/motmsc/time
addpath /asl/packages/ccast/motmsc/utils
addpath map_data2

nLat = 24;  dLon = 4;

dlist = [];
M1 = []; W1= []; N1 = [];
M2 = []; W2= []; N2 = [];

% loop on 16-day sets
year = 2018;
for i = 5 : 12
  c1 = load(sprintf('NPP_902y%ds%0.2d.mat', year, i));
  c2 = load(sprintf('N20_902y%ds%0.2d.mat', year, i));

  % asc/dec or other subsetting
  % CrIS asc = 1 is night, asc = 0 is day
  ix1 = ~logical(c1.asc_list);
  ix2 = ~logical(c2.asc_list);
  lat_list1 = c1.lat_list(ix1); 
  lon_list1 = c1.lon_list(ix1); 
  Tb_list1  = c1.Tb_list(ix1);
  lat_list2 = c2.lat_list(ix2); 
  lon_list2 = c2.lon_list(ix2); 
  Tb_list2  = c2.Tb_list(ix2);

  [latB1, lonB1, M1, W1, N1] = ...
    equal_area_var(nLat, dLon, lat_list1, lon_list1, Tb_list1, M1, W1, N1);

  [latB2, lonB2, M2, W2, N2] = ...
    equal_area_var(nLat, dLon, lat_list2, lon_list2, Tb_list2, M2, W2, N2);

  dlist = [dlist, c1.dlist];
  fprintf(1, '.')
end
fprintf(1, '\n')

S1 = sqrt(W1 ./ (N1 - 1));
S2 = sqrt(W2 ./ (N2 - 1));

sol_list1 = c1.sol_list(ix1);
mean(sol_list1)

tstr = 'CrIS NPP mean BT equal area bins';
equal_area_map(1, latB1, lonB1, M1, tstr);

tstr = 'CrIS NPP std BT equal area bins';
equal_area_map(2, latB1, lonB1, S1, tstr);

tstr = 'CrIS J1 minus NPP mean BT equal area bins, %d doy %d-%d';
tstr = sprintf(tstr, c1.year, dlist(1), dlist(end));
equal_area_map(3, latB1, lonB1, M2 - M1, tstr, [-6, 6]);

% tstr = 'CrIS J1 minus NPP std BT equal area bins';
% equal_area_map(4, latB2, lonB2, S2 - S1, tstr);

