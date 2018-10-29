%
% map_test4 - combine equal area Tb maps, CrIS npp and n20 diffs
%

addpath source
addpath map_source
addpath /asl/packages/ccast/motmsc/time
addpath map_data

ctot = 0; csum = 0; 
atot = 0; asum = 0;
dlist = [];

% loop on 16-day sets
year = 2018;
for i = 3 : 8
  a1 = load(sprintf('n20_902y%ds%0.2d.mat', year, i));
  c1 = load(sprintf('npp_902y%ds%0.2d.mat', year, i));

  atot = atot + a1.gtot1;
  ctot = ctot + c1.gtot1;

  asum = asum + a1.gavg1 .* a1.gtot1;
  csum = csum + c1.gavg1 .* c1.gtot1;

  dlist = [dlist, a1.dlist];
end

aavg = asum ./ atot;
cavg = csum ./ ctot;

cax = [-4, 4];
tstr = 'CrIS J1 minus NPP equal area Tb bins, %d doy %d-%d';
tstr = sprintf(tstr, a1.year, dlist(1), dlist(end));
equal_area_map(1, c1.latB1, c1.lonB1, aavg - cavg, tstr, cax);

return

tstr = 'AIRS %d mean equal area Tb bins';
tstr = sprintf(tstr, a1.year);
equal_area_map(2, a1.latB1, a1.lonB1, aavg, tstr);

tstr = 'CrIS %d mean equal area Tb bins';
tstr = sprintf(tstr, c1.year);
equal_area_map(3, c1.latB1, c1.lonB1, cavg, tstr);

