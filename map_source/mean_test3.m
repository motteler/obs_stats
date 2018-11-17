%
% simple demo of radiance vs BT means
%

% source for rad2bt, bt2rad
addpath /asl/packages/ccast/source

% frequency points
v = 500 : 500 : 3000;

% temperature scale
T = 180 : 320;

% mean temperature
mean(T)

% radiance at v
T = ones(length(v), 1) * T;
R = bt2rad(v, T);

% radiance mean
Rmean = mean(R, 2);

% radiance mean as BT
Rbt = rad2bt(v, Rmean);

% show v and radiance mean
format bank
[v', Rbt]
format short


