% function [peaks, locs] = findpeaks_manual(data, min_height, min_distance)
%     % Initialisation
%     peaks = [];
%     locs = [];
    
%     % Boucle sur les données pour détecter les pics locaux
%     for i = 2:length(data)-1
%         % Vérifie si c'est un pic local et si la hauteur est suffisante
%         if data(i) > data(i-1) && data(i) > data(i+1) && data(i) > min_height
%             % Si aucun pic n'a été trouvé ou si la distance minimale est respectée
%             if isempty(locs) || (i - locs(end)) >= min_distance
%                 peaks = [peaks, data(i)]; % Ajouter la valeur du pic
%                 locs = [locs, i];        % Ajouter l'indice du pic
%             elseif data(i) > peaks(end) % Si le pic actuel est plus grand que le dernier détecté
%                 % Remplace le dernier pic par le pic actuel
%                 peaks(end) = data(i);
%                 locs(end) = i;
%             end
%         end
%     end
% end

% % Charger le fichier audio
% [x, fs] = audioread('results/harmonized_getlucky.wav'); % x : signal, fs : fréquence d'échantillonnage
% x = mean(x, 2); % Convertir en mono si nécessaire

% % Paramètres STFT
% win_length = round(0.5 * fs); % Longueur de la fenêtre (500 ms)
% overlap = round(0.25 * fs); % Recouvrement (250 ms)
% nfft = 2^nextpow2(win_length); % Taille de la FFT

% % Initialisation
% win_length = round(0.5 * fs); % Longueur de la fenêtre (500 ms)
% window = 0.5 * (1 - cos(2 * pi * (0:win_length-1)' / (win_length-1))); % Fenêtre de Hann
% step = win_length - overlap; % Pas de la fenêtre
% num_frames = floor((length(x) - overlap) / step); % Nombre de fenêtres
% consonance_scores = zeros(1, num_frames); % Score de consonance pour chaque segment

% % Analyse segmentée
% for frame = 1:num_frames
%     % Extraire la fenêtre locale
%     start_idx = (frame - 1) * step + 1;
%     end_idx = start_idx + win_length - 1;
%     segment = x(start_idx:end_idx) .* window; % Appliquer la fenêtre

%     % FFT locale
%     X = fft(segment, nfft);
%     P = abs(X(1:nfft/2)); % Magnitude spectrale
%     f = (0:nfft/2-1) * (fs/nfft); % Échelle des fréquences

%     % Détection des pics
%     [peaks, locs] = findpeaks_manual(P, 0.2*max(P), 2*(fs/nfft)); % Ajustez le seuil et la distance minimale
%     frequencies = f(locs);

%     % Calcul des ratios
%     ratios = [];
%     for i = 1:length(frequencies)
%         for j = i+1:length(frequencies)
%             ratios = [ratios, frequencies(j)/frequencies(i)];
%         end
%     end

%     % Calcul de la consonance
%     consonant_ratios = [2, 3/2, 4/3, 5/4];
%     tolerance = 0.05; % Tolérance pour les ratios
%     is_consonant = false(size(ratios));
%     for k = 1:length(ratios)
%         is_consonant(k) = any(abs(ratios(k) - consonant_ratios) < tolerance);
%     end
%     consonance_scores(frame) = sum(is_consonant) / length(ratios); % Proportion de consonance
% end

% % Afficher les scores de consonance dans le temps
% time = (0:num_frames-1) * (step / fs);
% plot(time, consonance_scores);
% xlabel('Temps (s)');
% ylabel('Consonance (%)');
% title('Consonance temporelle');

% % % Charger le fichier audio
% % [x, fs] = audioread('results/harmonized_getlucky.wav'); % x : signal, fs : fréquence d'échantillonnage

% % % Appliquer la FFT
% % N = length(x); % Taille du signal
% % X = fft(x); % Transformée de Fourier
% % f = (0:N-1)*(fs/N); % Échelle des fréquences
% % P = abs(X); % Amplitude spectrale

% % N2 = length(X); % Nombre de points dans la FFT
% % delta_f = fs / N2; % Résolution fréquentielle
% % min_distance = 2 * delta_f; % Distance minimale (par exemple 2 fois la résolution)

% % % Identifier les pics dominants
% % [peaks, locs] = findpeaks_manual(P, 0.2*max(P), min_distance); % Ajustez le seuil

% % % Extraire les fréquences dominantes
% % frequencies = f(locs);

% % % Calculer les ratios entre les fréquences dominantes
% % ratios = [];
% % for i = 1:length(frequencies)
% %     for j = i+1:length(frequencies)
% %         ratios = [ratios, frequencies(j)/frequencies(i)];
% %     end
% % end

% % % Comparer aux ratios consonants
% % consonant_ratios = [2, 3/2, 4/3, 5/4];
% % tolerance = 0.05; % Tolérance pour les ratios
% % is_consonant = false(size(ratios));

% % for k = 1:length(ratios)
% %     is_consonant(k) = any(abs(ratios(k) - consonant_ratios) < tolerance);
% % end

% % % Calculer la proportion de consonance
% % proportion_consonance = sum(is_consonant) / length(ratios);
% % disp(['Consonance : ', num2str(proportion_consonance*100), '%']);

% % % , 'MinPeakDistance', 10


function consonance_general = calculate_consonance(audio_file)
    % Charger le fichier audio
    [x, fs] = audioread(audio_file); % x : signal, fs : fréquence d'échantillonnage
    x = mean(x, 2); % Convertir en mono si nécessaire

    % Paramètres STFT
    win_length = round(0.5 * fs); % Longueur de la fenêtre (500 ms)
    overlap = round(0.25 * fs); % Recouvrement (250 ms)
    nfft = 2^nextpow2(win_length); % Taille de la FFT
    window = 0.5 * (1 - cos(2 * pi * (0:win_length-1)' / (win_length-1))); % Fenêtre de Hann
    step = win_length - overlap; % Pas de la fenêtre
    num_frames = floor((length(x) - overlap) / step); % Nombre de fenêtres

    % Initialisation
    consonance_scores = zeros(1, num_frames); % Score de consonance pour chaque segment

    % Analyse segmentée
    for frame = 1:num_frames
        % Extraire la fenêtre locale
        start_idx = (frame - 1) * step + 1;
        end_idx = start_idx + win_length - 1;

        if end_idx > length(x)
            segment = x(start_idx:end); % Dernière fenêtre si incomplète
            segment = [segment; zeros(win_length - length(segment), 1)]; % Zero-padding
        else
            segment = x(start_idx:end_idx);
        end

        segment = segment .* window; % Appliquer la fenêtre de Hann

        % FFT locale
        X = fft(segment, nfft);
        P = abs(X(1:nfft/2)); % Magnitude spectrale
        f = (0:nfft/2-1) * (fs/nfft); % Échelle des fréquences

        % Détection des pics
        [peaks, locs] = findpeaks_manual(P, 0.2*max(P), 2*(fs/nfft)); % Ajustez le seuil et la distance minimale
        frequencies = f(locs);

        % Calcul des ratios
        ratios = [];
        for i = 1:length(frequencies)
            for j = i+1:length(frequencies)
                ratios = [ratios, frequencies(j)/frequencies(i)];
            end
        end

        % Calcul de la consonance
        consonant_ratios = [2, 3/2, 4/3, 5/4];
        tolerance = 0.05; % Tolérance pour les ratios
        is_consonant = false(size(ratios));
        for k = 1:length(ratios)
            is_consonant(k) = any(abs(ratios(k) - consonant_ratios) < tolerance);
        end
        if ~isempty(ratios)
            consonance_scores(frame) = sum(is_consonant) / length(ratios); % Proportion de consonance
        else
            consonance_scores(frame) = 0; % Si aucun ratio calculé, score = 0
        end
    end

    % Calcul de la consonance générale
    consonance_general = mean(consonance_scores) * 100; % Moyenne sur toutes les fenêtres
    fprintf('Consonance générale : %.2f%%\n', consonance_general);
end

function [peaks, locs] = findpeaks_manual(data, min_height, min_distance)
    % Initialisation
    peaks = [];
    locs = [];
    
    % Boucle sur les données pour détecter les pics locaux
    for i = 2:length(data)-1
        % Vérifie si c'est un pic local et si la hauteur est suffisante
        if data(i) > data(i-1) && data(i) > data(i+1) && data(i) > min_height
            % Si aucun pic n'a été trouvé ou si la distance minimale est respectée
            if isempty(locs) || (i - locs(end)) >= min_distance
                peaks = [peaks, data(i)]; % Ajouter la valeur du pic
                locs = [locs, i];        % Ajouter l'indice du pic
            elseif data(i) > peaks(end) % Si le pic actuel est plus grand que le dernier détecté
                % Remplace le dernier pic par le pic actuel
                peaks(end) = data(i);
                locs(end) = i;
            end
        end
    end
end

% calculate_consonance('results/harmonized_birds.wav');
calculate_consonance('audio/birds_moche.wav');
