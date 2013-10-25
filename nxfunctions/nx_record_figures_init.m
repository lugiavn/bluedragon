function data = nx_record_figures_init(FPS, filename_prefix)
%RECORD_FIGURES_INIT Summary of this function goes here
%   Detailed explanation goes here

    data            = struct;
    data.path       = './';
    data.name       = filename_prefix;
    data.framerate  = FPS;
end

