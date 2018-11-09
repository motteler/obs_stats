%
% map_test3 - combine equal area Tb maps, double difference
%

addpath source
addpath map_data
addpath /asl/packages/ccast/motmsc/time

year = 2016;
ctot = 0; csum = 0; 
atot = 0; asum = 0;

% loop on 16-day sets
for i = 1 : 23
  a1 = load(sprintf('airs902y%ds%0.2d.mat', year, i));
  c1 = load(sprintf('cris902y%ds%0.2d.mat', year, i));

  atot = atot + a1.gtot1;
  ctot = ctot + c1.gtot1;

  asum = asum + a1.gavg1 .* a1.gtot1;
  csum = csum + c1.gavg1 .* c1.gtot1;

end

aavg1 = asum ./ atot;
cavg1 = csum ./ ctot;

year = 2017;
ctot = 0; csum = 0; 
atot = 0; asum = 0;

% loop on 16-day sets
for i = 1 : 23
  a1 = load(sprintf('airs902y%ds%0.2d.mat', year, i));
  c1 = load(sprintf('cris902y%ds%0.2d.mat', year, i));

  atot = atot + a1.gtot1;
  ctot = ctot + c1.gtot1;

  asum = asum + a1.gavg1 .* a1.gtot1;
  csum = csum + c1.gavg1 .* c1.gtot1;

end

aavg2 = asum ./ atot;
cavg2 = csum ./ ctot;

ddif = (aavg2 - cavg2) - (aavg1 - cavg1);

tstr = '(AIRS - CrIS (2017)) - (AIRS - CrIS (2016))';
equal_area_map(3, c1.latB1, c1.lonB1, ddif, tstr);

