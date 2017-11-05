%
% merge_airs -- concatenate AIRS qunitile to annual PDFs
%

addpath airs_pdfs
addpath airs_pdfs/quintiles
addpath /asl/packages/ccast/motmsc/time

for year = 2016 : 2016

  d1 = load(sprintf('airs902y%dq1', year));
  d2 = load(sprintf('airs902y%dq2', year));
  d3 = load(sprintf('airs902y%dq3', year));
  d4 = load(sprintf('airs902y%dq4', year));
  d5 = load(sprintf('airs902y%dq5', year));
  
  d0 = d1;
  d0.tbin = [d1.tbin, d2.tbin, d3.tbin, d4.tbin, d5.tbin];
  d0.dlist = [d1.dlist, d2.dlist, d3.dlist, d4.dlist, d5.dlist];
  
  if ~isequal(year, d0.year) 
    error('year %d does not match tabulated value %d', year, d0.year)
  end

  if isleap(year), ndays = 366; else, ndays = 365; end

  if ~isequal(1:ndays, d0.dlist), 
    fprintf(1, 'merge_airs: year %d short day list\n', year)
  end
  
  save(sprintf('airs902y%d', year), '-struct', 'd0');
end

