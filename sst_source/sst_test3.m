
% check test differences

ix = [
134413
140688
147874
166578
175543
198230
261282
289253
294382
295176
438478
470244
596794
603614
];

j = 3;

% take values to indices
ilat1 = floor((lat_list(ix(j)) + 90)/0.25) + 1;
ilon1 = floor((lon_list(ix(j)) + 180)/0.25) + 1;

% take values to indices
ilat2 = floor((lat_list(ix(j)) + 90)/0.25) + 1;
ilon2 = floor(mod(lon_list(ix(j)) + 360, 360)/0.25) + 1;
ilon2 = floor(mod(double(lon_list(ix(j))) + 360, 360)/0.25) + 1;

