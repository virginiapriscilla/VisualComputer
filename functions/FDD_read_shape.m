function [shape] = FDD_read_shape(shape_path,col_max)

if nargin < 2
    col_max = 1;
end

% read_shape pts
fid = fopen(shape_path);
tline = fgetl(fid);
start = 1;
while ~strcmp(tline, '{')
    start = start + 1;
    tline = fgetl(fid);
    tline_array =split(tline,":");
    tline_key = cell2mat(strip(tline_array(1)));
    if (contains(tline_key,'n_points'));
        n_vertices = str2num(cell2mat(strip(tline_array(2))));
    end
end
fclose(fid);

% read shape
%[start 0 start+n_vertices-1 col_max]
shape =  dlmread(shape_path, ' ', [start 0 start+n_vertices-1 col_max]);

