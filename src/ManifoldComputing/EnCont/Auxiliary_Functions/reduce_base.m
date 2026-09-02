function [H] = reduce_base(x,H)
%REDUCE_BASE For unit vectors in columns x, returns base H of plane orthogonal to x
%   Reduces identity matrix to contain only vectors without components into
%   direction of x, then it uses an SVD on the resulting matrix to return
%   an orthogonal basis.
%   x should be of unit length or of zero length (then it is ignored).
%   Optionally, H can be given as an input, in which case it is used as a
%   base that is reduced further.
n = size(x,1);                                                              % Dimension of space
m = size(x,2);
if ~exist('H','var')
    H = eye(n);
end
dS = 1e-10;                                                                 % Threshold for singular directions

for i = 1:m
    H = H - x(:,i)*(H'*x(:,i))';
end

[H,S] = svd(H);
S = sum(diag(S)>dS);                                                         
H = H(:,1:S);

end
