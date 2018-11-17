%
% test merge_var
%

% define two sets
n1 = 1e5; 
n2 = 2e5;
x1 = randn(n1, 1);
x2 = randn(n2, 1);

% take the means
u1 = mean(x1);
u2 = mean(x2);
u3 = mean([x1;x2]);

% take the variance
m = 0;
v1 = var(x1,m);
v2 = var(x2,m);
v3 = var([x1;x2],m);

% get the merged mean and variance
[n3x, u3x, v3x] = merge_var(n1, u1, v1, n2, u2, v2);

% check the results
(u3x - u3) / u3
(v3x - v3) / v3

