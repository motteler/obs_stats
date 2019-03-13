
addpath ../source
addpath /asl/packages/ccast/motmsc/utils
addpath ../obs_16day_cris_c4

slist = 15;               % most complete set
% slist = [6 10 12 14 15];  % relatively complete sets
year = 2018;

rad_list1 = []; rad_list2 = [];
fov_list1 = []; fov_list2 = [];

% loop on 16-day sets
for i = slist
  c1 = load(sprintf('NPP_c04y%ds%0.2d.mat', year, i));
  c2 = load(sprintf('N20_c04y%ds%0.2d.mat', year, i));

  rad_list1 = cat(2, rad_list1, c1.rad_list);
  rad_list2 = cat(2, rad_list2, c2.rad_list);

  fov_list1 = cat(1, fov_list1, c1.fov_list);
  fov_list2 = cat(1, fov_list2, c2.fov_list);

  fprintf(1, '.')
end
fprintf(1, '\n')

vlist = c1.vlist;
% clear c1 c2

bt_list1 = rad2bt(vlist, double(rad_list1));
bt_list2 = rad2bt(vlist, double(rad_list2));

mean_all = mean(bt_list2, 2);
fov_mean = zeros(6, 9);
mean_diff = zeros(6, 9);
std_diff = zeros(6, 9);

for i = 1 : 9
  jx = find(fov_list2 == i);
  fov_mean(:, i) = mean(bt_list2(:, jx), 2);
  fov_diff = bt_list2(:, jx) - mean_all;
  mean_diff(:, i) = mean(fov_diff, 2);
  std_diff(:, i) = std(fov_diff, 0, 2);
end

dtmp = fov_mean - mean_all;
rms(mean_diff(:) - dtmp(:)) / rms(dtmp(:))

mean_diff'
std_diff'
vlist

