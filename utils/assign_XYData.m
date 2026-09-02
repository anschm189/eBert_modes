function [] = assign_XYData(handle, XYData)
%ASSIGN_XYZDATA 

    handle.XData = XYData(1,:);
    handle.YData = XYData(2,:);

end

