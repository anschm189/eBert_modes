function du = EoM(u, T)
% u
M_ = M(u(1:end/2));
C_ = C(u);
g_ = g(u(1:end/2));
pot = spring(u(1:end/2));

M_ddq = -C_*u(end/2+1:end) - g_ - pot;
ddq = M_ \ M_ddq;

du = T * [u(end/2+1:end); ddq];
% du
end
