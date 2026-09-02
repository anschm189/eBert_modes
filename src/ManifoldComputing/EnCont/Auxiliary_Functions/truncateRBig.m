function [RBig_truncated] = truncateRBig(RBig,Gen,EAbs)
%TRUNCATERBIG Returns version of RBig in which generator Gen is truncated 
%   The generator is truncated to those results that hold for pseudo-energies
%   below EAbs
EAbs_Gen = RBig{Gen,3};
Ind = find(EAbs_Gen <= EAbs);
Ind = Ind(end);
RBig_truncated = RBig;
RBig_truncated{Gen,1} = RBig{Gen,1}(1:Ind,:);
RBig_truncated{Gen,2} = RBig{Gen,2}(1:Ind);
RBig_truncated{Gen,3} = RBig{Gen,3}(1:Ind);
end
