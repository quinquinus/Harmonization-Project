function [notes, final_scale] = scale_detection(signal, framerate, min_freq, max_freq, window_size, overlap, filename)

    notes = notes_detection(signal, framerate, min_freq, max_freq, window_size, overlap, filename);

    % Input : 
    %   notes is a cell array of 2 lines : 
    %       The first is the name of each note detected.
    %       The second is the times at which each note start.

    % Output :
    %   - notes
    %   - final_scale : cell array of size (1x2) :
    %           the first cell is the name of the scale found
    %           the second cell is a cell array of all the note names of this scale


    disp('Determination of the scale ...');

    data = load('inputs/data_scales.mat', 'scales'); % Loading scales data from data_scales.mat
    scales = data.scales;

    present_notes = notes(1,:);
    tab_inter = [];

    for i = 1:size(scales, 1)
        inter = intersect(scales{i,2},present_notes); % Finding the number of matching notes with each scale
        tab_inter = [tab_inter,numel(inter)]; 
    end

    inter_max = max(tab_inter); % Keeping the scales with the most matchings
    max_index = [find(tab_inter == inter_max);zeros(1,length(find(tab_inter == inter_max)))];

    % Based on the fact that a melody usually begins and finishes by its tonic note,
    % if several scales 

    first_note = notes{1,1};
    last_note = notes{1,size(notes,2)};

    for j = 1:size(max_index,2)
        if strcmp(scales{max_index(1,j),2}{1},first_note)
            max_index(2,j) = max_index(2,j) + 1;
        end
        if strcmp(scales{max_index(1,j),2}{1},last_note)
            max_index(2,j) = max_index(2,j) + 1;
        end
    end

    max_comp = max(max_index(2,:));
    max_index = max_index(1,max_index(2,:) == max_comp);

    if length(max_index) ~= 1
        disp('Several scales seem to be assigned.');
    end

    index_final_scale = max_index(1);
    final_scale = scales(index_final_scale,:);
    
    disp(['This melody is in the scale of : ', final_scale{1}]);
    disp(['Number of notes in common with these : ', num2str(inter_max)]);
end