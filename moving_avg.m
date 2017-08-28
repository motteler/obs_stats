
function [b, ib] = moving_avg(a, k)

[m, n] = size(a);
b = zeros(m, n - 2*k);
ib = k + 1 : n - k;

for i = ib
  b(:, i - k) = mean(a(:, i - k : i + k), 2);
end

% use subrange at domain edges
% function b = moving_avg(a, k)
% [m, n] = size(a);
% b = zeros(m, n);
% for i = 1 : n
%   j = max(1, i-k) : min(i+k, n);
%   b(:, i) = mean(a(:,j), 2);
% end

