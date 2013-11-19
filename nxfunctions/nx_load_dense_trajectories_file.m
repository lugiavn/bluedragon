function v = nx_load_dense_trajectories_file( file_path )
%LOAD_DENSE_TRAJECTORIES Summary of this function goes here
%   Detailed explanation goes here


data = dlmread(file_path);

assert(size(data, 2) == 433);

v    = struct;

v.L   = 15;
v.nxy = 2;
v.nt  = 3;

for i=1:size(data,1)
    
    v(i).L   = 15;
    v(i).nxy = 2;
    v(i).nt  = 3;

    
    v(i).trajectory.last_frame = data(i,1);
    v(i).trajectory.mean       = [data(i,2) data(i,3)];
    v(i).trajectory.var        = [data(i,4) data(i,5)];
    v(i).trajectory.length     = data(i,6);
    v(i).trajectory.scale      = data(i,7);

    j                          = 8;

    v(i).trajectory_d          = data(i,j:j+30-1);  j = j + 30;
    v(i).HOG                   = data(i,j:j+96-1);  j = j + 96;
    v(i).HOF                   = data(i,j:j+108-1); j = j + 108;
    v(i).MBHx                  = data(i,j:j+96-1);  j = j + 96;
    v(i).MBHy                  = data(i,j:j+96-1);  j = j + 96;

end



end

