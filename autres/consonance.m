% function harmonyScore = evaluate_harmony(filename)
%     % Charger le fichier audio
%     [y, fs] = audioread(filename);
%     if size(y, 2) > 1
%         y = mean(y, 2); % Convertir en mono si stéréo
%     end

%     % Normaliser le signal si l'amplitude est faible
%     if max(abs(y)) < 0.5
%         disp('Warning: Normalizing signal to improve detection.');
%         y = y / max(abs(y));
%     end

%     % Vérification de l'amplitude du signal
%     disp(['Signal max amplitude: ', num2str(max(y))]);
%     disp(['Signal min amplitude: ', num2str(min(y))]);

%     % Paramètres d'analyse
%     windowSize = 4096; % Taille des fenêtres d'analyse
%     hopSize = 2048;    % Recouvrement partiel entre fenêtres
%     numWindows = floor((length(y) - windowSize) / hopSize);
%     harmonyScores = zeros(1, numWindows);
%     roughnessScores = zeros(1, numWindows);
%     consonanceScores = zeros(1, numWindows);

%     % Générer une fenêtre de Hanning manuellement
%     hannWindow = 0.5 * (1 - cos(2 * pi * (0:windowSize-1)' / (windowSize-1)));

%     % Fenêtrage et analyse spectrale
%     for i = 1:numWindows
%         % Extraire une fenêtre du signal
%         startIdx = (i - 1) * hopSize + 1;
%         endIdx = startIdx + windowSize - 1;
%         segment = y(startIdx:endIdx) .* hannWindow; % Appliquer la fenêtre de Hanning

%         % Calculer la FFT
%         spectrum = abs(fft(segment));
%         freqs = (0:windowSize/2 - 1) * fs / windowSize;
%         spectrum = spectrum(1:windowSize/2); % Garder uniquement les fréquences positives

%         % Vérifier si le spectre est trop faible
%         if max(spectrum) < 1e-3
%             % disp(['Window ', num2str(i), ': Spectrum too weak. Skipping.']);
%             harmonyScores(i) = 0; % Score par défaut
%             continue;
%         end

%         % Détecter les fréquences dominantes avec seuil ajusté
%         [peaks, locs] = manual_findpeaks(spectrum, 0.01 * max(spectrum), 20);
%         dominantFreqs = freqs(locs);

%         % Vérifier les fréquences détectées
%         % if isempty(dominantFreqs)
%         %     disp(['Window ', num2str(i), ': Detected frequencies - None']);
%         % else
%         %     disp(['Window ', num2str(i), ': Detected frequencies - ', ...
%         %         strjoin(arrayfun(@num2str, dominantFreqs, 'UniformOutput', false), ', ')]);
%         % end

%         % Si pas de fréquences détectées, passer à la fenêtre suivante
%         if isempty(dominantFreqs)
%             harmonyScores(i) = 0; % Score par défaut
%             continue;
%         end

%         % Calculer la rugosité (roughness)
%         roughness = calculate_roughness(dominantFreqs);

%         % Calculer les intervalles
%         intervals = calculate_intervals(dominantFreqs);
%         consonance = evaluate_consonance(intervals);

%         spectralDensity = length(dominantFreqs) / length(spectrum);

%         disp(['Window ', num2str(i), ': Roughness = ', num2str(roughness), ...
%       ', Consonance = ', num2str(consonance)]);

%         % Combiner les métriques
%         harmonyScores(i) = max(0, min(1, 1 - roughness + consonance + 0.2 * spectralDensity));
%         roughnessScores(i) = roughness;
%         consonanceScores(i) = consonance;
%     end

%     % Score final
%     harmonyScore = min(100, mean(harmonyScores) * 100); % Convertir en pourcentage
%     disp(['Harmony Score: ', num2str(harmonyScore), '%']);

%     % Visualisation des scores dans le temps
%     time = (0:numWindows-1) * (hopSize / fs);
%     if length(time) > 1000
%         step = ceil(length(time) / 100); % Limiter à 1000 points
%         time = time(1:step:end);
%         harmonyScores = harmonyScores(1:step:end);
%         roughnessScores = roughnessScores(1:step:end);
%         consonanceScores = consonanceScores(1:step:end);
%     end
%     windowedAverage1 = movmean(harmonyScores, 5); % Moyenne glissante sur 10 fenêtres
%     figure;
%     plot(time, windowedAverage1, 'LineWidth', 1.5);
%     xlabel('Time (s)');
%     ylabel('Harmony Score (Smoothed)');
%     title('Smoothed Harmony Score Over Time');
%     grid on;

%     % Graphique de la rugosité
%     windowedAverage2 = movmean(roughnessScores, 5);
%     figure;
%     plot(time, windowedAverage2, 'LineWidth', 1.5);
%     xlabel('Time (s)');
%     ylabel('Roughness');
%     title('Roughness Over Time');
%     grid on;

%     % Graphique de la consonance
%     windowedAverage3 = movmean(consonanceScores, 5);
%     figure;
%     plot(time, windowedAverage3, 'LineWidth', 1.5);
%     xlabel('Time (s)');
%     ylabel('Consonance');
%     title('Consonance Over Time');
%     grid on;
% end


% function [peaks, locs] = manual_findpeaks(signal, minHeight, minDistance)
%     % Détecter les pics manuellement
%     peaks = [];
%     locs = [];
%     len = length(signal);
    
%     for i = 2:len-1
%         % Vérifier si c'est un maximum local
%         if signal(i) > signal(i-1) && signal(i) > signal(i+1) && signal(i) >= minHeight
%             if isempty(locs) || (i - locs(end)) >= minDistance
%                 locs = [locs, i]; % Ajouter la position du pic
%                 peaks = [peaks, signal(i)]; % Ajouter la valeur du pic
%             end
%         end
%     end
% end

% function roughness = calculate_roughness(freqs)
%     % Mesurer la rugosité entre les fréquences dominantes

%     if isempty(freqs)
%         disp('No frequencies passed to calculate_roughness.');
%         roughness = NaN;
%         return;
%     end

%     roughness = 0;
%     for i = 1:length(freqs)
%         for j = i+1:length(freqs)
%             diff = abs(freqs(i) - freqs(j));
%             roughness = roughness + exp(-diff / 5); % Modèle simplifié
%         end
%     end
%     roughness = roughness / (length(freqs) * (length(freqs) - 1) + 1e-6);
% end

% function intervals = calculate_intervals(freqs)
%     % Calculer les intervalles en demi-tons

%     if length(freqs) < 2
%         % disp('Not enough frequencies to calculate intervals.');
%         intervals = [];
%         return;
%     end

%     intervals = [];
%     for i = 1:length(freqs)
%         for j = i+1:length(freqs)
%             interval = 12 * log2(freqs(j) / freqs(i));
%             intervals = [intervals, abs(interval)];
%         end
%     end
% end

% function consonance = evaluate_consonance(intervals)
%     % Évaluer la consonance basée sur des intervalles harmoniques

%     if isempty(intervals)
%         % disp('No intervals to evaluate consonance.');
%         consonance = 0;
%         return;
%     end

%     consonantIntervals = [0, 3, 4, 5, 7, 8, 12]; % Intervalles en demi-tons (unison, tierce, quinte, octave)
%     consonance = 0;
%     weights = [1.5, 1.2, 1, 0.8, 1.5, 1.3, 1.7]; % Pondérations pour [unison, tierce, quinte, etc.]
%     for interval = intervals
%         [minDiff, idx] = min(abs(interval - consonantIntervals));
%         if minDiff < 0.5
%             consonance = consonance + weights(idx);
%         end
%     end
%     consonance = consonance / length(intervals) + 1e-6;
% end


function harmonyScore = evaluate_harmony(filename)
    % Charger le fichier audio
    [y, fs] = audioread(filename);
    if size(y, 2) > 1
        y = mean(y, 2); % Convertir en mono si stéréo
    end

    % Paramètres d'analyse
    windowSize = 4096; % Taille des fenêtres d'analyse
    hopSize = 2048;    % Recouvrement partiel entre fenêtres
    numWindows = floor((length(y) - windowSize) / hopSize);
    harmonyScores = zeros(1, numWindows);

    % Générer une fenêtre de Hanning manuellement
    hannWindow = 0.5 * (1 - cos(2 * pi * (0:windowSize-1)' / (windowSize-1)));

    % Fenêtrage et analyse spectrale
    for i = 1:numWindows
        % Extraire une fenêtre du signal
        startIdx = (i - 1) * hopSize + 1;
        endIdx = startIdx + windowSize - 1;
        segment = y(startIdx:endIdx) .* hannWindow; % Appliquer la fenêtre de Hanning

        % Calculer la FFT
        spectrum = abs(fft(segment));
        freqs = (0:windowSize/2 - 1) * fs / windowSize;
        spectrum = spectrum(1:windowSize/2); % Garder uniquement les fréquences positives

        % Détection du pic dominant dans [508, 1000] Hz
        mask_high = (freqs >= 508) & (freqs <= 1000);
        if any(mask_high)
            [maxHighPeak, maxHighIdx] = max(spectrum(mask_high));
            freq_high = freqs(mask_high);
            freq508_1000 = freq_high(maxHighIdx); % Pic dans la plage [508, 1000]
        else
            harmonyScores(i) = 0; % Pas de pic détecté dans cette plage
            continue;
        end

        % Détection des 3 pics dominants dans [200, 508] Hz
        mask_low = (freqs >= 200) & (freqs <= 508);
        if any(mask_low)
            [peaks, locs] = manual_findpeaks(spectrum(mask_low), 0.01 * max(spectrum(mask_low)), 3);
            freqs_low = freqs(mask_low);
            if length(peaks) < 3
                harmonyScores(i) = 0; % Pas assez de pics
                continue;
            end
            [~, sortedIdx] = sort(peaks, 'descend');
            freq200_508 = freqs_low(locs(sortedIdx(1:3))); % 3 pics les plus forts
        else
            harmonyScores(i) = 0; % Pas de pics détectés dans cette plage
            continue;
        end

        % Calcul de la consonance entre freq508_1000 et les 3 pics dans freq200_508
        consonances = zeros(1, 3);
        for j = 1:3
            consonances(j) = evaluate_2note_consonance(freq508_1000, freq200_508(j));
        end

        % Score de consonance moyen pour cette fenêtre
        if isempty(consonances(consonances ~= 0))
            harmonyScores(i) = 0; % Si aucune consonance valide, attribuer un score de 0
        else
            harmonyScores(i) = mean(consonances(consonances ~= 0)); % Calculer la moyenne
        end
    end

    % Calcul du score de consonance général
    harmonyScore = mean(harmonyScores(harmonyScores ~= 0)) * 100; % Convertir en pourcentage
    fprintf('Harmony Score: %.2f%%\n', harmonyScore);
end

function consonance = evaluate_2note_consonance(freq1, freq2)
    % Évaluer la consonance entre deux fréquences
    interval = 12 * log2(freq2 / freq1); % Intervalle en demi-tons
    consonantIntervals = [-24, -19, -15, -12, -8, -7, -5, -4, -3, 0, 3, 4, 5, 7, 8, 12, 15, 19, 24]; % Demi-tons consonants
    weights = [2.0, 1.4, 1.2, 1.7, 1.3, 1.5, 0.8, 1, 1.2, 1.5, 1.2, 1.0, 0.8, 1.5, 1.3, 1.7, 1.4, 1.2, 2.0]; % Pondérations
    [minDiff, idx] = min(abs(interval - consonantIntervals));
    % disp(abs(interval - consonantIntervals));
    % disp(minDiff);
    if minDiff < 0.5
        consonance = weights(idx);
    else
        consonance = 0; % Dissonance si hors des seuils
    end
    consonance = max(0, min(1, consonance / max(weights))); % Normaliser entre 0 et 1
end

function [peaks, locs] = manual_findpeaks(signal, minHeight, minDistance)
    % Détecter les pics manuellement
    peaks = [];
    locs = [];
    len = length(signal);

    for i = 2:len-1
        % Vérifier si c'est un maximum local
        if signal(i) > signal(i-1) && signal(i) > signal(i+1) && signal(i) >= minHeight
            if isempty(locs) || (i - locs(end)) >= minDistance
                locs = [locs, i]; % Ajouter la position du pic
                peaks = [peaks, signal(i)]; % Ajouter la valeur du pic
            end
        end
    end
end



evaluate_harmony('results/harmonized_birds.wav');
% fprintf('Bien harmonisé : %.2f', harmony_score1);
evaluate_harmony('audio/birds_moche.wav');
% fprintf('Mal harmonisé : %.2f', harmony_score2);


