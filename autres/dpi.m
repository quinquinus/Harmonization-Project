function dpi_global = calculateDPI(N, pixel_width, pixel_height)
    % Fonction pour calculer le DPI global d'une image pour un format AN
    % Entrées :
    %   N : numéro du format AN (0 pour A0, 1 pour A1, etc.)
    %   pixel_width : largeur de l'image en pixels
    %   pixel_height : hauteur de l'image en pixels
    % Sortie :
    %   dpi_global : résolution DPI globale (moyenne largeur et hauteur)
    
    % Dimensions de base du format A0 (en mètres)
    width_A0 = 0.841; % largeur en mètres
    height_A0 = 1.189; % hauteur en mètres
    
    % Calcul des dimensions du format AN (en mètres)
    width_AN = width_A0 / 2^(N/2);
    height_AN = height_A0 / 2^(N/2);
    
    % Conversion des dimensions en pouces (1 mètre = 39.3701 pouces)
    width_AN_inches = width_AN * 39.3701;
    height_AN_inches = height_AN * 39.3701;
    
    % Calcul des DPI pour largeur et hauteur
    dpi_width = pixel_width / width_AN_inches;
    dpi_height = pixel_height / height_AN_inches;
    
    % Calcul du DPI global (moyenne)
    dpi_global = (dpi_width + dpi_height) / 2;
    
    % Affichage des résultats
    fprintf('Format A%d:\n', N);
    fprintf('Dimensions physiques : %.2f x %.2f centimètres\n', width_AN*100, height_AN*100);
    fprintf('DPI (largeur) : %.2f\n', dpi_width);
    fprintf('DPI (hauteur) : %.2f\n', dpi_height);
    fprintf('DPI global : %.2f\n', dpi_global);
end

calculateDPI(1, 2836, 3545);