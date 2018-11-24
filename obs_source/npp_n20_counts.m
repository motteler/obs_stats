%
% npp_n20_cnt_map - compare NPP and N20 equal area obs counts
%

addpath ../source
addpath /asl/packages/ccast/motmsc/utils
% addpath ../obs_16day_mix_v1
addpath ../obs_16day_cris_c4

% set size table
a = [];

% loop on 16-day sets
year = 2018;
% for i = [5:7 10:19]
for i = 5 : 19
  c1 = load(sprintf('NPP_c04y%ds%0.2d.mat', year, i));
  c2 = load(sprintf('N20_c04y%ds%0.2d.mat', year, i));
  n1 = length(c1.lat_list);
  n2 = length(c2.lat_list);
  a = [a; [i, n1, n2]];
  fprintf(1, '%2d  %8d  %8d\n', i, n1, n2)
end

% find the most complete sets
ix = find(a(:,2) > 30718000 & a(:,3) > 30718000);
a(ix, 1)

ix = find(a(:,2) > 30717000 & a(:,3) > 30717000);
a(ix, 1)

