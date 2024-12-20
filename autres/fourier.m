function filtre = transf_fourier(signal, framerate, freq_range, pas, n)
    % S'assurer que la longueur du signal est un multiple de n
    signal = signal(1:floor(length(signal)/n)*n);

    % Définir les axes
    axisx = freq_range(1):pas:freq_range(2); % Axe des fréquences
    axisy = 1:n:length(signal);              % Axe des segments temporels

    % Initialisation de la matrice du filtre
    filtre = zeros(length(axisx), length(axisy));

    % Calcul des composantes spectrales
    for i = 1:length(axisx)
        freq = axisx(i);
        for j = 1:length(axisy)
            debut = axisy(j);

            % Calcul des composantes cosinus et sinus
            k = 0:n-1;
            x = sum(signal(debut:debut+n-1) .* cos(k .* (2 * pi * freq / framerate)));
            y = sum(signal(debut:debut+n-1) .* sin(k .* (2 * pi * freq / framerate)));
            e = sum(signal(debut:debut+n-1).^2);
            f = sqrt(2 * (x^2 + y^2) / (e * n));

            % Stocker la valeur
            filtre(i, j) = f;
        end
    end

    % Normalisation des valeurs
    filtre = filtre / max(filtre(:));

    % Affichage du spectrogramme
    figure('Position', [100, 100, 800, 600]); % Taille de la figure
    imagesc(axisy / framerate, axisx, filtre); % Inversion des axes pour une meilleure compréhension
    colorbar; % Ajouter une barre de couleur
    axis xy;  % Orientation classique
    xlabel('Temps (s)'); % Label de l'axe des x
    ylabel('Fréquences (Hz)'); % Label de l'axe des y
    title('Spectrogramme du signal (Transformée de Fourier)'); % Titre

    %%%

    % Test sur une seule colonne
    % moy = 3;
    % kernel = ones(1,moy)/moy;
    % colonne = filtre(:, 1); % Première colonne
    % smoothed_colonne = conv(colonne, kernel, 'same'); % Convolution 1D verticale
    % disp(smoothed_colonne);

    moy_col = 30;
    kernel_col = ones(moy_col,1)/moy_col;
    moy_row = 3;
    kernel_row = ones(1,moy_row)/moy_row;
    filtre = conv2(filtre, kernel_col, 'same');
    filtre = conv2(filtre, kernel_row, 'same');

    % Normalisation des valeurs
    filtre = filtre / max(filtre(:));
    filtre(filtre<0.2)=0;

    % for a = round(size(filtre, 1)/2):size(filtre, 1)
    %     % Initialiser la somme pour cette ligne
    %     somme = filtre(a, :); % Commencer avec la ligne courante
        
    %     % Ajouter les lignes divisées si elles sont valides
    %     if round(a/2) >= 1 && round(a/2) <= size(filtre, 1)
    %         somme = somme + filtre(round(a/2), :);
    %     end
    %     if round(a/4) >= 1 && round(a/4) <= size(filtre, 1)
    %         somme = somme + filtre(round(a/4), :);
    %     end
    %     if round(a/8) >= 1 && round(a/8) <= size(filtre, 1)
    %         somme = somme + filtre(round(a/8), :);
    %     end
        
    %     % Assigner la somme à la ligne courante
    %     filtre(a, :) = somme;
    % end
    % filtre = filtre(round(size(filtre, 1)/2):size(filtre, 1));

    % Affichage du spectrogramme
    figure('Position', [100, 100, 800, 600]); % Taille de la figure
    imagesc(axisy / framerate, axisx, filtre); % Inversion des axes pour une meilleure compréhension
    colorbar; % Ajouter une barre de couleur
    axis xy;  % Orientation classique
    xlabel('Temps (s)'); % Label de l'axe des x
    ylabel('Fréquences (Hz)'); % Label de l'axe des y
    title('Spectrogramme du signal (Transformée de Fourier)'); % Titre

end


chemin_script = fileparts(mfilename('fullpath'));
sous_dossier = fullfile(chemin_script, 'audio');
nom_fichier = 'coq.wav';
chemin_fichier = fullfile(sous_dossier, nom_fichier);
if ~isfile(chemin_fichier)
    fprintf('Le fichier %s n''existe pas dans le sous-dossier %s.\n', nom_fichier, sous_dossier);
    return;
end
fprintf('Traitement du fichier : %s\n', nom_fichier);

[signal, framerate] = audioread(chemin_fichier);
signal = double(signal)';

if size(signal,1)==1
    disp("le signal est en mono.");
elseif size(signal,1)==2
    disp("le signal est en stéréo.");
    signal = mean(signal, 1);
    disp("Converti en mono.");
end


freq = [50 2000];
pas = 1;
n = 1000;
transf_fourier(signal, framerate, freq, pas, n);


% function detect_notes(signal, framerate)
%     % Paramètres de découpage
%     window_size = round(0.05 * framerate); % Taille de fenêtre : 50 ms
%     overlap = round(0.025 * framerate);    % Chevauchement : 25 ms
%     step = window_size - overlap;          % Pas de fenêtre

%     % Table des fréquences des notes
%     note_frequencies = struct( ...
%         'C4', 261.63, ...
%         'D4', 293.66, ...
%         'E4', 329.63, ...
%         'F4', 349.23, ...
%         'G4', 392.00, ...
%         'A4', 440.00, ...
%         'B4', 493.88);

%     % Découper et analyser chaque fenêtre
%     num_windows = floor((length(signal) - window_size) / step);
%     times = zeros(1, num_windows);  % Temps au centre des fenêtres
%     detected_notes = cell(1, num_windows); % Notes détectées

%     for i = 1:num_windows
%         % Indices de la fenêtre actuelle
%         idx_start = (i-1)*step + 1;
%         idx_end = idx_start + window_size - 1;

%         % Extraire la fenêtre
%         segment = signal(idx_start:idx_end);
%         times(i) = (idx_start + idx_end) / 2 / framerate; % Temps au centre

%         % Estimer la fréquence fondamentale
%         freq = estimate_pitch_autocorr(segment, framerate);

%         % Trouver la note correspondante
%         detected_notes{i} = find_closest_note(freq, note_frequencies);
%     end

%     % Afficher les résultats
%     for i = 1:num_windows
%         fprintf('Temps : %.2f s, Note détectée : %s\n', times(i), detected_notes{i});
%     end
% end

% function freq = estimate_pitch_autocorr(segment, framerate)
%     % Appliquer une fenêtre de Hamming
%     segment = segment .* (0.54 - 0.46 * cos(2 * pi * (0:length(segment)-1) / (length(segment)-1)))';

%     % Définir le décalage maximum pour l'auto-corrélation
%     max_lag = round(framerate / 50); % Limiter à 50 Hz minimum

%     % Calcul manuel de l'auto-corrélation
%     autocorr_result = zeros(1, max_lag + 1);
%     for lag = 0:max_lag
%         autocorr_result(lag + 1) = sum(segment(1:end-lag) .* segment(1+lag:end));
%     end

%     % Trouver le premier pic significatif
%     [~, peak_index] = max(autocorr_result(2:end));
%     peak_index = peak_index + 1;

%     % Calculer la fréquence fondamentale
%     freq = framerate / peak_index;
% end

% function note = find_closest_note(frequency, note_frequencies)
%     % Trouver la note la plus proche
%     if isnan(frequency)
%         note = 'Unknown';
%         return;
%     end
%     note = 'Unknown';
%     min_diff = inf;
%     fields = fieldnames(note_frequencies);
%     for i = 1:length(fields)
%         diff = abs(frequency - note_frequencies.(fields{i}));
%         if diff < min_diff
%             min_diff = diff;
%             note = fields{i};
%         end
%     end
% end

% % Exemple d'utilisation
% [signal, framerate] = audioread('plusieurs_notes.wav');
% if size(signal, 2) > 1
%     signal = mean(signal, 2); % Convertir en mono
% end
% detect_notes(signal, framerate);



% -------------------------------------------------------------------------------------------------------------------------



% % Paramètres de la sinusoïde
% fs = 44100; % Fréquence d'échantillonnage (Hz)
% f_test = 440; % Fréquence de la sinusoïde (Hz) - LA4
% duration = 2; % Durée du signal (secondes)

% % Générer la sinusoïde
% t = 0:1/fs:duration; % Vecteur temps
% signal = sin(2 * pi * f_test * t); % Signal sinusoïdal pur

% % Paramètres pour la fonction de détection
% min_freq = 50; % Fréquence minimale à détecter (Hz)
% max_freq = 1000; % Fréquence maximale à détecter (Hz)
% taille_fenetre = 0.1; % Taille de fenêtre (10 % du framerate)
% cheuvauchement = 0.05; % Chevauchement de 5 % du framerate

% % Appel de la fonction de détection
% detection_frequence(signal, fs, min_freq, max_freq, taille_fenetre, cheuvauchement);


