filename = 'audios.txt';
fileID = fopen(filename, 'r');
fileNames = textscan(fileID, '%s');
fclose(fileID);
disp(class(fileNames));
disp(fileNames);