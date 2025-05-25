function [shape_index] = read_grid(shape_path,column_num)

% read_shape pts
n_vertices = 21;
col_max = 10;
fid = fopen(shape_path);
tline = fgetl(fid);
start = 1;
while ~strcmp(tline, '{')
    start = start + 1;
    tline = fgetl(fid);
end
fclose(fid);

% read shape


%shape =  dlmread(shape_path, ' ', [start 0 start+n_vertices-1 col_max]);

shape_index =  dlmread(shape_path, ' ', [start column_num-1 start+n_vertices-1 column_num-1]);

