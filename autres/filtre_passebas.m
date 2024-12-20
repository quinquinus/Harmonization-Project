function signal_filtre = filtre_passebas(signal, framerate, fc)

    % Filtrage passe-bas segmenté pour éviter les problèmes de mémoire
    %
    % Paramètres :
    % signal : Signal audio d'entrée (vecteur)
    % fs : Fréquence d'échantillonnage (en Hz)
    % fc : Fréquence de coupure (en Hz)
    %
    % Retour :
    % signal_filtre : Signal filtré

    % Taille du segment
    segment_size = 2^16; % Taille d'un segment (par ex. 65536 points)
    N = length(signal);

    % Initialisation du signal filtré
    signal_filtre = zeros(size(signal));

    % Traiter le signal par segments
    for start_idx = 1:segment_size:N
        % Indices pour le segment actuel
        end_idx = min(start_idx + segment_size - 1, N);
        segment = signal(start_idx:end_idx);

        % Transformée de Fourier rapide (FFT) du segment
        spectre = fft(segment);

        % Nombre de points dans ce segment
        segment_length = length(segment);

        % Création du filtre passe-bas pour ce segment
        freqs = (0:segment_length-1) * (framerate / segment_length); % Fréquences associées
        filtre = freqs <= fc; % 1 pour les fréquences <= fc, 0 sinon

        % Appliquer le filtre dans le domaine fréquentiel
        spectre_filtre = spectre .* filtre;

        % Transformée de Fourier inverse (IFFT) pour revenir au domaine temporel
        segment_filtre = real(ifft(spectre_filtre));

        % Sauvegarder le segment filtré
        signal_filtre(start_idx:end_idx) = segment_filtre;
    end

    % Normalisation pour éviter les dépassements d'amplitude
    signal_filtre = signal_filtre / max(abs(signal_filtre));
end