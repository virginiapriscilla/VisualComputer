% EMOTION DETECTION Triangulation Feature Extraction
% ---------------------------------------------------------------------
% Programmed by     :       D. V. Shobhana Priscilla
% Guided by         :       Dr. P. Vanaja Ranjan
% Initial Version   :       Oct 27, 2024
% Revised Version   :       May 20, 2025
% ---------------------------------------------------------------------
function [newPointsData,pointsArray,feature_array] = featureExtractionT_AAM(pointsFile,pointsData)


%function featureExtractionT_AAM(pointsFile,pointsData)
%left_eyebroes_left   = 18          right_eyebroes_left   = 23
%left_eyebroes_center = 20          right_eyebroes_center = 25
%left_eyebroes_right  = 22          right_eyebroes_right  = 27
lebl = 18;rebl = 23;
lebc = 20;rebc = 25;
lebr = 22;rebr = 27;

%left_eyes_left       = 37          right_eyes_left   = 43
%left_eyes_top        = 38          right_eyes_top    = 45
%left_eyes_right      = 40          right_eyes_right  =  46
%left_eyes_bottom     = 42          right_eyes_bottom = 48
lel = 37;rel = 43;
let = 38;ret = 45;
ler = 40;rer = 46;
leb = 42;reb = 48;

%nose_left            = 32          lips_left  = 49
%nose_center          = 34          lips_right = 55
%nose_right           = 36          lips_top   = 52
%                                   lips_bottom= 58
nl = 32;ll = 49;
nc = 34;lr = 55;
nr = 36;lt = 52;
        lb = 58;

    originalSize = size(pointsData,1);
    targetSize = 21;

    [pointsFolderName pointsBaseName pointsExt]=fileparts(pointsFile);
    outDataFile =   ['.\emotions\' pointsBaseName '_21' pointsExt];
    outputFID = fopen(outDataFile ,'w');
    fprintf(outputFID,'%s\n','version      : 2');
    fprintf(outputFID,'%s %d\n','n_points  :  ',targetSize);
    fprintf(outputFID,'%s\n','{');
    %pointsData = read_shape(shapesData,originalSize);
    %for index = [ 18 20 22 23 25 27 32 34 36 37 40 43 46 49 52 55 58 ]
    for index = [ lebl lebc lebr rebl rebc rebr nl nc nr lel ler rel rer ll lt lr lb]
    fprintf(outputFID,'%3.6f %3.6f %d\n', pointsData(index,1),pointsData(index,2),index);
    pointsArray(index,1)=pointsData(index,1);
    pointsArray(index,2)=pointsData(index,2);
    end
    fprintf(outputFID,'%3.6f %3.6f %d\n', mean([pointsData(let,:); pointsData(39,:)]),let);
    pointsArray(let,1)=pointsData(let,1);
    pointsArray(let,2)=pointsData(let,2);

    fprintf(outputFID,'%3.6f %3.6f %d\n', mean([pointsData(41,:); pointsData(leb,:)]),leb);
    pointsArray(leb,1)=pointsData(leb,1);
    pointsArray(leb,2)=pointsData(leb,2);

    fprintf(outputFID,'%3.6f %3.6f %d\n', mean([pointsData(44,:); pointsData(ret,:)]),ret);
    pointsArray(ret,1)=pointsData(ret,1);
    pointsArray(ret,2)=pointsData(ret,2);

    fprintf(outputFID,'%3.6f %3.6f %d\n', mean([pointsData(47,:); pointsData(reb,:)]),reb);   
    pointsArray(reb,1)=pointsData(reb,1);
    pointsArray(reb,2)=pointsData(reb,2);

    fprintf(outputFID,'%s\n','}');
    fclose(outputFID);
    newPointsData = read_points(outDataFile,targetSize,2);
    %array_seq = [18 20 22 23 25 27 32 34 36 37 40 43 46 49 52 55 58 38 42 45 48 ];
    %             [18 20 22 23 25 27 32 34 36 37 40 43 46 49 52 55 58             ]      
    %array_seq = [ lebl lebc lebr rebl rebc rebr nl nc nr lel ler rel rer ll lt lr lb let leb ret reb];
    %array_seq=transpose(array_seq);

%    triangle_bottom_points = [ nl nc nr ll lt lr lb];
%    triangle_upper_points= [ lebl lebc lebr rebl rebc rebr lel ler rel rer let leb ret reb];
%    triangle_bottom_points = [ nl nc nr ll lt lr lb lebl lebc lebr rebl rebc rebr lel ler rel rer let leb ret reb];
    triangle_points  = [ nl nc nr ll lt lr lb lebl lebc lebr rebl rebc rebr lel ler rel rer let leb ret reb];
    triangle_points_array = [];
    
    for x=1:size(triangle_points,2)
     for y=x+1:size(triangle_points,2)
        for z = y+1:size(triangle_points,2)
        triangle_points_x = [pointsData(triangle_points(x),1) pointsData(triangle_points(x),2)];
        triangle_points_y = [pointsData(triangle_points(y),1) pointsData(triangle_points(y),2)];
        triangle_points_z = [pointsData(triangle_points(z),1) pointsData(triangle_points(z),2)];
        
        triangle_ic=incenterTriangle(triangle_points_x,triangle_points_y,triangle_points_z);
        triangle_cc=circumcenterTriangle(triangle_points_x,triangle_points_y,triangle_points_z);
        triangle_oc=orthocenterTriangle(triangle_points_x,triangle_points_y,triangle_points_z);
        triangle_bc=barycenterTriangle(triangle_points_x,triangle_points_y,triangle_points_z);

        ic_cc_dist=euc_dist(triangle_ic,triangle_cc);
        ic_oc_dist=euc_dist(triangle_ic,triangle_oc);
        ic_bc_dist=euc_dist(triangle_ic,triangle_bc);
        cc_oc_dist=euc_dist(triangle_cc,triangle_oc);
        cc_bc_dist=euc_dist(triangle_cc,triangle_bc);
        oc_bc_dist=euc_dist(triangle_oc,triangle_bc);

        triangle_points_array = [triangle_points_array; triangle_points_x triangle_points_y triangle_points_z triangle_ic triangle_cc triangle_oc triangle_bc ic_cc_dist ic_oc_dist ic_bc_dist cc_oc_dist cc_bc_dist oc_bc_dist];
        %triangle_points_array = [triangle_points_array; ic_cc_dist ic_oc_dist ic_bc_dist cc_oc_dist cc_bc_dist oc_bc_dist]
        %[ triangle_point_x triangle_point_y triangle_point_z];
    end
    end
    end


feature_array=triangle_points_array;
%end