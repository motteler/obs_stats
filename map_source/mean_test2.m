
% basic comparison of rad and BT means

addpath /asl/packages/ccast/source

  load /home/motteler/shome/obs_stats/obs_16day_airs_c3/airs_c03y2018s10.mat
% load /home/motteler/shome/obs_stats/obs_16day_airs_c3/airs_c03y2012s14.mat

rad_list = double(rad_list);
rad_mean = rad2bt(vlist, mean(rad_list, 2));  % rad mean to BT
bt_mean = mean(rad2bt(vlist, rad_list), 2);  % rad to BT, BT mean
format bank
real([vlist, rad_mean, bt_mean, rad_mean - bt_mean])
format short
min(rad_list, [], 2)

