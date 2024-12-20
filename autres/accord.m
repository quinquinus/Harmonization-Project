function chords()

    notes = {'Do', 'Re', 'Mi', 'Do', 'Do', 'Re', 'Mi', 'Do', ...
        'Mi', 'Fa', 'Sol', 'Mi', 'Fa', 'Sol', ...
        'Sol', 'La', 'Sol', 'Fa', 'Mi', 'Do', 'Sol', 'La', 'Sol', 'Fa', 'Mi', 'Do', ...
        'Do', 'Sol', 'Do', 'Do', 'Sol', 'Do'; ...
        1,1.5,2,2.5,3,3.5,4,4.5,...
        5,5.5,6,7,7.5,8,...
        9,9.25,9.5,9.75,10,10.5, 11,11.25,11.5,11.75,12,12.5,...
        13,13.5,14,15,15.5,16};
    gamme_finale = {'Do Majeur',   {'Do', 'Re', 'Mi', 'Fa', 'Sol', 'La', 'Si'}};

    taille = size(notes,2);
    notes_deg = zeros(2, taille);

    ecarts_notes = cell2mat(notes(2,2:taille)) - cell2mat(notes(2,1:taille-1));
    min_long = mean(ecarts_notes(ecarts_notes<1.25*min(ecarts_notes)));
    noire = min_long;

    while noire < 60/160 || noire >= 60/80
        if noire < 60/160
            noire = noire * 2;
        else
            noire = noire / 2;
        end
    end

    disp('Détermination des accords ...')
    tic;

    for a = 1:taille
        notes_deg(1,a) = find(strcmp(gamme_finale{2},notes(1,a)));
        if mod(round((cell2mat(notes(2,a))-cell2mat(notes(2,1)))/noire*4)/4, 4)==0
            notes_deg(2,a) = -1;
        end
    end

    mod7 = @(x) mod(x-1,7)+1;

    function res = accord(i)
        res = [i,mod7(i+2),mod7(i+4)];
    end

    function res = prochaine_mesure(i)
        % res = i + 1;
        % if res > length(indice_mesure)
        %     return;
        % end
        res = min(i + 1, length(indice_mesure));
    end

    function res = precedente_mesure(i)
        % res = i - 1;
        % if res < 1
        %     return;
        % end
        res = max(i - 1, 1);
    end


    function indice = pattern_milieu(liste)
        indice = [];
        if length(liste) <= length(indice_mesure)
            i = 1;
            liste_accords = arrayfun(@accord, liste, 'UniformOutput', false);
            while i <= length(indice_mesure)-length(liste)+1
                notes_verif = num2cell(notes_deg(1,indice_mesure(i:i+length(liste)-1)));
                if all(notes_deg(2,indice_mesure(i:i+length(liste)-1))==-1) && all(cellfun(@(x, y) ismember(x, y), notes_verif, liste_accords))
                    indice = [indice, i];
                    i = i + length(liste);
                else
                    i = i + 1;
                end
            end
        end
    end

    % accords = [notes_deg; cell2mat(notes(2,:))];

    if ~any(notes_deg(2,:) == -1)
        disp('Aucun début de mesure semble détecté !');
        disp(round((notes(2,:)-notes(2,1))/noire*4)/4);
        return;
    else
        indice_mesure = find(notes_deg(2,:) == -1);
        
        % Début
        k = 1;

        if ismember(notes_deg(1,indice_mesure(k)),accord(1))
            notes_deg(2,indice_mesure(k)) = 1;

            k = prochaine_mesure(k);
            if ismember(notes_deg(1,indice_mesure(k)),accord(4))
                notes_deg(2,indice_mesure(k)) = 4;

                k = prochaine_mesure(k);
                if ismember(notes_deg(1,indice_mesure(k)),accord(5))
                    notes_deg(2,indice_mesure(k)) = 5;
                end

            elseif ismember(notes_deg(1,indice_mesure(k)),accord(5))
                notes_deg(2,indice_mesure(k)) = 5;
            end
        end
    
        % Fin
        k = length(indice_mesure);
        if all(ismember(notes_deg(1,indice_mesure(k):taille), accord(1)))
            notes_deg(2,indice_mesure(k)) = 1;

            k = precedente_mesure(k);
            if ismember(notes_deg(1,indice_mesure(k)), accord(5))
                notes_deg(2,indice_mesure(k)) = 5;

                k = precedente_mesure(k);
                if ismember(notes_deg(1,indice_mesure(k)), accord(2))
                    notes_deg(2,indice_mesure(k)) = 2;
                end

            elseif ismember(notes_deg(1,indice_mesure(k)), accord(4))
                notes_deg(2,indice_mesure(k)) = 4;
            end
        end
        
        if isempty(find(notes_deg(2,:) == -1, 1))
            return;
        end 

        % Milieu
        pattern = [4,5,1];
        indices = pattern_milieu(pattern);
        if ~isempty(indices)
            for b = 1:length(indices)
                notes_deg(2,indice_mesure(b:b+length(pattern))) = pattern;
            end
        end

        pattern = [1,6,2,5];
        indices = pattern_milieu(pattern);
        if ~isempty(indices)
            for b = 1:length(indices)
                notes_deg(2,indice_mesure(b:b+length(pattern))) = pattern;
            end
        end

        pattern = [6,4,1,5];
        indices = pattern_milieu(pattern);
        if ~isempty(indices)
            for b = 1:length(indices)
                notes_deg(2,indice_mesure(b:b+length(pattern))) = pattern;
            end
        end
        
        % Compléter
        if ~any(notes_deg(2,:) == -1)
            return;
        end
        if notes_deg(2,indice_mesure(1)) == -1
            notes_deg(2,indice_mesure(1)) = notes_deg(1,indice_mesure(1));
        end
        
        c = 2;
        
        while c <= length(indice_mesure)
            if notes_deg(2,indice_mesure(c)) == -1
                accord_precedent = accord(notes_deg(2,indice_mesure(c-1)));
                accord1 = accord(notes_deg(1,indice_mesure(c)));
                accord2 = accord(mod7(notes_deg(1,indice_mesure(c))-2));
                accord3 = accord(mod7(notes_deg(1,indice_mesure(c))-4));
                comp = [length(intersect(accord1, accord_precedent)), length(intersect(accord2, accord_precedent)), length(intersect(accord3, accord_precedent))];
                [~,indice] = max(comp);
                notes_deg(2,indice_mesure(c)) = mod(notes_deg(1,indice_mesure(c))+2-2*indice-1,7)+1;
            end
            c = c + 1;
        end
        
        if any(notes_deg(2,:) == -1)
            disp('Il reste des accords à compléter, problème de code !!');
        else
            disp('Tous les accords ont été ajoutés')
        end

        disp([notes_deg; cell2mat(notes(2,:))]);
        
    end

    time = toc;%
    fprintf('Temps d''exécution : %.3f secondes\n', time);%
    fprintf('\n');%
end

% début :
% 1-4
% 1-5
% 1-4-5

% fin :
% 5-1
% 4-1
% 2-5-1

% milieu :
% 4-5-1
% 1-6-2-5
% 6-4-1-5
chords();