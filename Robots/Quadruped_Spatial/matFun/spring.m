
function spring = spring(q)
%SPRING
%    SPRING = SPRING(IN1)

global K xb0
b_Htm_o = [o_Htm_BASE_fcn(q); 0 0 0 1]^-1;
spring = p_J_q_fcn(q).' * dUdp_fcn(b_Htm_o(1:3,:), K, xb0);