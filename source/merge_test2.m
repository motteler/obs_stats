%
% test merge_var
%

% test data
nchan = 7; 
nlat = 48; 
nlon = 90; 
k1 = 100;
k2 = 500;
x1 = randn([nchan,nlat,nlon,k1]) * 20 + 200;
x2 = randn([nchan,nlat,nlon,k2]) * 20 + 200;
x3 = cat(4,x1,x2);
n1 = ones(nchan,nlat,nlon) * k1;
n2 = ones(nchan,nlat,nlon) * k2;

% take the means
u1 = mean(x1,4);
u2 = mean(x2,4);
u3 = mean(x3,4);

% take the variance
m = 0;
v1 = var(x1,m,4);
v2 = var(x2,m,4);
v3 = var(x3,m,4);

% get the merged mean and variance
[n3x, u3x, v3x] = merge_var(n1, u1, v1, n2, u2, v2);

% check the results
rms(u3x(:) - u3(:)) / rms(u3(:))
rms(v3x(:) - v3(:)) / rms(v3(:))

