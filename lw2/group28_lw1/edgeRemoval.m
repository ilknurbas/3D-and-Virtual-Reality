function edgeRemoval( h )
    face_normals = h.FaceNormals; 
    
    % normals magnitude in the horizontal/vertical directions
    mag12 = sqrt(sum(face_normals(:, :, 1:2).^2, 3));
    % mag12 = norm([face_normals(i,j,1), face_normals(i,j, 2)]) 
    mag3 = abs(face_normals(:, :, 3));
    size(mag12);
    size(mag3);

    [row, col] = find(mag12 > mag3);
    size(row);

    for i = 1:length(row)
        h.CData(row(i),col(i),:) = NaN;
    end
    
end

