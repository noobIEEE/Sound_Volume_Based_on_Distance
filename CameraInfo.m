function [camera_name, camera_id, resolution] = CameraInfo(device)
camera_name = char(device.InstalledAdaptors(end));
camera_info = imaqhwinfo(camera_name);
camera_id = camera_info.DeviceInfo.DeviceID(end);
resolution = char(camera_info.DeviceInfo.SupportedFormats(end));