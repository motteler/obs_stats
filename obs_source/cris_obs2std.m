%
% cris_obs2std - per-channel mean and std from obs lists
%

addpath ../source
addpath ../map_source
addpath /asl/packages/ccast/motmsc/utils
% addpath ../obs_16day_mix_v1
% addpath ../obs_16day_cris_c4

% loop on 16-day sets
dlist = [];
year = 2018;
slist = 5 : 20;
nset = length(slist);
for i = 1 : nset
% c1 = load(sprintf('NPP_c06y%ds%0.2d.mat', year, slist(i)));
  c1 = load(sprintf('N20_c06y%ds%0.2d.mat', year, slist(i)));

  dlist = [dlist, c1.dlist];
  rtmp = double(c1.rad_list);
  [nchan, nobs] = size(rtmp);

  if i == 1
    ntab = zeros(nchan, 9, nset);
    utab = ntab; vtab = ntab;
  end

  for j = 1 : 9
    ix = find(c1.fov_list == j);
    ntab(:, j, i) = ones(nchan,1) * length(ix);
    utab(:, j, i) = mean(rtmp(:,ix), 2);
    vtab(:, j, i) = var(rtmp(:,ix), 0, 2);
  end
  fprintf(1, '.');
end
fprintf(1, '\n');

[n2, u2, v2] = merge_tree(ntab, utab, vtab);
s2 = sqrt(v2);

figure(1); clf
plot(1:9, s2 - mean(s2,2))
title('FOV std diff from std mean')
legend('chan 1', 'chan 2', 'chan 3', 'chan 4', 'chan 5', ...
       'chan 6', 'chan 7', 'location', 'northeast')
ylabel('mw sr-1 m-2')
xlabel('FOV index')
grid on

