%
% plot_airs - compare successive AIRS years
%

addpath airs_pdfs

% load annual tabulations
a11 = load('airs902y2011');
a12 = load('airs902y2012');
a13 = load('airs902y2013');
a14 = load('airs902y2014');
a15 = load('airs902y2015');
a16 = load('airs902y2016');

% sum along days
tbin11 = sum(a11.tbin, 2);
tbin12 = sum(a12.tbin, 2);
tbin13 = sum(a13.tbin, 2);
tbin14 = sum(a14.tbin, 2);
tbin15 = sum(a15.tbin, 2);
tbin16 = sum(a16.tbin, 2);

% annual obs counts
n11 = sum(tbin11);
n12 = sum(tbin12);
n13 = sum(tbin13);
n14 = sum(tbin14);
n15 = sum(tbin15);
n16 = sum(tbin16);

% normalize to 2016
tmp11 = (n16/n11)*tbin11;
tmp12 = (n16/n12)*tbin12;
tmp13 = (n16/n13)*tbin13;
tmp14 = (n16/n14)*tbin14;
tmp15 = (n16/n15)*tbin15;
tmp16 = (n16/n16)*tbin16;

% mean normalized counts
tref = mean([tmp11, tmp12, tmp13, tmp14, tmp15, tmp16], 2);

% count diff from mean
dif_11 = tmp11 - tref;
dif_12 = tmp12 - tref;
dif_13 = tmp13 - tref;
dif_14 = tmp14 - tref;
dif_15 = tmp15 - tref;
dif_16 = tmp16 - tref;

rel_11 = (tmp11 - tref) ./ tref;
rel_12 = (tmp12 - tref) ./ tref;
rel_13 = (tmp13 - tref) ./ tref;
rel_14 = (tmp14 - tref) ./ tref;
rel_15 = (tmp15 - tref) ./ tref;
rel_16 = (tmp16 - tref) ./ tref;

% midpoints for Tb bins
tmid = a16.tmid;

figure(1)
subplot(2,1,1)
plot(tmid, tmp11, tmid, tmp12, tmid, tmp13, tmid, tmp14, ...
     tmid, tmp15, tmid, tmp16, 'linewidth', 2)
axis([190, 330, 0, 1.4e7])
title('AIRS obs count by 902 cm-1 Tb bins')
legend('2011', '2012', '2013', '2014', '2015', '2016', ...
       'location', 'northwest')
grid on

subplot(2,1,2)
plot(tmid, rel_11, tmid, rel_12, tmid, rel_13, tmid, rel_14, ...
     tmid, rel_15, tmid, rel_16, 'linewidth', 2)
axis([190, 330, -0.3, 0.3])
title('AIRS relative difference from mean')
legend('2011', '2012', '2013', '2014', '2015', '2016', ...
       'location', 'north')
xlabel('Tb, K')
grid on

return

subplot(2,1,2)
plot(tmid, dif11, tmid, dif12, tmid, dif13, tmid, dif14, ...
     tmid, dif15, tmid, dif16, 'linewidth', 2)
axis([190, 330, -8e5, 8e5])
title('AIRS obs count difference from mean')
legend('2011', '2012', '2013', '2014', '2015', '2016', ...
       'location', 'northwest')
xlabel('Tb, K')
grid on


