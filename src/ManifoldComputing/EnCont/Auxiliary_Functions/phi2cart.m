function Y = phi2cart(X)
% Compute the cartesian coordinates of the unit hypersphere
% from the input hypersphere angles.
%
% See https://en.wikipedia.org/wiki/N-sphere#Spherical_coordinates for more
% details.

% n = number of column vectors
n = size(X,2);

% cosine terms
C = [cos(X); ones(1,n)];
% sine terms
S = [ones(1,n); cumprod(sin(X),1)];
% calculate output
Y = C .* S;
