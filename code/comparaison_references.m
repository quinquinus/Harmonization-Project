function comparaison_references(notes_comp, chords_comp, scale_comp, filename)
    
    % This function compares computed notes, chords, and scales with reference data.
    % Inputs:
    %   - notes_comp: Computed notes from the audio file (cell array of notes and times).
    %   - chords_comp: Computed chords (matrix with degrees and times).
    %   - scale_comp: Computed scale (cell array containing the scale name and notes).
    %   - filename: Name of the audio file (used to load references and save results).
    % Outputs:
    %   - None (results are saved in a text file).

    % Helper function for modular arithmetic on 7-note scales
    mod7 = @(x) mod(x-1, 7) + 1;

    % Function to generate a reference chord (triad) for a given note name
    function res = chord_ref(str)
        index_note = find(strcmp(note_scale_ref, str));
        res = {str, note_scale_ref{mod7(index_note+2)}, note_scale_ref{mod7(index_note+4)}};
    end

    % Function to generate a computed chord (triad) for a given degree
    function res = chord_comp(deg)
        res = {scale_comp{2}{deg}, scale_comp{2}{mod7(deg+2)}, scale_comp{2}{mod7(deg+4)}};
    end

    % Function to calculate similarity between two sets of chords
    function score = calculate_similarity(cellArray1, cellArray2)
        % Ensure the two arrays have the same number of columns
        if size(cellArray1, 2) ~= size(cellArray2, 2)
            error('The two cell arrays must have the same number of columns.');
        end
        
        numColumns = size(cellArray1, 2);
        scores = zeros(1, numColumns);
        
        % Compare each column of the two arrays
        for col = 1:numColumns
            strings1 = cellArray1{1, col}; % Chord components (computed)
            strings2 = cellArray2{1, col}; % Chord components (reference)
            time1 = cellArray1{2, col};    % Time (computed)
            time2 = cellArray2{2, col};    % Time (reference)
            
            % Time similarity (20% weight)
            timeDiff = abs(time1 - time2);
            if timeDiff < 0.2
                timeScore = (1 - timeDiff / 0.2) * 0.2;
            else
                timeScore = 0;
            end
            
            % String similarity (80% weight)
            commonStrings = intersect(strings1, strings2);
            stringScore = (numel(commonStrings) / 3) * 0.8;
            
            % Combine scores
            scores(col) = timeScore + stringScore;
        end
        
        % Return average similarity score as a percentage
        score = mean(scores) * 100;
    end

    % Load reference data for notes, chords, and scale
    filename_ref = strcat(filename, '.mat');
    path = strcat('references/', filename_ref);
    data1 = load(path, 'notes_ref', 'chords_ref', 'scale_ref');
    notes_ref = data1.notes_ref;
    chords_ref = data1.chords_ref;
    scale_ref = data1.scale_ref;

    % Load predefined scale data
    data2 = load('inputs/data_scales.mat', 'scales');
    scales = data2.scales;

    % Grade notes detection
    if size(notes_comp, 2) == size(notes_ref, 2) && all(strcmp(notes_comp(1,:), notes_ref(1,:)))
        % Perfect match in note names and counts
        dist_time = mean(abs(cell2mat(notes_ref(2,:)) - cell2mat(notes_comp(2,:))));
        grade_notes = (0.6 + 0.4 * (1 - dist_time / 0.2)) * 100;
    else
        % Partial match: Compute grade based on individual comparisons
        grade_notes = 0;
        cnt = zeros(1, size(notes_comp, 2));
        for a = 1:size(notes_ref, 2)
            dist_time = abs(cell2mat(notes_comp(2,:)) - notes_ref{2,a});
            [value_min, index_min] = min(dist_time);
            grade_notes = grade_notes + ...
                        0.6 * (strcmp(notes_ref{1,a}, notes_comp{1,index_min})) + ...
                        0.4 * max(0, (1 - value_min / 0.25));
            cnt(index_min) = 1;
        end
        grade_notes = (grade_notes - length(notes_comp(2,~cnt))) / size(notes_ref, 2) * 100;
    end

    % Grade scale detection
    index_ref = find(strcmp(scale_ref, scales(:,1)));
    index_comp = find(strcmp(scale_comp{1}, scales(:,1)));

    if strcmp(scale_comp{1}, scale_ref)
        grade_scale = 100; % Perfect match
    elseif ((index_ref >= 1 && index_ref <= 12 && index_comp >= 13 && index_comp <=24) || ...
            (index_comp >= 1 && index_comp <= 12 && index_ref >= 13 && index_ref <=24)) && ...
            mod(max(index_ref, index_comp) +12 - 3 - 1, 12) + 1 == min(index_ref, index_comp)
        grade_scale = 80; % Match with transposition
    else
        grade_scale = 0; % No match
    end

    % Grade chords determination
    note_scale_ref = scales{index_ref, 2};

    if size(chords_comp, 2) == size(chords_ref, 2) || size(chords_comp, 2) == size(chords_ref, 2) + 1
        % Allow for one extra chord in the computed results
        if size(chords_comp, 2) == size(chords_ref, 2) + 1
            chords_comp = chords_comp(:, 1:end-1);
        end
        % Transform chords for comparison
        chords_ref(1,:) = cellfun(@chord_ref, chords_ref(1,:), 'UniformOutput', false);
        chords_comp = num2cell(chords_comp);
        chords_comp(1,:) = cellfun(@chord_comp, chords_comp(1,:), 'UniformOutput', false);
        grade_chords = calculate_similarity(chords_comp, chords_ref);
    else
        grade_chords = -1; % Invalid comparison
    end

    % Write grades to output file
    filename_output = strcat('results/grades/grade_', filename, '.txt');
    fileID = fopen(filename_output, 'w');

    if fileID == -1
        error('Failed to open the file.');
    end

    % Save grades to file
    fprintf(fileID, 'Grade of the notes detection : %.1f\n', grade_notes);
    fprintf(fileID, 'Grade of the scale detection : %.1f\n', grade_scale);
    fprintf(fileID, 'Grade of the chords determination : %.1f\n', grade_chords);
    fprintf(fileID, '\nFinal grade of %s harmonization : %.1f\n', filename, grade_notes * 0.3 + grade_scale * 0.3 + grade_chords * 0.4);

    % Close the file
    fclose(fileID);
end