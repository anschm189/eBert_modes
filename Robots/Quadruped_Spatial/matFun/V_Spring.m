
function pot = V_Spring(q)
%V_SPRING

global K xb0

b_Htm_o = [o_Htm_BASE_fcn(q); 0 0 0 1]^-1;
pot = Ux_fcn(b_Htm_o(1:3,:), K, xb0);