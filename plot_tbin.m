%
% plot_tbin - show results from airs_tbin and cris_tbin
%

addpath airs_pdfs
addpath cris_pdfs

a1 = load('airs902y2016q1');
a2 = load('airs902y2016q2');
a3 = load('airs902y2016q3');
a4 = load('airs902y2016q4');
a5 = load('airs902y2016q5');

c1 = load('cris902y2016q1');
c2 = load('cris902y2016q2');
c3 = load('cris902y2016q3');
c4 = load('cris902y2016q4');
c5 = load('cris902y2016q5');

tbin_a = [a1.tbin, a2.tbin, a3.tbin, a4.tbin, a5.tbin];
tbin_c = [c1.tbin, c2.tbin, c3.tbin, c4.tbin, c5.tbin];

% sum along days
tbin_a = sum(tbin_a, 2);
tbin_c = sum(tbin_c, 2);

na = sum(tbin_a)
nc = sum(tbin_c)
tmid = a1.tmid;

figure(1)
subplot(2,1,1)
  plot(tmid, tbin_a, tmid, (na/nc)*tbin_c, 'linewidth', 2)
% plot(tmid, tbin_a, tmid, tbin_c, 'linewidth', 2)
  axis([190, 330, 0, 1.4e7])
% axis([200, 305, 0, 4e5])
  title('obs count by 900 cm-1 temperature bins')
% title('obs count by SW cm-1 temperature bins')
legend('AIRS', 'CrIS', 'location', 'northwest')
grid on

subplot(2,1,2)
  plot(tmid, ((na/nc)* tbin_c - tbin_a) ./ tbin_a, 'linewidth', 2)
% plot(tmid, (tbin_c - tbin_a) ./ tbin_a, 'linewidth', 2)
  axis([190, 330,-0.05, 0.05])
% axis([200, 305 -0.1, 0.4])
title('CrIS minus AIRS relative difference')
xlabel('Tb, K')
grid on

