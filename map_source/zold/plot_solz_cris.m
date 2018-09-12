%
% plot_solbin - equal area solar zenith stats
%

addpath source
addpath map_source
addpath /asl/packages/ccast/motmsc/time

d1 = load('sol_npp_x1');
d2 = load('sol_j01_x1');

% subset by solar zenith angle
j1 = d1.sol_list < 70;
j2 = d2.sol_list < 70;
lat_list1 = d1.lat_list(j1);
lon_list1 = d1.lon_list(j1);
sol_list1 = d1.sol_list(j1);
lat_list2 = d2.lat_list(j2);
lon_list2 = d2.lon_list(j2);
sol_list2 = d2.sol_list(j2);

% nLat = 20;  dLon = 6;
  nLat = 24;  dLon = 4;

[latB1, lonB1, gtot1, gavg1] = ...
    equal_area_bins(nLat, dLon, lat_list1, lon_list1, sec(deg2rad(sol_list1)));

[latB2, lonB2, gtot2, gavg2] = ...
    equal_area_bins(nLat, dLon, lat_list2, lon_list2, sec(deg2rad(sol_list2)));

gdiff = gavg2 - gavg1;

tstr = 'CrIS J1 minus NPP mean solar zenith secants';
equal_area_map(1, latB1, lonB1, gdiff, tstr);

return

tstr = 'CrIS NPP mean solar zenith secants';
equal_area_map(2, latB1, lonB1, gavg1, tstr);

tstr = 'CrIS J1 mean solar zenith secants';
equal_area_map(3, latB1, lonB1, gavg2, tstr);

