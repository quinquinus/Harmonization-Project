disp('MATLAB running');
fprintf('\n');fprintf('\n');
set(0, 'DefaultFigureVisible', 'off');

cd ..;
addpath('./code');

subfolder = './references';

files = dir(fullfile(subfolder, '*.m'));

for k = 1:length(files)
    scriptPath = fullfile(subfolder, files(k).name);
    try
        run(scriptPath);
    catch ME
        fprintf('Error running %s: %s\n', scriptPath, ME.message);
    end
end

run('inputs/data_scales.m');

subfolder = './inputs/audio';
filename = './inputs/audios.txt';
fileID = fopen(filename, 'r');
fileNames = textscan(fileID, '%s');
fileNames = fileNames{1};
fclose(fileID);

for i = 1:size(fileNames, 1)
    filename = [fileNames{i}, '.wav'];
    file_path = fullfile(subfolder, filename);

    if ~isfile(file_path)
        fprintf('The file %s does not exist in the subfolder %s.\n', filename, subfolder);
        return;
    end

    fprintf('File processing : %s\n', filename);
    [signal, framerate] = audioread(file_path);
    signal = double(signal)';

    if size(signal,1)==1
        disp("The signal is in mono.");
    elseif size(signal,1)==2
        disp("The signal is in stereo.");
        signal = mean(signal, 1);
        disp("Converted to mono.");
    end

    % Paramètres pour la fonction de détection
    min_freq = 50; % Fréquence minimale à détecter (Hz)
    max_freq = 1000; % Fréquence maximale à détecter (Hz)
    window_size = 0.05; % Taille de fenêtre (10 % du framerate)
    overlap = 0.025; % Chevauchement de 5 % du framerate

    % Appel de la fonction de détection
    [chords, final_scale] = chords_determination(signal, framerate, min_freq, max_freq, window_size, overlap, fileNames{i});

    note_frequencies = struct( ...
        'Do', 261.625, ...
        'Dod', 277.182, ...
        'Re', 293.664, ...
        'Red', 311.126, ...
        'Mi', 329.627, ...
        'Fa', 349.228, ...
        'Fad', 369.994, ...
        'Sol', 391.995, ...
        'Sold', 415.304, ...
        'La', 440.000, ...
        'Lad', 466.163, ...
        'Si', 493.883);

    notes_name = fieldnames(note_frequencies)';
    notes_value = cell2mat(struct2cell(note_frequencies))';
    [~,indexes_freq] = ismember(final_scale{2}, notes_name);
    frequencies_scale = notes_value(indexes_freq);
    output = [frequencies_scale, reshape(chords', 1, [])];
    fprintf(2, '%d ', size(chords,2));
    fprintf(2, '%.3f ', output);
    fprintf(2, '\n');

    fprintf('\n');fprintf('\n');
end

disp('MATLAB has finished running');
fprintf('\n');fprintf('\n');

disp('Starting C ...');
fprintf('\n');