function [chords, final_scale] = chords_determination(signal, framerate, min_freq, max_freq, window_size, overlap, filename)

    [notes, final_scale] = scale_detection(signal, framerate, min_freq, max_freq, window_size, overlap, filename);

    % This function determines the chords associated with a given signal and its scale.
    % Input : 
    %   - notes is a cell array of 2 lines : 
    %           the first is the name of each note detected.
    %           the second is the times at which each note start.
    %
    %   - final_scale : cell array of size (1x2) :
    %           the first cell is the name of the scale found
    %           the second cell is a cell array of all the note names of this scale

    % Output :
    %   - chords is a matrix of 3 lines :
    %           the first line is the degree of each note detected based on the scale
    %           the second line is the degree of the chord on each note, 0 corresponds to "no chords on this note"
    %           the third line is the times of each note
    %
    %   - final_scale


    % Initialize variables for note processing
    % notes: Cell array containing detected notes and their corresponding times.
    % final_scale: Cell array with the name of the detected scale and its notes.
    notes_comp = notes;
    number_notes = size(notes,2); % Total number of detected notes
    notes_deg = zeros(2, number_notes); % Stores the degree of each note and its chord

    % Initial quarter note duration and start time estimation
    start = cell2mat(notes(2,1));
    quarter = 0.5625; % Mid value for a "quarter note" duration
    max_in_times = 0;
    
    % Adjust quarter note duration and start time by iterating over possible values
    for m = -0.33:0.005:0.33
        for n = -0.03:0.003:0.03
            quarter_temp = quarter * (1+m); % Adjust quarter note duration
            start_temp = start + n; % Adjust start time
            if quarter_temp >= 60/160 && quarter_temp < 60/80
                list_times = round((cell2mat(notes(2,:)) - start_temp)/quarter_temp*8)/8; % Count notes that align with measure boundaries
                if numel(list_times(mod(list_times,0.5)==0)) > max_in_times
                    max_in_times = numel(list_times(mod(list_times,0.5)==0));
                    dif_quarter = m;
                    dif_start = n;
                end
            end
        end
    end
    % Final adjusted black note duration and start time
    quarter = quarter * (1+dif_quarter);
    start = start + dif_start;


    disp('Determination of chords ...');

    % Assign degrees to detected notes based on the scale
    for a = 1:number_notes
        if any(strcmp(final_scale{2},notes(1,a)))
            notes_deg(1,a) = find(strcmp(final_scale{2},notes(1,a)));
        else
            notes_deg(1,a) = 0;
        end
    end
    
    % Calculate measures for each note based on timing and quarter note duration
    measures = round((cell2mat(notes(2,:)) - start)/quarter * 4) / 4;
    notes_deg = [notes_deg; measures];

    % Remove notes not in the scale
    mask = notes_deg(1, :) ~= 0;
    notes_deg = notes_deg(:, mask);
    notes = notes(:, mask);
    times = cell2mat(notes(2,:));

    % Insert missing measure starts and assign chords to notes
    for b = 0:4:notes_deg(3, size(notes_deg, 2))
        if ~any(notes_deg(3,:) == b) % If the measure start is missing
            if b == 0
                vect = [notes_deg(1,2); -1; 0]; % Insert a placeholder for the first measure
                notes_deg = [vect, notes_deg];
                times = [start, times];
            else
                [~, pos_new_note] = max(notes_deg(3, notes_deg(3,:) < b));
                if b - notes_deg(3,pos_new_note) > notes_deg(3,pos_new_note+1) - b
                    value_note = notes_deg(1, pos_new_note+1);
                else
                    value_note = notes_deg(1, pos_new_note);
                end
                vect = [value_note; -1; b];
                notes_deg = [notes_deg(:, 1:pos_new_note), vect, notes_deg(:,pos_new_note+1:end)];
                times = [times(1:pos_new_note), b * quarter + start, times(pos_new_note+1:end)];
            end
            
        else
            notes_deg(2, notes_deg(3,:) == b) = -1; % Assign placeholder chord to measure start
        end
    end
    
    % Add a placeholder for the last measure if needed
    if round(notes_deg(3,end)/4)*4 > notes_deg(3,end)
        vect = [notes_deg(1,end); -1; round(notes_deg(3, size(notes_deg, 2))/4)*4];
        notes_deg = [notes_deg, vect];
        times = [times, round(notes_deg(3,end)/4)*4 * quarter + start];
    end
    
    notes_deg = notes_deg(1:2, :);
    number_notes = size(notes_deg,2);

    % Helper functions for chord processing

    mod7 = @(x) mod(x-1,7) + 1; % Modular arithmetic for 7-note scales

    function res = chord(i)
        % Generate a chord (triad) from a degree
        res = [i, mod7(i+2), mod7(i+4)];
    end

    function res = next_measure(i)
        % Find the index of the next measure
        res = min(i + 1, length(index_measure));
    end

    function res = previous_measure(i)
        % Find the index of the previous measure
        res = max(i - 1, 1);
    end

    function index = pattern_milieu(list_pattern)
        % Function that check all places where a pattern would be possible to add
        index = [];
        if length(list_pattern) <= length(index_measure)
            i = 1;
            list_pattern_chords = arrayfun(@chord, list_pattern, 'UniformOutput', false);
            while i <= length(index_measure)-length(list_pattern)+1
                notes_verif = num2cell(notes_deg(1,index_measure(i:i+length(list_pattern)-1)));
                if all(notes_deg(2,index_measure(i:i+length(list_pattern)-1))==-1) && all(cellfun(@(x, y) ismember(x, y), notes_verif, list_pattern_chords))
                    index = [index, i];
                    i = i + length(list_pattern);
                else
                    i = i + 1;
                end
            end
        end
    end

    function notes_deg = middle(notes_deg, pattern)
        % Function that adds the middle patterns where its needed
        indexes = pattern_milieu(pattern);
        if ~isempty(indexes)
            for d = 1:length(indexes)
                notes_deg(2,index_measure(d:d+length(pattern)-1)) = pattern;
            end
        end

    end



    chords = [notes_deg; times];

    if ~any(notes_deg(2,:) == -1)
        disp('No start of measure seems to be detected !');
        disp(round((cell2mat(notes(2,:))-notes{2,1})/quarter*4)/4);
        return;
    else
        index_measure = find(notes_deg(2,:) == -1);
        
        % Start : this section checks if different patterns can be put at the end
        % Patterns checked :
        % 1-4
        % 1-5
        % 1-4-5


        k = 1; 
        if ismember(notes_deg(1,index_measure(k)),chord(1))
            notes_deg(2,index_measure(k)) = 1; 

            k = next_measure(k);
            if ismember(notes_deg(1,index_measure(k)),chord(4))
                notes_deg(2,index_measure(k)) = 4;

                k = next_measure(k);
                if ismember(notes_deg(1,index_measure(k)),chord(5))
                    notes_deg(2,index_measure(k)) = 5;
                end

            elseif ismember(notes_deg(1,index_measure(k)),chord(5))
                notes_deg(2,index_measure(k)) = 5;
            end
        end

        if ~any(notes_deg(2,:) == -1)
            chords = [notes_deg; times];
            disp('All chords have been added.');
            return;
        end
    
        % End : this section checks if different patterns can be put at the end
        % Patterns checked :
        % 5-1
        % 4-1
        % 2-5-1

        k = length(index_measure);
        if all(ismember(notes_deg(1,index_measure(k):number_notes), chord(1)))
            notes_deg(2,index_measure(k)) = 1;

            k = previous_measure(k);
            if ismember(notes_deg(1,index_measure(k)), chord(5))
                notes_deg(2,index_measure(k)) = 5;

                k = previous_measure(k);
                if ismember(notes_deg(1,index_measure(k)), chord(2))
                    notes_deg(2,index_measure(k)) = 2;
                end

            elseif ismember(notes_deg(1,index_measure(k)), chord(4))
                notes_deg(2,index_measure(k)) = 4;
            end
        end
        
        if ~any(notes_deg(2,:) == -1)
            chords = [notes_deg; times];
            disp('All chords have been added.')
            return;
        end 

        % Middle
        notes_deg = middle(notes_deg, [4, 5, 1]); % Pattern 1
        notes_deg = middle(notes_deg, [1, 6, 2, 5]); % Pattern 2
        notes_deg = middle(notes_deg, [6, 4, 1, 5]); % Pattern 3
        
        % Complete
        data = load('inputs/data_scales.mat', 'scales');
        scales = data.scales;
        index_scale = find(strcmp(final_scale{1}, scales(:,1)));
        forbidden_chord = 2 + 5 * (index_scale >= 8 && index_scale <= 24); % A "forbidden" chord that is rarely used in harmonization

        if ~any(notes_deg(2,:) == -1)
            chords = [notes_deg; times];
            disp('All chords have been added.')
            return;
        end
        if notes_deg(2,index_measure(1)) == -1
            notes_deg(2,index_measure(1)) = notes_deg(1,index_measure(1));
        end
        
        c = 2;
        while c <= length(index_measure)
            if notes_deg(2,index_measure(c)) == -1
                previous_chord = chord(notes_deg(2,index_measure(c-1)));
                chord1 = chord(notes_deg(1,index_measure(c)));
                chord2 = chord(mod7(notes_deg(1,index_measure(c))-2));
                chord3 = chord(mod7(notes_deg(1,index_measure(c))-4));
                comp = [length(intersect(chord1, previous_chord)), length(intersect(chord2, previous_chord)), length(intersect(chord3, previous_chord))];
                comp(comp==3) = 0;
                [~,index] = max(comp); % Find the closest chord to the previous chord
                value_chord = mod(notes_deg(1, index_measure(c)) + 2 - 2 * index - 1, 7) + 1;
                if value_chord == forbidden_chord
                    comp(index) = 0;
                    [~,index] = max(comp);
                    value_chord = mod(notes_deg(1, index_measure(c)) + 2 - 2 * index - 1, 7) + 1;
                end
                notes_deg(2, index_measure(c)) = value_chord;
            end
            c = c + 1;
        end
        
        if any(notes_deg(2,:) == -1)
            disp('There are still some chords to complete, code problem !');
        else
            disp('All chords have been added.')
        end

        chords = [notes_deg; times];
    end

    chords_comp = chords(2:3, chords(2,:) ~= 0);
    comparaison_references(notes_comp, chords_comp, final_scale, filename); % Calling the function that determines the grade of the harmonzation
end

