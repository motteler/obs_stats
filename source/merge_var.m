%
% merge_var - combine mean and variance from two sets
%
% SYNOPSIS
%   [n3, u3, v3] = merge_var(n1, u1, v1, n2, u2, v2)
%
% INPUTS
%   n1  -  set 1 size
%   u1  -  set 1 mean
%   v1  -  set 1 variance
%   n2  -  set 2 size
%   u2  -  set 2 mean
%   v2  -  set 2 variance
%
% OUTPUTS
%   n3  -  combined size
%   u3  -  combined mean
%   v3  -  combined variance
% 
% DISCUSSION
%   expects and returns variance with Bessel's correction, n/(n-1),
%   the same as matlab var(x,0).  
%
% AUTHOR
%  H. Motteler, 29 Oct 2018
%

function [n3, u3, v3] = merge_var(n1, u1, v1, n2, u2, v2)

% combined obs
n3 = n1 + n2;

% merge E[X1] and E[X2] to get E[X3] 
u3 = u1 .* n1./n3 + u2 .* n2./n3;

% solve for E[X1^2] and E[X2^2], 
% E[X1^2] = var(X1) + E^2[X1], etc.
q1 = ((n1-1)./n1).*v1 + u1.^2;
q2 = ((n2-1)./n2).*v2 + u2.^2;

% merge E[X1^2] and E[X2^2] to get E[X3^2] 
q3 = q1 .* n1./n3 + q2 .* n2./n3;

% var(X3) = E[X3^2] - E^2[X3]
v3 = q3 - u3.^2;
v3 = (n3./(n3-1)).*v3;

