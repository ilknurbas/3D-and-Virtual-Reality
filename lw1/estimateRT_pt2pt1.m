function [R,t] = estimateRT_pt2pt1(pts, ptsMoved)
 
    C = zeros(6,6);
    b = zeros(6,1);
    t = zeros(1,3);
    R = zeros(3,3);
    
    
    normals = pcnormals(pointCloud(pts)); %  35947           3

    %c = cross(ptsMoved, normals); % 35947           3
    %size(ptsMoved - pts); %   35947           3
    %size(dot(ptsMoved - pts, normals)); % 1     3
    %size(c*dot(ptsMoved - pts, normals)'); %  35947           1
    %ci = cross(ptsMoved(1,:), normals(1,:)); % 1     3
    %bx = ci' * dot(ptsMoved(1, :) - pts(1, :), normals(1,:)); % 3     1
 

    for i = 1:size(pts,1)
        ni = normals(i, :)'; % 3x1

        ci = cross(ptsMoved(i, :), normals(i, :)); % 1     3
        b(1:3,1) = b(1:3,1) + ci' * dot(ptsMoved(i, :) - pts(i, :), ni);
        b(4:6,1) = b(4:6,1) + ni * dot(ptsMoved(i, :) - pts(i, :), ni);
       
        
        cix = ci(1);
        ciy = ci(2);
        ciz = ci(3);
        nix = ni(1);
        niy = ni(2);
        niz = ni(3);
        
        temp1 = [cix*cix cix*ciy cix*ciz;
            ciy*cix ciy*ciy ciy*ciz;
            ciz*cix ciz*ciy ciz*ciz];
        C(1:3,1:3) = C(1:3,1:3) + temp1;

        temp2 = [cix*nix cix*niy cix*niz;
            ciy*nix ciy*niy ciy*niz;
            ciz*nix ciz*niy ciz*niz;];
        C(1:3,4:6) = C(1:3,4:6) + temp2;

        temp3 = [nix*cix nix*ciy nix*ciz;
            niy*cix niy*ciy niy*ciz;
            niz*cix niz*ciy niz*ciz];
        C(4:6,1:3) = C(4:6,1:3) + temp3;

        temp4 = [nix*nix nix*niy nix*niz;
            niy*nix niy*niy niy*niz;
            niz*nix niz*niy niz*niz];
        C(4:6,4:6) = C(4:6,4:6) + temp4;
        
    end
    b = -b; %  6     1
    x = C\b; %  6     1
 

    t = [x(4) x(5) x(6)]; %  1     3

    x(1) = deg2rad(x(1));
    x(2) = deg2rad(x(2));
    x(3) = deg2rad(x(3));

    R_x = [1 0 0; 0 cos(x(1)) -sin(x(1)); 0 sin(x(1)) cos(x(1))];
    R_y = [cos(x(2)) 0 sin(x(2)); 0 1 0; -sin(x(2)) 0 cos(x(2))];
    R_z = [cos(x(3)) -sin(x(3)) 0; sin(x(3)) cos(x(3)) 0; 0 0 1];
    R = R_z * R_y * R_x;
    
   
    
end

