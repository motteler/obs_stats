
% test with matlab mean

% load /home/motteler/shome/obs_stats/obs_16day_airs_c3/airs_c03y2018s10.mat
load /home/motteler/shome/obs_stats/obs_16day_airs_c3/airs_c03y2012s14.mat
% rad_list = double(rad_list);
bt_mean1 = rad2bt(vlist, mean(rad_list, 2));  % rad mean to BT
bt_mean2 = mean(rad2bt(vlist, rad_list), 2);  % rad to BT, BT mean
format bank
real([vlist, bt_mean1, bt_mean2, bt_mean1 - bt_mean2])
%  frequency       mean1         mean2      mean1 - mean2
format short
min(rad_list, [], 2)

% test with rec_var (function for running mean and variance)
addpath /home/motteler/cris/ccast/motmsc/utils
load /home/motteler/shome/obs_stats/obs_16day_airs_c3/airs_c03y2012s14.mat
[nchan, nobs] = size(rad_list);

u = zeros(nchan,1); m = u; n = u;
tic
for i = 1 : nobs
 [u, m, n] = rec_var(u, m, n, rad_list(:, i));
end
toc
bt_mean1 = rad2bt(vlist, u);

bt_list = rad2bt(vlist, rad_list);
u = zeros(nchan,1); m = u; n = u;
tic
for i = 1 : nobs
 [u, m, n] = rec_var(u, m, n, bt_list(:, i));
end
toc
bt_mean2 = u;

format bank
real([vlist, bt_mean1, bt_mean2])
format short

