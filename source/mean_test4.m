%
% mean_test4 - another comparison of radiance and temperature means
%
% This test demonstrates how given a set of radiances and
% paired brightness temperatures (1) the radiance mean is warmer
% than the temperature mean, (2) the distance of the radiance mean
% from radiances is less than the distance of the temperature mean
% from radiances, and (3) the distance of the temperature mean from
% temperatures is less than the distance of the radiance mean from
% temperatures.

v = 902;   % Planck frequency
t1 = 220;  % test temp 1
t2 = 300;  % test temp 2

r1 = bt2rad(v, t1);  % test rad 1
r2 = bt2rad(v, t2);  % test rad 2

tt_mean = mean([t1, t2]);      % mean temp as temp
rt_mean = bt2rad(v, tt_mean);  % mean temp as rad

rr_mean = mean([r1, r2]);      % mean rad as rad
tr_mean = rad2bt(v, rr_mean);  % mean rad as temp

% compare temperature and radiance means as temperatures
% and as radiances.  In both cases temp mean < rad mean.
[tt_mean, tr_mean]
[rt_mean, rr_mean]

% distance of radiance mean from radiances
sqrt((r1 - rr_mean)^2 + (r2 - rr_mean)^2)

% distance of temperature mean from radiances
sqrt((r1 - rt_mean)^2 + (r2 - rt_mean)^2)

% distance of temperature mean from temperatures
sqrt((t1 - tt_mean)^2 + (t2 - tt_mean)^2)

% distance of radiance mean from temperatures
sqrt((t1 - tr_mean)^2 + (t2 - tr_mean)^2)

