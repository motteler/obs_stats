%
% map_test6 - map_test5 with equal_area_bins, for comparison
%

addpath source
addpath map_source
addpath /asl/packages/ccast/motmsc/time
addpath /asl/packages/ccast/motmsc/utils
addpath map_data

nLat = 24;  dLon = 4;

dlist = [];
tot1 = 0; sum1 = 0; 
tot2 = 0; sum2 = 0;

% loop on 16-day sets
year = 2018;
for i = 5 : 12
  c1 = load(sprintf('NPP_902y%ds%0.2d.mat', year, i));
  c2 = load(sprintf('N20_902y%ds%0.2d.mat', year, i));

  % data QC (we shouldn't need this...)
  iOK1 = -90 <= c1.lat_list & c1.lat_list <=  90 & ...
        -180 <= c1.lon_list & c1.lon_list <= 180;
  lat_list1 = c1.lat_list(iOK1); 
  lon_list1 = c1.lon_list(iOK1); 
  Tb_list1 = c1.Tb_list(iOK1);

  iOK2 = -90 <= c2.lat_list & c2.lat_list <=  90 & ...
        -180 <= c2.lon_list & c2.lon_list <= 180;
  lat_list2 = c2.lat_list(iOK2); 
  lon_list2 = c2.lon_list(iOK2); 
  Tb_list2 = c2.Tb_list(iOK2);

  [latB1, lonB1, gtot1, gavg1] = ...
         equal_area_bins(nLat, dLon, lat_list1, lon_list1, Tb_list1);

  [latB2, lonB2, gtot2, gavg2] = ...
         equal_area_bins(nLat, dLon, lat_list2, lon_list2, Tb_list2);

  tot1 = tot1 + gtot1;
  tot2 = tot2 + gtot2;

  sum1 = sum1 + gavg1 .* gtot1;
  sum2 = sum2 + gavg2 .* gtot2;

  dlist = [dlist, c1.dlist];
  fprintf(1, '.')
end
fprintf(1, '\n')

avg1 = sum1 ./ tot1;
avg2 = sum2 ./ tot2;

cax = [-4, 4];
tstr = 'CrIS J1 minus NPP equal area Tb bins, %d doy %d-%d';
tstr = sprintf(tstr, c1.year, dlist(1), dlist(end));
equal_area_map(1, latB1, lonB1, avg2 - avg1, tstr, cax);

return

tstr = 'CrIS NPP mean equal area Tb bins';
equal_area_map(2, latB1, lonB1, avg1, tstr);

tstr = 'CrIS J1 mean equal area Tb bins';
equal_area_map(3, latB2, lonB2, avg2, tstr);

