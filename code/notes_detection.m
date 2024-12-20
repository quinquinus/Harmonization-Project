function notes = notes_detection (signal, framerate, min_freq, max_freq, window_size, overlap, filename)
    
    frequencies = frequencies_detection(signal, framerate, min_freq, max_freq, window_size, overlap, filename);

    % Input : 
    %   frequencies is a matrix of 2 lines : 
    %       The first is the frequencies of each note detected.
    %       The second is the times at which each note start.

    % Output :
    %   notes : a cell array structured the same as the variable frequencies, 
    %   but instead of frequencies there is the name of the closest note.

    notes_frequencies = struct( ...
        'Do', 261.625, ...
        'Dod', 277.182, ...
        'Re', 293.664, ...
        'Red', 311.126, ...
        'Mi', 329.627, ...
        'Fa', 349.228, ...
        'Fad', 369.994, ...
        'Sol', 391.995, ...
        'Sold', 415.304, ...
        'La', 440.000, ...
        'Lad', 466.163, ...
        'Si', 493.883);


    disp('Matching with notes ...')
    
    % Finding the closest note to all frequencies found

    notes_name = fieldnames(notes_frequencies);
    notes_value = cell2mat(struct2cell(notes_frequencies));
    notes = cell(2,0);

    for a = 1:length(frequencies(1,:))
        freq = frequencies(1,a);
        [~, min_index] = min(abs(log2(notes_value / freq)));
        notes = [notes, {notes_name{min_index};frequencies(2,a)}];
    end

    fprintf('%d notes detected.\n', size(notes, 2));
end