%
% NAME
%   merge_tree - combine mean and variance from a list
%
% SYNOPSIS
%   [n2, u2, v2] = merge_tree(n1, u1, v1)
%
% INPUTS
%   n1  -  input size
%   u1  -  input mean
%   v1  -  input variance
%
% OUTPUTS
%   n2  -  combined size
%   u2  -  combined mean
%   v2  -  combined variance
% 
% DISCUSSION
%   sizes of the input arrays much match.  Reduction is along
%   the last dimension.  Actual merges are done by merge_var.
%
%   expects and returns variance with Bessel's correction, n/(n-1),
%   the same as matlab var(x,0).  
%
% AUTHOR
%  H. Motteler, 22 Nov 2018
%

function [n1, u1, v1] = merge_tree(n1, u1, v1)

k = size(n1);
if ~(isequal(k,size(u1)) & isequal(k,size(v1)))
  error('input arrays must all be the same shape')
end

out_shape = k(1:end-1);
if length(out_shape) == 1
  out_shape = [out_shape, 1];
end
nrow = prod(out_shape);
ncol = k(end);

n1 = reshape(n1, nrow, ncol);
u1 = reshape(u1, nrow, ncol);
v1 = reshape(v1, nrow, ncol);

% m = input('m > ');
% a = rand(m,1) * 100;
% b = sum(a);

m = ncol;

while m > 1
  n = floor((m-1)/2)+1;
  for i = 1 : n
    j1 = 2*i - 1; 
    j2 = 2*i;
    if 2*i-1 == m
%     [m, n, i, 2*i-1]
%     a(i) = a(2*i-1);
      n1(:,i) = n1(:,j1);
      u1(:,i) = u1(:,j1); 
      v1(:,i) = v1(:,j1);
    else
%     [m, n, i, 2*i-1, 2*i]
%     a(i) = a(2*i-1) + a(2*i);
      [n1(:,i), u1(:,i), v1(:,i)] = ...
         merge_var(n1(:,j1), u1(:,j1), v1(:,j1),...
                   n1(:,j2), u1(:,j2), v1(:,j2));
    end
  end
  m = n;
end

n1 = reshape(n1(:,1), out_shape);
u1 = reshape(u1(:,1), out_shape);
v1 = reshape(v1(:,1), out_shape);

