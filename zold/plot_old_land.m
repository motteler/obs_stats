%
% plot_tbinX - show combined results from airs_tbin and cris_tbin
%

addpath tbin_tests

d1 = load('airs_tbinW');
d3 = load('airs_tbinX');
d5 = load('airs_tbinY');
d7 = load('airs_tbinZ');

d2 = load('cris_tbinW');
d4 = load('cris_tbinX');
d6 = load('cris_tbinY');
d8 = load('cris_tbinZ');

tbin_a = d1.tbin + d3.tbin + d5.tbin + d7.tbin;
tbin_c = d2.tbin + d4.tbin + d6.tbin + d8.tbin;
tind = d1.tind;

na = sum(tbin_a)
nc = sum(tbin_c)

figure(1)
subplot(2,1,1)
plot(tind, tbin_a, tind, (na/nc)*tbin_c, 'linewidth', 2)
axis([200, 330, 0, 8e6])
title('obs count by 900 cm-1 temperature bins')
legend('AIRS', 'CrIS', 'location', 'northwest')
grid on

subplot(2,1,2)
plot(tind, ((na/nc)* tbin_c - tbin_a) ./ tbin_a, 'linewidth', 2)
axis([200, 330 -0.05, 0.05])
title('CrIS minus AIRS relative difference')
xlabel('Tb, K')
grid on

