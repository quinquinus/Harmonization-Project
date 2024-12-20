function frequencies = frequencies_detection(signal, framerate, min_freq, max_freq, window_size, overlap, filename)
    
    threshold = 0.001;

    window_size = round(window_size*framerate);

    if length(signal) < window_size
        error("The signal is too short for the specified window size.");
    end



    disp('Searching for frequencies ...');
    overlap = round(overlap*framerate);
    step = window_size - overlap;

    min_offset = floor(framerate/max_freq);
    max_offset = ceil(framerate/min_freq);
    freq_times = zeros(4,0);
    offset = min_offset:min(max_offset, window_size-1);

    start_note = 0;

    for z = 1:floor((length(signal)-window_size)/step)
        start = z * step - step + 1;
        amplitude_window = mean(abs(signal(start:start+window_size)));
        if amplitude_window < threshold
            freq = 0;
            if_note = 0;
        else
            autocorr = zeros(1, max_offset-min_offset+1);
            
            for k = offset

                sum = 0;

                for i = 1:window_size-k
                    sum = sum + signal(start+i) * signal(start+i+k);
                end

                autocorr (k - min_offset + 1) = sum;

            end

            [~, index] = max(autocorr);
            freq = framerate / offset(index);

            
            if freq >= 1000
                freq = 0;
            end
            while (freq <= 254.177 || freq >= 508.355) && freq ~= 0

                if freq <= 254.177
    
                    freq = freq*2;
    
                elseif freq >= 508.355
    
                    freq = freq / 2;
                end
            end

            if start_note == 0
                if z == 1 || z == 2
                    if_note = 0;
                elseif amplitude_window > freq_times(3,z-1) + 0.002
                    if_note = 1;
                    start_note = z;
                else
                    if_note = 0;
                end
            else
                previous_freq = mean(freq_times(1,start_note:size(freq_times,2)));
                if freq_times(2,z-1) == 1 || freq_times(2,z-2) == 1
                    index_1 = z - 1 - (freq_times(2, z-2) == 1);
                    if (amplitude_window > 1.2*freq_times(3,index_1) && freq <= 1.0293 * previous_freq && freq >= (1/1.0293) * previous_freq) ...
                        || freq >= 1.0293 * previous_freq || freq <= (1/1.0293) * previous_freq
                        if_note = 1;
                        start_note = z;
                        freq_times(2,index_1) = 0;
                    else
                        if_note = 0;
                    end
                elseif amplitude_window > freq_times(3,z-1) + 0.002 || amplitude_window > freq_times(3,z-2) + 0.002 || freq >= 1.0293 * previous_freq || freq <= (1/1.0293) * previous_freq
                    if_note = 1;
                    start_note = z;
                else
                    if_note = 0;
                end
            end
        end

        vect = [ freq ; if_note; amplitude_window; (start+window_size/2)/framerate ];
        freq_times = [ freq_times , vect ];
    end

    disp('Plotting frequencies ...')

    figure;
    plot(freq_times(4,freq_times(1,:)~=0),freq_times(1,freq_times(1,:)~=0));
    xlabel("Time (s)");
    ylabel("Frequencies (Hz)");
    title("Detected frequencies as a function of time");
    subfolder = './results/plots';
    filename = fullfile(subfolder, ['plot_', filename, '.png']);
    saveas(gcf, filename);




    disp('Determination of the start of same frequencies ...')
    indexes = find(freq_times(2,:));
    frequencies = zeros(2,length(indexes));
    for w = 1:length(indexes)-1
        interval = freq_times(1,indexes(w):indexes(w+1)-1-2);
        frequencies(1,w) = mean(interval(interval~=0));
        frequencies(2,w) = freq_times(4,indexes(w));
    end
    interval = freq_times(1,indexes(length(indexes)):size(freq_times,2));
    frequencies(1,length(indexes)) = mean(interval(interval~=0));
    frequencies(2,length(indexes)) = freq_times(4,indexes(length(indexes)));
end