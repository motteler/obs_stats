%
% compare large SP and DP matlab means with SP rec_var
%
% uses 30M 16-day radiance obs list, compares both BT and 
% radiance means
%

addpath /home/motteler/cris/ccast/motmsc/utils

% load /home/motteler/shome/obs_stats/obs_16day_airs_c3/airs_c03y2018s10.mat
  load /home/motteler/shome/obs_stats/obs_16day_airs_c3/airs_c03y2012s14.mat

[nchan, nobs] = size(rad_list);

% sp matlab rad mean
rm1sp = mean(rad_list, 2);   

% dp matlab rad mean
rm1dp = mean(double(rad_list), 2);   

% sp rad recursive var
u = zeros(nchan,1); m = u; n = u;
tic
for i = 1 : nobs
 [u, m, n] = rec_var(u, m, n, rad_list(:, i));
end
toc
rm2sp = u;

format bank
[vlist, rad2bt(vlist,rm1sp), rad2bt(vlist,rm2sp), rad2bt(vlist,rm1dp)]
format short

% sp matlab BT mean
bt_list = rad2bt(vlist, rad_list);

% sp matlab rad mean
bm1sp = mean(bt_list, 2);   

% dp matlab rad mean
bm1dp = mean(double(bt_list), 2);   

% sp BT recursive var
u = zeros(nchan,1); m = u; n = u;
tic
for i = 1 : nobs
 [u, m, n] = rec_var(u, m, n, bt_list(:, i));
end
toc
bm2sp = u;

format bank
[vlist, bm1sp, bm2sp, bm1dp]
format short
