# Project of Computational Methods and Tools : Harmonization of a melody

## Project description

This project modelizes a harmonization of a known melody by adding chords to the audio and by comparing to the original harmonization of the music.

## Structure

- **audios** folder groups all .wav files needed to harmonize
- **references** folder represents the real data of the original music, what we tend to have in our results
- **results** folder groups hramonized audios, plots of frequencies detected and grades of harmonization compared to references
- **code** folder contains program code

## Execution steps for each melody

1. "*main.m*" : Reads the .wav file and converting to a mono signal if necessary
2. "*frequencies_detection.m*" : Finds the frequencies of the signal and the start time of same frequencies
3. "*notes_detection.m*" : Assigns frequencies to musical notes
4. "*scale_detection.m*" : Finds the scale associated to notes detected
5. "*chords_determination.m*" : Finds what chords to add and at what times
6. "*harmonization.c*" : Reads .wav file, adds chords signals, writes a new .wav file

## Inputs

- "*christmas.wav*" : All I Want For Christmas Is You - Mariah Carey
- "*birds.wav*" : Birds - Imagine Dragons
- "*getlucky.wav*" : Get Lucky - Daft Punk
- "*laseine.wav*" : La Seine - Vanessa Paradis & M
- "*reality.wav*" : Reality - Richard Sanderson
- references .m files with the same filename as the .wav files, composed of the scale, the notes and their times, the chords and their times

## Outputs

- "*audios*" with harmonized audios in .wav of each melody
- "*plots*" with the frequencie/time graph for each melody
- "*grades*" with the grades of notes detection, scale detection and chords determination out of 100 and a final grade for this melody harmonization

## Requirements

- Matlab : R2024b (older versions might work but it has not been tested)
- gcc : 14.1.0

## Instructions

- Open the bash terminal from the project root directory
- To verify if the Matlab path is added to the bash, run the line : 
```
which matlab
```
If a path is returned, continue to the next step, if not open matlab and run the line
```
disp(matlabroot)
```
It will return C:/{matlab path}, then run in the bash the line :
```
export PATH=$PATH:/{matlab path}/bin
```
Then retry the which matlab line
- Run in the bash the following line to compile the C file :
```
gcc -Wall harmonization.c -o harmonization -lm
```
- Then run the line : 
```
echo -e "\nStarting Matlab ..." && matlab -batch "run('main.m')" 2>results/last_line.txt && ./harmonization.exe < results/last_line.txt
```

## Credits
caca boudin
