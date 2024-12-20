function [chords, final_scale] = chords_determination(signal, framerate, min_freq, max_freq, window_size, overlap, filename)

    [notes, final_scale] = scale_detection(signal, framerate, min_freq, max_freq, window_size, overlap, filename);

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

    notes_comp = notes;

    number_notes = size(notes,2);
    notes_deg = zeros(2, number_notes);

    notes_gap = cell2mat(notes(2,2:number_notes)) - cell2mat(notes(2,1:number_notes-1));
    min_length = mean(notes_gap(notes_gap < 1.3 * min(notes_gap)));
    black = min_length;

    while black < 60/160 || black >= 60/80
        if black < 60/160
            black = black * 2;
        else
            black = black / 2;
        end
    end

    start = cell2mat(notes(2,1));
    max_in_times = 0;
    
    for m = -0.1:0.01:0.1
        for n = -0.03:0.0015:0.03
            black_temp = black * (1+m);
            start_temp = start + n;
            list_times = round((cell2mat(notes(2,:)) - start_temp)/black_temp*4)/4;
            if numel(list_times(mod(list_times,1)==0)) > max_in_times
                max_in_times = numel(list_times(mod(list_times,1)==0));
                dif_black = m;
                dif_start = n;
            end
        end
    end
    black = black * (1+dif_black);
    start = start + dif_start;


    disp('Determination of chords ...')

    % tic;%
    for a = 1:number_notes
        if any(strcmp(final_scale{2},notes(1,a)))
            notes_deg(1,a) = find(strcmp(final_scale{2},notes(1,a)));
        else
            notes_deg(1,a) = 0;
        end
        if mod(round((cell2mat(notes(2,a)) - start)/black * 4) / 4, 4) == 0
            notes_deg(2,a) = -1;
        end
    end
    mask = notes_deg(1, :) ~= 0;
    notes_deg = notes_deg(:, mask);
    notes = notes(:, mask);
    number_notes = size(notes,2);

    mod7 = @(x) mod(x-1,7) + 1;




    function res = chord(i)
        res = [i, mod7(i+2), mod7(i+4)];
    end

    function res = next_measure(i)
        res = min(i + 1, length(index_measure));
    end

    function res = previous_measure(i)
        res = max(i - 1, 1);
    end

    function index = pattern_milieu(list_pattern)
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

        indexes = pattern_milieu(pattern);
        if ~isempty(indexes)
            for b = 1:length(indexes)
                notes_deg(2,index_measure(b:b+length(pattern)-1)) = pattern;
            end
        end

    end




    chords = [notes_deg; cell2mat(notes(2,:))];

    if ~any(notes_deg(2,:) == -1)
        disp('No start of measure seems to be detected !');
        disp(round((cell2mat(notes(2,:))-notes{2,1})/black*4)/4);
        % time = toc;%
        % fprintf('Execution time : %.3f seconds\n', time);%
        % fprintf('\n');%
        return;
    else
        index_measure = find(notes_deg(2,:) == -1);
        
        % Début
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
            chords = [notes_deg; cell2mat(notes(2,:))];
            disp('All chords have been added.');
            % time = toc;%
            % fprintf('Execution time : %.3f seconds\n', time);%
            % fprintf('\n');%
            return;
        end
    
        % Fin
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
            chords = [notes_deg; cell2mat(notes(2,:))];
            disp('All chords have been added.')
            % time = toc;%
            % fprintf('Execution time : %.3f seconds\n', time);%
            % fprintf('\n');%
            return;
        end 

        % Milieu
        notes_deg = middle(notes_deg, [4, 5, 1]);
        notes_deg = middle(notes_deg, [1, 6, 2, 5]);
        notes_deg = middle(notes_deg, [6, 4, 1, 5]);
        
        % Compléter
        if ~any(notes_deg(2,:) == -1)
            chords = [notes_deg; cell2mat(notes(2,:))];
            disp('All chords have been added.')
            % time = toc;%
            % fprintf('Execution time : %.3f seconds\n', time);%
            % fprintf('\n');%
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
                [~,index] = max(comp);
                notes_deg(2, index_measure(c)) = mod(notes_deg(1, index_measure(c)) + 2 - 2 * index - 1, 7) + 1;
            end
            c = c + 1;
        end
        
        if any(notes_deg(2,:) == -1)
            disp('There are still some chords to complete, code problem !');
        else
            disp('All chords have been added.')
        end

        chords = [notes_deg; cell2mat(notes(2,:))];
    end

    chords_comp = chords(2:3, chords(2,:) ~= 0);

    compaaraison_references(notes_comp, chords_comp, final_scale);

    % time = toc;%
    % fprintf('Execution time : %.3f seconds\n', time);%
    % fprintf('\n');%
end

% début :
% 1-4
% 1-5
% 1-4-5

% fin :
% 5-1
% 4-1
% 2-5-1

% milieu :
% 4-5-1
% 1-6-2-5
% 6-4-1-5

