% function frequences = detection_freq(signal, framerate, min_freq, max_freq, taille_fenetre, cheuvauchement)

%     % mediane=median(abs(signal));
%     % signal(signal<0.3*mediane)=0;

%     taille_fenetre=round(taille_fenetre*framerate);

%     if length(signal) < taille_fenetre
%         error("Le signal est trop court pour la taille de fenêtre spécifiée.");
%     end

%     disp('Recherche des fréquences ...');

%     cheuvauchement=round(cheuvauchement*framerate);
%     pas=taille_fenetre-cheuvauchement;

%     decal_min=floor(framerate/max_freq);
%     decal_max=ceil(framerate/min_freq);
%     disp(decal_min);
%     disp(min(decal_max, taille_fenetre-1));

%     axisx = decal_min:min(decal_max, taille_fenetre-1);
%     axisy = 1:pas:length(signal)-taille_fenetre;
%     frequences = zeros(length(axisx), length(axisy));

%     for n=1:length(axisy)%
%         start=axisy(n);%
%         autocorr=zeros(1, length(axisx));

%         for m=1:length(axisx)
%             k=axisx(m);
%             somme=0;

%             for i=1:taille_fenetre-k
%                 somme=somme+signal(start+i)*signal(start+i+k);
%             end

%             autocorr(m)=somme;
            
%         end
%         [~,indice]=max(autocorr);
%         autocorr(indice)=NaN;
%         frequences(:,n)=autocorr;

%     end

    
%     % Normalisation des valeurs
%     frequences = frequences / max(frequences(:));

%     % axisx = framerate ./ axisx; % Conversion des décalages en fréquences
%     % Affichage du spectrogramme
%     figure('Position', [100, 100, 800, 600]); % Taille de la figure
%     imagesc(axisy / framerate, axisx, frequences); % Inversion des axes pour une meilleure compréhension
%     colorbar; % Ajouter une barre de couleur
%     axis xy;  % Orientation classique
%     xlabel('Temps (s)'); % Label de l'axe des x
%     ylabel('Fréquences (Hz)'); % Label de l'axe des y
%     title('Spectrogramme du signal (Autocorrélation)'); % Titre
    
% end
function frequences2 = detection_freq(signal, framerate, min_freq, max_freq, taille_fenetre, cheuvauchement)

    % mediane=median(abs(signal));
    % signal(signal<0.3*mediane)=0;

    taille_fenetre=round(taille_fenetre*framerate);

    if length(signal) < taille_fenetre
        error("Le signal est trop court pour la taille de fenêtre spécifiée.");
    end

    disp('Recherche des fréquences ...');

    cheuvauchement=round(cheuvauchement*framerate);
    pas=taille_fenetre-cheuvauchement;

    decal_min=floor(framerate/max_freq);
    decal_max=ceil(framerate/min_freq);
    disp(decal_min);
    disp(min(decal_max, taille_fenetre-1));

    axisx = decal_min:min(decal_max, taille_fenetre-1);
    axisy = 1:pas:length(signal)-taille_fenetre;
    frequences1 = zeros(length(axisx), length(axisy));

    for n=1:length(axisy)%
        start=axisy(n);%
        autocorr=zeros(1, length(axisx));

        for m=1:length(axisx)
            k=axisx(m);
            somme=0;

            for i=1:taille_fenetre-k
                somme=somme+signal(start+i)*signal(start+i+k);
            end

            autocorr(m)=somme;
        end
        [~,indice]=max(autocorr);
        autocorr(indice)=NaN;
        frequences1(:,n)=autocorr;

    end

    
    % Normalisation des valeurs
    frequences1 = frequences1 / max(frequences1(:));
    frequences2 = zeros(max_freq-min_freq+1, length(axisy));
    range_freq = min_freq:max_freq;
    for i = 1:length(axisy)
        for j = 1:max_freq-min_freq+1
            freq = range_freq(j);
            frequences2(j,i)= frequences1(round(framerate/freq-framerate/max_freq+1),i);
        end
        frequences2(:,i) = frequences2(:,i)/max(frequences2(:,i));
    end
    % axisx = framerate ./ axisx; % Conversion des décalages en fréquences
    % Affichage du spectrogramme
    figure('Position', [100, 100, 800, 600]); % Taille de la figure
    imagesc(axisy/framerate, range_freq, frequences2); % Inversion des axes pour une meilleure compréhension
    colorbar; % Ajouter une barre de couleur
    axis xy;  % Orientation classique
    xlabel('Temps (s)'); % Label de l'axe des x
    ylabel('Fréquences (Hz)'); % Label de l'axe des y
    title('Spectrogramme du signal (Autocorrélation)'); % Titre
    
end