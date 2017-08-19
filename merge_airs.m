%
% merge_airs -- concatenate AIRS qunitile to annual PDFs
%

addpath airs_pdfs
addpath /asl/packages/ccast/motmsc/time

for year = 2008 : 2016

  d1 = load(sprintf('airs902y%dq1', year));
  d2 = load(sprintf('airs902y%dq2', year));
  d3 = load(sprintf('airs902y%dq3', year));
  d4 = load(sprintf('airs902y%dq4', year));
  d5 = load(sprintf('airs902y%dq5', year));
  
  d0 = d1;
  d0.tbin = [d1.tbin, d2.tbin, d3.tbin, d4.tbin, d5.tbin];
  d0.dlist = [d1.dlist, d2.dlist, d3.dlist, d4.dlist, d5.dlist];
  
  if ~isequal(year, d0.year), error('bad year spec'), end
  if ~isleap(year) || year == 2016 ndays = 365; else, ndays = 366; end
  if ~isequal(1:ndays, d0.dlist), error('bad day list'), end
  
  save(sprintf('airs902y%d', year), '-struct', 'd0');

end

