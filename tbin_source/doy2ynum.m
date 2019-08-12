
function ynum = doy2ynum(year, doy)

if numel(year) ~= 1
  error('year must be scalar, doy can be vector')
end

if ~isleap(year) 
  ylen = 365; 
else, 
  ylen = 366; 
end

ynum = year + doy / ylen;

