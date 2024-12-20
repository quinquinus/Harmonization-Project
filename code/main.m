% Display a message indicating MATLAB has started running
disp('MATLAB running');
fprintf('\n'); fprintf('\n');

% Disable the visibility of all figures (useful for headless processing)
set(0, 'DefaultFigureVisible', 'off');

% Navigate to the parent directory
cd ..;

% Add the 'code' folder to MATLAB's search path to ensure access to its functions
addpath('./code');

% Define the subfolder containing reference files
subfolder = './references';

% List all .m files in the 'references' subfolder
files = dir(fullfile(subfolder, '*.m'));

% Loop through all detected .m files in the 'references' folder and run them
for k = 1:length(files)
    scriptPath = fullfile(subfolder, files(k).name); % Full path to the script
    try
        run(scriptPath); % Execute the script
    catch ME
        fprintf('Error running %s: %s\n', scriptPath, ME.message);
    end
end

% Run the 'data_scales.m' script from the 'inputs' folder
run('inputs/data_scales.m');

% Define the subfolder containing audio files
subfolder = './inputs/audio';

% Read the list of audio filenames from 'audios.txt'
filename = './inputs/audios.txt';
fileID = fopen(filename, 'r');
fileNames = textscan(fileID, '%s'); % Extract file names as a cell array
fileNames = fileNames{1};
fclose(fileID);

% Loop through all audio files listed in 'audios.txt'
for i = 1:size(fileNames, 1)
    filename = [fileNames{i}, '.wav'];
    file_path = fullfile(subfolder, filename);

    % Check if the audio file exists in the specified subfolder
    if ~isfile(file_path)
        fprintf('The file %s does not exist in the subfolder %s.\n', filename, subfolder);
        return;
    end

    % Display a message indicating which file is being processed
    fprintf('File processing : %s\n', filename);

    % Read the audio file and get the signal and sampling rate
    [signal, framerate] = audioread(file_path);
    signal = double(signal)'; % Convert the signal to double precision and transpose

    % Check if the signal is mono or stereo
    if size(signal, 1) == 1
        disp("The signal is in mono.");
    elseif size(signal, 1) == 2
        disp("The signal is in stereo.");
        signal = mean(signal, 1); % Convert stereo to mono by averaging channels
        disp("Converted to mono.");
    end

    % Parameters for frequency detection
    min_freq = 50; % Minimum frequency to detect (Hz)
    max_freq = 1000; % Maximum frequency to detect (Hz)
    window_size = 0.05; % Window size (5% of the signal's framerate)
    overlap = 0.025; % Overlap between consecutive windows (2.5% of framerate)

    % Call the function to determine chords and the final scale
    [chords, final_scale] = chords_determination(signal, framerate, min_freq, max_freq, window_size, overlap, fileNames{i});

    % Define a struct for note frequencies (in Hz) for reference
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

    % Extract note names and their corresponding frequencies
    notes_name = fieldnames(note_frequencies)'; % Get note names
    notes_value = cell2mat(struct2cell(note_frequencies))'; % Get note frequencies
    [~, indexes_freq] = ismember(final_scale{2}, notes_name); % Map final scale notes to frequencies
    frequencies_scale = notes_value(indexes_freq); % Frequencies corresponding to the final scale

    % Combine scale frequencies and chords into a single output array
    output = [frequencies_scale, reshape(chords', 1, [])];
    
    % Sending results to the second flux for the C program
    fprintf(2, '%d ', size(chords, 2));
    fprintf(2, '%.3f ', output);
    fprintf(2, '\n');
    fprintf('\n'); fprintf('\n');
end

disp('MATLAB has finished running');
fprintf('\n'); fprintf('\n');

disp('Starting C ...');
fprintf('\n');