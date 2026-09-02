function [cart] = spherical_to_cart_coord(sc)
%SPHERICAL_COORD Summary of this function goes here
%   Detailed explanation goes here

r=sc(1);
theta=sc(2);
phi=sc(3);

cart(1,1) = r*cos(phi)*sin(theta);
cart(2,1) = r*sin(phi)*sin(theta);
cart(3,1) = r*cos(theta);

end

