function face_annotation(movies)
global movies_folder
    for movie_name=movies
        movie_name=cell2mat(movie_name);
        filename = [movies_folder movie_name '/annotation/face.txt'];
        delimiter = '\t';
        formatSpec = '%f%f%s%[^\n\r]';
        fileID = fopen(fullfile(filename),'r');
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
        fclose(fileID);
        dataArray([1, 2]) = cellfun(@(x) num2cell(x), dataArray([1, 2]), 'UniformOutput', false);
        face1 = [dataArray{1:end-1}];
        clearvars filename delimiter formatSpec fileID dataArray ans;
        load([movies_folder movie_name '/results_script/' movie_name '_person_tags.mat'])

        index_pairs=[];
        for i=1:length(classes)
            index=find(strcmp(tags(i),face1(:,3)));
            if isempty(index)==0
                index_pairs=[index_pairs;classes(i) face1{index,2}];
            end
        end

        face2=zeros(size(face1,1),1);
        for i=1:size(face1,1)
            index=find(face1{i,2}==index_pairs(:,2));
            if isempty(index)==0
                face2(i)=index_pairs(index,1);
            end
        end
        face3=face1;
        face3(:,2)=mat2cell(face2,ones(length(face2),1));

        face=face3;
        save([movies_folder movie_name '/annotation/face.mat'],'face')
    end
end