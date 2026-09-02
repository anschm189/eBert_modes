function phi = cart2phi(x)
%
% This function extracts the orientation of a vector x with base in the
% origin.
%
% x can be a matrix, in which case the operation is applied column-wise
%
DoF = size(x,1);
phi = zeros(DoF-1,size(x,2));
for i_col = 1:size(x,2)
    for i_DoF = 1:(DoF - 1)
        phi(i_DoF,i_col) = acos(x(i_DoF,i_col)/norm(x(i_DoF:DoF,i_col),2));
    end
    if x(end,i_col) < 0
        phi(end) = 2*pi - phi(end,i_col);
    end
    phi = mod(phi + pi,2*pi) - pi;
end

end