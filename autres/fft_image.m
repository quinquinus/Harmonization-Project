function spectrogram_image = create_spectrogram(y, fs, windowSize, hopSize, freqMin, freqMax)
    % Fenêtre de Hanning
    hannWindow = 0.5 * (1 - cos(2 * pi * (0:windowSize-1)' / (windowSize-1)));
    
    % Nombre total de fenêtres
    numWindows = floor((length(y) - windowSize) / hopSize);
    
    % Liste pour stocker les spectres
    spectrogram_image = [];
    timeAxis = (0:numWindows-1) * hopSize / fs; % Temps en secondes
    
    % Analyse par fenêtres
    for i = 1:numWindows
        % Extraire une fenêtre du signal
        startIdx = (i - 1) * hopSize + 1;
        endIdx = startIdx + windowSize - 1;
        segment = y(startIdx:endIdx) .* hannWindow;
        
        % Calculer la FFT et garder les fréquences positives
        spectrum = abs(fft(segment));
        spectrum = spectrum(1:windowSize/2);
        freqs = (0:windowSize/2 - 1) * fs / windowSize;
        
        % Filtrer les fréquences entre freqMin et freqMax
        mask = (freqs >= freqMin) & (freqs <= freqMax);
        spectrum = spectrum(mask);
        freqs = freqs(mask);
        
        % Normaliser les amplitudes (optionnel pour visualisation)
        spectrum = spectrum / max(spectrum);
        
        % Ajouter ce spectre comme une colonne de l'image
        spectrogram_image = [spectrogram_image, spectrum];
    end
    
    % Visualisation de l'image
    figure;
    imagesc(timeAxis, freqs, spectrogram_image);
    axis xy; % Mettre l'origine des fréquences en bas
    colormap jet; % Palette de couleurs
    colorbar; % Afficher la légende des couleurs
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title('Spectrogram');
end

[y, fs] = audioread('results/harmonized_getlucky.wav'); % Charger un fichier audio
windowSize = 4096; % Taille de la fenêtre
hopSize = 2048;    % Chevauchement
freqMin = 200;     % Fréquence minimale (Hz)
freqMax = 1000;    % Fréquence maximale (Hz)
create_spectrogram(y, fs, windowSize, hopSize, freqMin, freqMax);