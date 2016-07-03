function [ statues ] = checkDir(path)
if (~exist(path))
    statues = 0;
    mkdir(path);
end
statues = 1;
end

