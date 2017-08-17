%
% plot_tbin3 - compare successive AIRS years
%

addpath airs_pdfs

a1 = load('airs902y2016q1');
a2 = load('airs902y2016q2');
a3 = load('airs902y2016q3');
a4 = load('airs902y2016q4');
a5 = load('airs902y2016q5');

b1 = load('airs902y2015q1');
b2 = load('airs902y2015q2');
b3 = load('airs902y2015q3');
b4 = load('airs902y2015q4');
b5 = load('airs902y2015q5');

c1 = load('airs902y2014q1');
c2 = load('airs902y2014q2');
c3 = load('airs902y2014q3');
c4 = load('airs902y2014q4');
c5 = load('airs902y2014q5');

tbin_a = [a1.tbin, a2.tbin, a3.tbin, a4.tbin, a5.tbin];
tbin_b = [b1.tbin, b2.tbin, b3.tbin, b4.tbin, b5.tbin];
tbin_c = [c1.tbin, c2.tbin, c3.tbin, c4.tbin, c5.tbin];

% sum along days
tbin_a = sum(tbin_a, 2);
tbin_b = sum(tbin_b, 2);
tbin_c = sum(tbin_c, 2);

na = sum(tbin_a)
nb = sum(tbin_b)
nc = sum(tbin_c)
tmid = a1.tmid;

figure(1)
subplot(2,1,1)
tmp_b = (na/nb)*tbin_b;
tmp_c = (na/nc)*tbin_c;

plot(tmid, tbin_a, tmid, tmp_b,  tmid, tmp_c, 'linewidth', 2)
axis([190, 330, 0, 1.4e7])
title('AIRS obs count by 900 cm-1 temperature bins')
legend('2016', '2015', '2014', 'location', 'northwest')
grid on

subplot(2,1,2)
plot(tmid, (tbin_a - tmp_c) ./ tmp_c, 'linewidth', 2)
axis([190, 330,-0.1, 0.1])
title('2016 minus 2014 AIRS relative difference')
xlabel('Tb, K')
grid on

