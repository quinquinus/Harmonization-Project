function frequencies = frequencies_detection(signal, framerate, min_freq, max_freq, window_size, overlap, filename)
    % This function detects frequencies in a given signal over time.
    % Inputs:
    %   - signal: Audio signal to analyze.
    %   - framerate: Sampling frequency of the signal.
    %   - min_freq, max_freq: Minimum and maximum frequencies to detect (Hz).
    %   - window_size: Duration of the analysis window (seconds).
    %   - overlap: Overlap between consecutive windows (seconds).
    %   - filename: Name of the file for saving results.
    % Output:
    %   - frequencies: 2-row matrix with detected frequencies and their start times.

    % Threshold for signal amplitude to consider as valid
    threshold = 0.001;

    % Convert window size and overlap to samples
    window_size = round(window_size * framerate);

    % Ensure the signal is long enough for the specified window size
    if length(signal) < window_size
        error("The signal is too short for the specified window size.");
    end

    disp('Searching for frequencies ...');
    overlap = round(overlap * framerate);
    step = window_size - overlap; % Step size between windows

    % Define offset range based on min and max frequency
    min_offset = floor(framerate / max_freq);
    max_offset = ceil(framerate / min_freq);
    freq_times = zeros(4, 0); % Matrix to store detected frequencies, notes, amplitudes, and times
    offset = min_offset:min(max_offset, window_size - 1); % Range of offsets for autocorrelation

    start_note = 0; % Tracks the start of a note

    % Loop through signal in steps of the specified window size
    for z = 1:floor((length(signal) - window_size) / step)
        start = z * step - step + 1; % Start index of the current window
        amplitude_window = mean(abs(signal(start:start + window_size))); % Mean amplitude of the window
        
        if amplitude_window < threshold
            % If the window's amplitude is below the threshold, no frequency is detected
            freq = 0;
            if_note = 0;
        else
            % Calculate autocorrelation for the current window
            autocorr = zeros(1, max_offset - min_offset + 1);
            for k = offset
                sum = 0;
                for i = 1:window_size - k
                    sum = sum + signal(start + i) * signal(start + i + k); % Autocorrelation computation
                end
                autocorr(k - min_offset + 1) = sum;
            end

            % Find the offset corresponding to the maximum autocorrelation
            [~, index] = max(autocorr);
            freq = framerate / offset(index); % Compute frequency from the offset

            % Normalize frequency to the range [254.177, 508.355] Hz (within one octave)
            if freq >= 1000
                freq = 0;
            end
            while (freq <= 254.177 || freq >= 508.355) && freq ~= 0
                if freq <= 254.177
                    freq = freq * 2;
                elseif freq >= 508.355
                    freq = freq / 2;
                end
            end

            % Determine if this is the start of a new note
            if start_note == 0
                % Initial detection logic
                if z == 1 || z == 2
                    if_note = 0;
                elseif amplitude_window > freq_times(3, z - 1) + 0.002
                    if_note = 1;
                    start_note = z;
                else
                    if_note = 0;
                end
            else
                % Check if this is a continuation or a new note
                previous_freq = mean(freq_times(1, start_note:size(freq_times, 2)));
                if freq_times(2, z - 1) == 1 || freq_times(2, z - 2) == 1
                    % Adjust note start if conditions are met
                    index_1 = z - 1 - (freq_times(2, z - 2) == 1);
                    if (amplitude_window > 1.2 * freq_times(3, index_1) && ...
                        freq <= 1.0293 * previous_freq && freq >= (1 / 1.0293) * previous_freq) || ...
                        freq >= 1.0293 * previous_freq || freq <= (1 / 1.0293) * previous_freq
                        if_note = 1;
                        start_note = z;
                        freq_times(2, index_1) = 0;
                    else
                        if_note = 0;
                    end
                elseif amplitude_window > freq_times(3, z - 1) + 0.002 || ...
                       amplitude_window > freq_times(3, z - 2) + 0.002 || ...
                       freq >= 1.0293 * previous_freq || freq <= (1 / 1.0293) * previous_freq
                    if_note = 1;
                    start_note = z;
                else
                    if_note = 0;
                end
            end
        end

        % Store detected frequency, note status, amplitude, and time
        vect = [freq; if_note; amplitude_window; (start + window_size / 2) / framerate];
        freq_times = [freq_times, vect];
    end

    % Plot detected frequencies over time
    disp('Plotting frequencies ...');
    figure;
    plot(freq_times(4, freq_times(1, :) ~= 0), freq_times(1, freq_times(1, :) ~= 0));
    xlabel("Time (s)");
    ylabel("Frequencies (Hz)");
    title("Detected frequencies as a function of time");
    subfolder = './results/plots';
    filename = fullfile(subfolder, ['plot_', filename, '.png']);
    saveas(gcf, filename);

    % Determine the start times of segments with similar frequencies
    disp('Determination of the start of same frequencies ...');
    indexes = find(freq_times(2, :));
    frequencies = zeros(2, length(indexes));
    for w = 1:length(indexes) - 1
        interval = freq_times(1, indexes(w):indexes(w + 1) - 1 - 2);
        frequencies(1, w) = mean(interval(interval ~= 0)); % Average frequency in the interval
        frequencies(2, w) = freq_times(4, indexes(w)); % Start time of the interval
    end
    interval = freq_times(1, indexes(length(indexes)):size(freq_times, 2));
    frequencies(1, length(indexes)) = mean(interval(interval ~= 0));
    frequencies(2, length(indexes)) = freq_times(4, indexes(length(indexes)));
end