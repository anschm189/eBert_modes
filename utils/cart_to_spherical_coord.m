function [sc] = cart_to_spherical_coord(cart)
%SPHERICAL_COORD Summary of this function goes here
%   Detailed explanation goes here

% ONLY VALID FOR x>0 !!!

x=cart(1);
y=cart(2);
z=cart(3);

sc(1,1) = sqrt(x^2 + y^2 + z^2); % r
sc(2,1) = acos(z/sc(1)); % theta
sc(3,1) = atan(y/x); % !! % phi
sc(4,1) = atan(z/x);

end

