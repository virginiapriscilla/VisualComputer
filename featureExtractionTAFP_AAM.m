% EMOTION DETECTION Triangulation and Local Pattern Feature Extraction
% ---------------------------------------------------------------------
% Programmed by     :       D. V. Shobhana Priscilla
% Guided by         :       Dr. P. Vanaja Ranjan
% Initial Version   :       Oct 27, 2024
% Revised Version   :       May 20, 2025
% ---------------------------------------------------------------------
function [newPointsData,pointsArray,P_array_x,P_array_y] = featureExtractionTAFP_AAM(pointsFile,pointsData)

%pointsFile=names2(gg).name;
%pointsData=current_shape;

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

    P1=[pointsData(ll,1) pointsData(ll,2) ll ];
    P2=[pointsData(lr,1) pointsData(lr,2) lr ];
    %P1
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(ll,1),pointsData(ll,2),10,-1,0);
    index = 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y;
    
    %P4
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(lr,1),pointsData(lr,2),10,1,0);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y; 
    
    %P10
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(lb,1),pointsData(lb,2),10,0,1);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y; 

    %P9
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(ll,1),pointsData(lb,2),10,-1,0);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y; 

    %P11
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(lr,1),pointsData(lb,2),10,1,0);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y; 


    %P20
    %[P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(nc,1),pointsData(nc,2),10,0,0);
    %index = index + 1;
    %P_array_x(:,:,index) = P_local_array_x;
    %P_array_y(:,:,index) = P_local_array_y; 
    
    %P2
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(nl,1),pointsData(nl,2),10,-1,-1);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y; 

    %P2-1
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(nl,1),pointsData(nl,2)+20,10,-1,-1);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y; 
   
    %P7
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(nl,1) - 20,pointsData(nl,2),10,-1,-1);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y; 

    %P8
    %[P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(nl,1) - 20,pointsData(nl,2) + 10,10,-1,-1);
    %index = index + 1;
    %P_array_x(:,:,index) = P_local_array_x;
    %P_array_y(:,:,index) = P_local_array_y; 

    %P5
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(nr,1),pointsData(nr,2),10,1,-1);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y;     

    %P5-1
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(nr,1),pointsData(nr,2)+20,10,1,-1);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y;  

    %P13
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(nr,1)+20,pointsData(nr,2),10,1,-1);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y; 

    %P12
    %[P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(nr,1)+20,pointsData(nr,2)+10,10,1,-1);
    %index = index + 1;
    %P_array_x(:,:,index) = P_local_array_x;
    %P_array_y(:,:,index) = P_local_array_y; 

    %P3
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(rel,1),pointsData(rel,2),10,-1,1);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y; 

    %P6
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(ler,1),pointsData(ler,2),10,1,1);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y; 
    
    %[ pointsData(rel,1) pointsData(rel,2) pointsData(ler,1) pointsData(ler,2) ( pointsData(ler,1) + pointsData(rel,1) ) / 2 ( pointsData(ler,2) + pointsData(rel,2) ) / 2 ]
    %P16
    [P_local_array_x,P_local_array_y]=adjacent_pixels( ( pointsData(ler,1) + pointsData(rel,1) ) / 2, ( pointsData(ler,2) + pointsData(rel,2) ) / 2,10,0,0);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y; 
    
    %P19
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(rebl,1),pointsData(rebl,2),10,1,-1);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y; 

    %P18
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(lebr,1),pointsData(lebr,2),10,-1,-1);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y; 

    %P17
    [P_local_array_x,P_local_array_y]=adjacent_pixels((pointsData(lebr,1)+pointsData(rebl,1))/2,(pointsData(lebr,2) + pointsData(rebl,2))/2,10,0,-1);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y;

    %P14
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(reb,1),pointsData(reb,2),10,0,1);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y; 

    %P15
    [P_local_array_x,P_local_array_y]=adjacent_pixels(pointsData(leb,1),pointsData(leb,2),10,0,1);
    index = index + 1;
    P_array_x(:,:,index) = P_local_array_x;
    P_array_y(:,:,index) = P_local_array_y; 


    %feature_array=P1_array;
end