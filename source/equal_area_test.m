%
% equal_area_test - compare equal area binning functions
% 

addpath ../source
addpath ../obs_16day_airs_c3
addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/utils

nLat = 24;  dLon = 4;

dlist = [];
total_obs = 0;
M1 = []; W1= []; N1 = [];

% loop on years
% for year = 2003 : 2017
for year = 2016

  % loop on 16-day sets
% for i = 1 : 23
  for i = 10

    % load the next 16-day set
    afile = sprintf('airs_c03y%ds%0.2d.mat', year, i);
    if exist(afile) == 2
      c1 = load(afile);
      if isempty(c1.rad_list)
        fprintf(1, 'empty file %s\n', afile)
        continue
      end
    else
      fprintf(1, 'missing %s\n', afile)
      continue
    end

    % convert rad to BT
    bt_list = real(rad2bt(c1.vlist, c1.rad_list));

    % test input subset
    ix = 3;
    bt_test = squeeze(bt_list(ix,:,:));

%   % old equal area bins
%   [latB, lonB, gtotX, gavgX] = ...
%      equal_area_binsX(nLat, dLon, c1.lat_list, c1.lon_list, bt_test);

    % new equal area bins
    [latB, lonB, gtot, gavg, gvar] = ...
       equal_area_bins(nLat, dLon, c1.lat_list, c1.lon_list, bt_test);
%   gavg2 = squeeze(gavg2(ix,:,:));
%   gvar2 = squeeze(gvar2(ix,:,:));

    % multi-call recursive variance
    [latB, lonB, M1, W1, N1] = ...
       equal_area_var(nLat, dLon, c1.lat_list, c1.lon_list, ...
                      bt_test, M1, W1, N1);
    V1 = W1 ./ (N1 - 1);

%   % small, nonzero
%   rms(gavgX(:) - gavg(:)) / rms(gavg(:))

    % should be zero
    rms(N1(:) - gtot(:))
    rms(M1(:) - gavg(:)) / rms(gavg(:))
    rms(V1(:) - gvar(:)) / rms(gvar(:))

  end
end

