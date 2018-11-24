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

% plot(T(1,:), R, 'linewidth', 2)
semilogy(T(1,:), R, 'linewidth', 2)
axis([180, 320, 1e-4, 2e2])
title('radiance as a function of temperature')
legend('500 cm-1', '1000 cm-1', '1500 cm-1', '2000 cm-1', ...
       '2500 cm-1', '3000 cm-1', 'location', 'southeast')
xlabel('temperature (K)')
ylabel('radiance (mw/sr-1/m-2)')
grid on


