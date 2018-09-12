%
% plot_tai_cris - CrIS NPP and J1 obs stats
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

c1 = load('NPP_902y2018s06.mat');
c2 = load('N20_902y2018s06.mat');

% asc/dec or other subsetting
% note asc = 1 is night, asc = 0 is day
% so asc is night, and ~asc is day
ix1 = ~logical(c1.asc_list);
ix2 = ~logical(c2.asc_list);
lat_list1 = c1.lat_list(ix1); 
lon_list1 = c1.lon_list(ix1); 
tai_list1 = c1.tai_list(ix1);
sol_list1 = c1.sol_list(ix1);
lat_list2 = c2.lat_list(ix2); 
lon_list2 = c2.lon_list(ix2); 
tai_list2 = c2.tai_list(ix2);
sol_list2 = c2.sol_list(ix2);

mean(sol_list1)

tbase = mean([tai_list1; tai_list2]);
datestr(tai2dnum(tbase))

t1 = (tai_list1 - tbase) / (60 * 60 * 24);
t2 = (tai_list2 - tbase) / (60 * 60 * 24);

[latB1, lonB1, M1, W1, N1] = ...
  equal_area_var(nLat, dLon, lat_list1, lon_list1, t1, M1, W1, N1);

[latB2, lonB2, M2, W2, N2] = ...
  equal_area_var(nLat, dLon, lat_list2, lon_list2, t2, M2, W2, N2);

S1 = sqrt(W1 ./ (N1 - 1));
S2 = sqrt(W2 ./ (N2 - 1));

tstr = 'CrIS NPP mean equal area time vs midpt';
equal_area_map(1, latB1, lonB1, M1, tstr);

tstr = 'CrIS NPP std dev equal area time vs midpt';
equal_area_map(2, latB1, lonB1, S1, tstr);

tstr = 'CrIS J1 minus NPP mean equal area time diffs';
equal_area_map(3, latB1, lonB1, M2 - M1, tstr);

tstr = 'CrIS J1 minus NPP std dev equal area time diffs';
equal_area_map(4, latB1, lonB1, S2 - S1, tstr);

