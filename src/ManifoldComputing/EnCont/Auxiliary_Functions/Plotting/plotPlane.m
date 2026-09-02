function [h] = plotPlane(H,x,i,j,fig)
%PLOTPLANE plots plane or line specified by columns of H at position x
%   The size of the plane is scaled by the lengths of the vectors in H.
%   Returns line handle h for plane/ line. j-i+1 should be either 2 or 3.

nPlot = j - i + 1;

if nPlot == 2                                                               % Case 1: Plot Line
    Lx = x(i)+[H(1),-H(1)]/4;                                               % Division by 4 to make this smaller
    Ly = x(j)+[H(2),-H(2)]/4;
    hold(fig,'on');
    h = plot(fig,Lx,Ly,'red','DisplayName','Potential','Linewidth',1);
    hold(fig,'off');
elseif nPlot == 3                                                           % Case 2: Plot Plane
    L = x(i:j) + [H(:,1)+H(:,2),-H(:,1)+H(:,2),-H(:,1)-H(:,2),H(:,1)-H(:,2)]/4;
    hold(fig,'on');
    h = patch(fig,L(1,:),L(2,:),L(3,:),'red','DisplayName','Potential'); 
    hold(fig,'off');
end

end


