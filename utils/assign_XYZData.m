function [] = assign_XYZData(handle, XYZData)
%ASSIGN_XYZDATA 

    handle.XData = XYZData(1,:);
    handle.YData = XYZData(2,:);
    handle.ZData = XYZData(3,:);

end

