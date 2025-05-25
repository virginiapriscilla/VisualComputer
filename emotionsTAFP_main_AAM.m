% EMOTION DETECTION TAFTP MAIN
% ---------------------------------------------------------------------
% Programmed by     :       D. V. Shobhana Priscilla
% Guided by         :       Dr. P. Vanaja Ranjan
% Initial Version   :       Oct 27, 2024
% Revised Version   :       May 20, 2025
% ---------------------------------------------------------------------

clear; clc; close all;
addpath functions

%% Train
% should you change any of the parameters below, set flag_train = 1;
flag_train = 1;
where = '.';
folder = 'trainset';
what = 'png';
AAM.num_of_points = 68;

AAM.scales = [1 2];
AAM.shape.max_n = 136;
num_of_scales = length(AAM.scales);
AAM.texture = cell(1, num_of_scales);
for ii = 1:num_of_scales
    AAM.texture{ii}.max_m = 550;
    %AAM.texture{ii}.max_m = 25;
end

% Create the AAM
if flag_train
    AAM = train_AAM(where, folder, what, AAM);
    save([where '/' folder '/AAM.mat'], 'AAM');
end


flag_precompute = 1;
if flag_train
    flag_precompute = 1;
end
cAAM.shape{1}.n = 10;
cAAM.shape{2}.n = 3;
cAAM.shape{1}.num_of_similarity_eigs = 4;
cAAM.shape{2}.num_of_similarity_eigs = 4;
cAAM.shape{1}.n_all = cAAM.shape{1}.n + cAAM.shape{1}.num_of_similarity_eigs;
cAAM.shape{2}.n_all = cAAM.shape{2}.n + cAAM.shape{2}.num_of_similarity_eigs;
cAAM.texture{1}.m = 200;
cAAM.texture{2}.m = 50;

%cAAM.texture{1}.m = 25;
%cAAM.texture{2}.m = 5;

if flag_precompute
    if ~flag_train
        load([where '/' folder '/AAM.mat']);
    end
    
    cAAM.num_of_points = AAM.num_of_points;
    cAAM.scales = AAM.scales;
    cAAM.coord_frame = AAM.coord_frame;
    
    for ii = 1:num_of_scales
        % shape
        cAAM.shape{ii}.s0 = AAM.shape.s0;
        cAAM.shape{ii}.S = AAM.shape.S(:, 1:cAAM.shape{ii}.n);
        cAAM.shape{ii}.Q = AAM.shape.Q;
        
        % texture
        cAAM.texture{ii}.A0 = AAM.texture{ii}.A0;
        cAAM.texture{ii}.A = AAM.texture{ii}.A(:, 1:cAAM.texture{ii}.m);
        cAAM.texture{ii}.AA0 = AAM.texture{ii}.AA0;
        cAAM.texture{ii}.AA = AAM.texture{ii}.AA(:, 1:cAAM.texture{ii}.m);
        
        % warp jacobian
        [cAAM.texture{ii}.dW_dp, cAAM.coord_frame{ii}.triangles_per_point] = create_warp_jacobian(cAAM.coord_frame{ii}, cAAM.shape{ii});
    end
    save([where '/' folder '/cAAM.mat'], 'cAAM');
    
else
    load([where '/' folder '/cAAM.mat']);
end

%% fitting related parameters
num_of_scales_used = 2;
num_of_iter = [50 50];

%% landmark initializations
load initializations_LFPW

%% get images and ground truth shapes
%names1 = dir('./dataset/helen/testset/*.png');
names1 = dir('./testset/*.png');
%names1 = dir('./emotions/happiness/*.png');
%names2 = dir('./dataset/helen/testset/*.pts');
names2 = dir('./testset/*.pts');

emotionsDataFile =   ['.\emotions\emotionsTAFPDataFile.' date '_' int2str(randi(100,1)) '.xlsx'];
%emotionsDataFID = fopen(emotionsDataFile ,'w');
%fprintf(emotionsDataFID,"%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s\n", 'image name','emotions','left_eyes_height','left_eyes_width','right_eye_height','right_eye_width','left_eyebrows_width','right_eyebrows_width','lips_width','left_eye_upper_corner & left_eyebrows center distance', 'right_eye_upper_corner & right_eyebrows center distance', 'nose_center & lip_center','left_eye_lower & lips_left','right_eye_lower & lips_right','Lips Rows','Lips Columns','Left Eye Rows','Left Eye Columns','Right Eye Rows','Right Eye Columns');
%fprintf(emotionsDataFID,"%s, %s, %s, %s, %s, %s, %s, %s\n", 'image name','emotions','ic_cc','ic_oc','ic_bc','cc_oc','ic_bc','oc_bc');

%gg = 7; % choose image gg to fit
%for gg=1:size(names1,1)

%image_list=["image_0003.png" "image_0050.png" "image_0146.png" "image_0186.png" "image_0195.png" "image_0206.png"];
%image_list=["image_0001.png" "image_0008.png" "image_0011.png" "image_0014.png" "image_0021.png" "image_0022.png" "image_0044.png" "image_0059.png" "image_0093.png" "image_0099.png" "image_0115.png"];
%emotion_list=["Happy" "Happy" "Happy" "Happy" "Happy" "Happy" "Surprise" "Surprise" "Surprise" "Surprise" "Surprise"];

xlRange='A1:AYG1';
%xlswrite(emotionsDataFile,[ "images" "emotions" "distance type" [[1:1330] [1:19]]], xlRange);
%for gg=[3 45 134 173 180 191];
excel_index=0;
excel_index_size=6;

%for image=image_list
for gg=1:1
%for gg=1:size(names1,1)
%gg=find(ismember(string(vertcat(names1.name)),image));
%image_index=find(ismember(image_list,image));
%image_emotion=emotion_list(image_index);
%input_image = imread(['./dataset/helen/testset/' names1(gg).name]);
input_image = imread(['./testset/' names1(gg).name]);
input_image_dir = dir(['./emotions/*/' names1(gg).name]);
if (~isempty(input_image_dir))
input_image_dir_parts=regexp(input_image_dir.folder,'\','split');
image_emotion = string(input_image_dir_parts(11));
else
image_emotion = "Others"
end
%input_image = imread(['./emotions/happiness/' names1(gg).name]);
%input_image = imread(['./face_PNG5646.png']);

%
 pts = read_shape(['./testset/' names2(gg).name], cAAM.num_of_points);
%pts=read_shape('face_PNG5646.pts',68);

if size(input_image, 3) == 3
    input_image = double(rgb2gray(input_image));
else
    input_image = double(input_image);
end

%% ground_truth
%gt_s = (pts);
%face_size = (max(gt_s(:,1)) - min(gt_s(:,1)) + max(gt_s(:,2)) - min(gt_s(:,2)))/2;

%% initialization
s0 = cAAM.shape{1}.s0;
current_shape = scl(gg)*reshape(s0, cAAM.num_of_points, 2) + repmat(trans(gg, :), cAAM.num_of_points, 1);
input_image = imresize(input_image, 1/scl(gg));
current_shape = (1/scl(gg))*(current_shape);
% uncomment to see initialization
%figure;imshow(input_image, []);  hold on; plot(current_shape(:,1), current_shape(:,2), '.', 'MarkerSize', 11);

%% Fitting an AAM using Fast-SIC algorithm
sc = 2.^(cAAM.scales-1);
for ii = num_of_scales_used:-1:1
    current_shape = current_shape /sc(ii);
    
    % indices for masking pixels out
    ind_in = cAAM.coord_frame{ii}.ind_in;
    ind_out = cAAM.coord_frame{ii}.ind_out;
    ind_in2 = cAAM.coord_frame{ii}.ind_in2;
    ind_out2 = cAAM.coord_frame{ii}.ind_out2;
    resolution = cAAM.coord_frame{ii}.resolution;
    
    A0 = cAAM.texture{ii}.A0;
    A = cAAM.texture{ii}.A;
    AA0 = cAAM.texture{ii}.AA0;
    AA = cAAM.texture{ii}.AA;
    
    for i = 1:num_of_iter(ii)
        
         %figure(1);clf;
        %imshow(imresize(input_image, [size(input_image, 1)/sc(ii) size(input_image, 2)/sc(ii)]), []); hold on;
         %trimesh(cAAM.coord_frame{ii}.triangles, current_shape(:,1),current_shape(:,2),'Color',(i/num_of_iter(ii)).*[0 1 1],'LineStIle','-');hold off;
        
        % Warp image
        Iw = warp_image(cAAM.coord_frame{ii}, current_shape*sc(ii), input_image);
        I = Iw(:); I(ind_out) = [];
        II = Iw(:); II(ind_out2) = [];
        
        % compute reconstruction Irec 
        if (i == 1)
            c = A'*(I - A0) ;
        else
            c = c + dc;
        end
        Irec = zeros(resolution(1), resolution(2));
        Irec(ind_in) = A0 + A*c;
        
        % compute gradients of Irec
        [Irecx Irecy] = gradient(Irec);
        Irecx(ind_out2) = 0; Irecy(ind_out2) = 0;
        Irec(ind_out2) = [];
        Irec = Irec(:);
        
        % compute J from the gradients of Irec
        J = image_jacobian(Irecx, Irecy, cAAM.texture{ii}.dW_dp, cAAM.shape{ii}.n_all);
        J(ind_out2, :) = [];
        
        % compute Jfsic and Hfsic 
        Jfsic = J - AA*(AA'*J);
        Hfsic = Jfsic' * Jfsic;
        inv_Hfsic = inv(Hfsic);
        
        % compute dp (and dq) and dc
        dqp = inv_Hfsic * Jfsic'*(II-AA0);
        dc = AA'*(II - Irec - J*dqp);
        
        % This function updates the shape in an inverse compositional fashion
        current_shape =  compute_warp_update(current_shape, dqp, cAAM.shape{ii}, cAAM.coord_frame{ii});
    end
    %figure; hold on; plot(current_shape(:,1), current_shape(:,2), '.', 'MarkerSize',11);
    current_shape(:,1) = current_shape(:, 1) * sc(ii) ;
    current_shape(:,2) = current_shape(:, 2) * sc(ii) ;
    %figure;imshow(input_image,[]);hold on;axis on;plot(current_shape(17:68,1), current_shape(17:68,2), '.', 'MarkerSize',11);
end
%[shapes_new,prom_array,prom_points] = convertPoints_AAM(names2(gg).name,current_shape);
[shapes_new,prom_array,fetT_array] = featureExtractionT_AAM(names2(gg).name,current_shape);
[shapes_new,prom_array,fetAFP_array_x,fetAFP_array_y] = featureExtractionTAFP_AAM(names2(gg).name,current_shape);

figure;
imshow(input_image, []); 
hold on; 
plot(shapes_new (:,1), shapes_new (:,2), '.','MarkerSize',11);
text(shapes_new(:,1),shapes_new(:,2),int2str(shapes_new(:,3)));
%plot(shapes_new (:,1), shapes_new (:,2), '.','MarkerSize',11);
%text(shapes_new(:,1),shapes_new(:,2),int2str(shapes_new(:,3)));

%figure;imshow(plot(shapes_new (:,1), shapes_new (:,2), '.','MarkerSize',11);text(shapes_new(:,1),shapes_new(:,2),int2str(shapes_new(:,3)));



%cmd=["python emotionDetection.py testset\" + names1(gg).name ]; 
%[null em_raw_data]=system(cmd);
%em_array=split(em_raw_data,"emotion:");
%if(size(em_array,1) == 4)
%emotions=string(strip(em_array(4)));
emotions='';
fprintf("Processing %s !!!\n",names1(gg).name);

for fetT_rows=1:size(fetT_array,1)
%fprintf(emotionsDataFID,"%s, %s,%f,%f,%f,%f,%f,%f\n", names1(gg).name,emotions,fetT_array(fetT_rows,15:20));
plot([fetT_array(fetT_rows,1),fetT_array(fetT_rows,3)],[fetT_array(fetT_rows,2),fetT_array(fetT_rows,4)],'Color','b');plot([fetT_array(fetT_rows,3),fetT_array(fetT_rows,5)],[fetT_array(fetT_rows,4),fetT_array(fetT_rows,6)],'Color','b');plot([fetT_array(fetT_rows,5),fetT_array(fetT_rows,1)],[fetT_array(fetT_rows,6),fetT_array(fetT_rows,2)],'Color','b');
end

%fprintf(emotionsDataFID,"%s, %s, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %d, %d, %d, %d, %d, %d\n", names1(gg).name,emotions,transpose(fet_array));
%for fetT_rows=1:size(fetT_array,1)
%fprintf(emotionsDataFID,"%s, %s,%f,%f,%f,%f,%f,%f\n", names1(gg).name,emotions,fetT_array(fetT_rows,15:20));
%plot([fetT_array(fetT_rows,1),fetT_array(fetT_rows,3)],[fetT_array(fetT_rows,2),fetT_array(fetT_rows,4)],'Color','b');plot([fetT_array(fetT_rows,3),fetT_array(fetT_rows,5)],[fetT_array(fetT_rows,4),fetT_array(fetT_rows,6)],'Color','b');plot([fetT_array(fetT_rows,5),fetT_array(fetT_rows,1)],[fetT_array(fetT_rows,6),fetT_array(fetT_rows,2)],'Color','b');
%end
fetAFP_array_size=size(fetAFP_array_x,1);
%figure;imshow(input_image, []);hold on;
fetAFP_array_lbp=[];
for fetAFP_z = 1:size(fetAFP_array_x,3)
plot([ fetAFP_array_x(1,1,fetAFP_z) fetAFP_array_x(fetAFP_array_size,1,fetAFP_z) fetAFP_array_x(fetAFP_array_size,fetAFP_array_size,fetAFP_z) fetAFP_array_x(1,fetAFP_array_size,fetAFP_z) fetAFP_array_x(1,1,fetAFP_z) ],[ fetAFP_array_y(1,1,fetAFP_z) fetAFP_array_y(fetAFP_array_size,1,fetAFP_z) fetAFP_array_y(fetAFP_array_size,fetAFP_array_size,fetAFP_z) fetAFP_array_y(1,fetAFP_array_size,fetAFP_z) fetAFP_array_y(1,1,fetAFP_z) ],'MarkerSize',11,'LineWidth',2);
    fetAFP_array_i = [];
    for fetAFP_x = 1:size(fetAFP_array_x,1)
        fetAFP_i_vector = [];
        for fetAFP_y = 1:size(fetAFP_array_y,1)
            if ( uint16(fetAFP_array_x(fetAFP_x,fetAFP_y,fetAFP_z)) <= size(input_image,1) && uint16(fetAFP_array_y(fetAFP_x,fetAFP_y,fetAFP_z)) <= size(input_image,2) )
            fetAFP_i_local=input_image(uint16(fetAFP_array_x(fetAFP_x,fetAFP_y,fetAFP_z)),uint16(fetAFP_array_y(fetAFP_x,fetAFP_y,fetAFP_z)));
            end
            fetAFP_i_vector = [ fetAFP_i_vector fetAFP_i_local ];
        end
        fetAFP_array_i = [ fetAFP_array_i ; fetAFP_i_vector ];
    end
fetAFP_array_z(:,:,fetAFP_z)=fetAFP_array_i;
fetAFP_local_lbp=localBinaryPatternAFP_AAM(fetAFP_array_i);
fetAFP_array_lbp = [fetAFP_array_lbp ; fetAFP_local_lbp ];
end
%plot(173.3585,286.1084,'.','MarkerSize',11);
%else
%fprintf("SkippefetAFP_array_y %s !!!\n",names1(gg).name);
%end
emotions='';
%fprintf("Processing %s !!!\n",names1(gg).name);
fetT_AFP_array_init = [ string(names1(gg).name) string(image_emotion) 'ic_cc'; string(names1(gg).name) string(image_emotion) 'ic_oc'; string(names1(gg).name) string(image_emotion) 'ic_bc'; string(names1(gg).name) string(image_emotion) 'cc_oc'; string(names1(gg).name) string(image_emotion) 'cc_bc'; string(names1(gg).name) string(image_emotion) 'oc_bc' ] ;
index_lower=strcat('A', int2str((excel_index)*excel_index_size+2));
index_upper=strcat('AYZ', int2str((excel_index)*excel_index_size+7));
xlRange = strcat(index_lower,':',index_upper);
fetAFP_array_lbp_local=fetAFP_array_lbp(:,1)';
%xlswrite(emotionsDataFile,[ fetT_AFP_array_init  transpose(fetT_array(:,15:20)) kron(fetAFP_array_lbp_local,[1;1;1;1;1;1]) ], xlRange);

%x = input('Do you want to proceed to next image Y/y [Y]:','s');
excel_index=excel_index+1;
end
%fclose(emotionsDataFID);
%shapes_distance = pdist(shapes_new);

%shapes_grid= squareform(shapes_distance);
%shapes_normalize = normalize(shapes_new);
%figure;imshow(input_image, []); hold on; plot(current_shape(:,1), current_shape(:,2), '.','MarkerSize',11);

%figure;imshow(input_image,[]);hold on;axis on;plot(current_shape(17:68,1), current_shape(17:68,2), '.','LineStyle','-', 'MarkerSize',11);
%trim_shape=trim_Shapes(current_shape(18:68,:));
%figure;imshow(input_image, []); hold on; plot(trim_shape(:,1), trim_shape(:,2), '.','LineStyle','-','MarkerSize',11);

%hold on; plot(current_shape(:,1), current_shape(:,2), '.', 'MarkerSize',11);
%current_shape = current_shape*scl(gg);



%% error metric used, a value of approx 0.03 shows very good fitting

%{
pt_pt_err1 = [];
for ii = 1:cAAM.num_of_points
    pt_pt_err1(ii) =  norm(gt_s(ii,:) - current_shape(ii,:));
end
pt_pt_err = mean(pt_pt_err1)/face_size
%}
