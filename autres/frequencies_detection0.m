function frequencies = frequencies_detection0(signal, framerate, min_freq, max_freq, window_size, overlap)

    threshold = 0.10 * mean(abs(signal));

    window_size = round(window_size*framerate);

    if length(signal) < window_size
        error("The signal is too short for the specified window size.");
    end



    disp('Searching for frequencies ...');
    tic;%
    overlap = round(overlap*framerate);
    step = window_size - overlap;

    min_offset = floor(framerate/max_freq);
    max_offset = ceil(framerate/min_freq);
    freq_times = zeros(2,0);
    offset = min_offset:min(max_offset, window_size-1);

    for start = 1:step:length(signal)-window_size
        if mean(abs(signal(start:start+window_size))) < threshold
            freq = 0;
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
        end

        % fprintf("Fenetre centrée à %.2f s : frequence détectée = %.2f Hz\n", (start + window_size/2) / framerate, freq);

        vect = [ freq ; (start+window_size/2)/framerate ];
        freq_times = [ freq_times , vect ];

        % if start == 1 + 30*step
        %     plot(autocorr)
        %     [~, index2] = max(autocorr);
        %     disp(offset(index2));
        %     disp(framerate/offset(index2));
        % end
    end
    time = toc;%
    fprintf('Temps d''exécution : %.3f secondes\n', time);%
    fprintf('\n');%

    figure;
    plot(freq_times(2,:),freq_times(1,:));
    xlabel("Temps (s)");
    ylabel("Fréquence (Hz)");
    title("Fréquences détectées en fonction du temps");
    saveas(gcf, 'graphe_frequences.png');



    disp('Octave shifting of frequencies ...')
    tic;%
    freq_times(1, freq_times(1, :) >= 1000) = 0;

    for j = 1:size(freq_times,2)

        while (freq_times(1,j) <= 254.177 || freq_times(1,j) >= 508.355) && freq_times(1,j) ~= 0

            if freq_times(1,j) <= 254.177

                freq_times(1,j) = freq_times(1,j)*2;

            elseif freq_times(1,j) >= 508.355

                freq_times(1,j) = freq_times(1,j)/2;

            end
        end
    end
    time = toc;%
    fprintf('Temps d''exécution : %.3f secondes\n', time);%
    fprintf('\n');%
    % plot(freq_times(2,:),freq_times(1,:));
    % xlabel("Temps (s)");
    % ylabel("Fréquence (Hz)");
    % title("Fréquences détectées en fonction du temps");



    disp('Determination of the start of the same frequencies ...')
    tic;%
    frequencies = zeros(2,0);
    m = 1;

    while m <= size(freq_times,2)

        if freq_times(1,m) == 0

            m = m + 1;

        else

            start = m;
            m = m + 1;

            while m <= size(freq_times,2) && (freq_times(1,m) <= 1.0293 * freq_times(1,start) && freq_times(1,m) >= (1/1.0293) * freq_times(1,start))

                m=m+1;

            end

            if (m-1) - start >= 2

                vect = [ mean(freq_times(1,start:(m-1))) ; freq_times(2,start) ];
                frequencies = [ frequencies , vect ];

            end
        end
    end
    time = toc;%
    fprintf('Temps d''exécution : %.3f secondes\n', time);%
    fprintf('\n');%
end