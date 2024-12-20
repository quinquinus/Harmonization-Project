#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <math.h>
#include <string.h>
#define PI 3.141592653589793

typedef struct {
    char chunkID[4];
    uint32_t chunkSize;
    char format[4];
    char subchunk1ID[4];
    uint32_t subchunk1Size;
    uint16_t audioFormat;
    uint16_t numChannels;
    uint32_t sampleRate;
    uint32_t byteRate;
    uint16_t blockAlign;
    uint16_t bitsPerSample;
    char subchunk2ID[4];
    uint32_t subchunk2Size;
} WAVHeader;




int16_t *read_wav(const char *filename, size_t *numSamples, int32_t *framerate) {
    FILE *file = fopen(filename, "rb");
    if (!file) {
        perror("Error opening WAV file");
        return NULL;
    }

    WAVHeader header;
    fread(&header, sizeof(WAVHeader), 1, file);

    if (strncmp(header.chunkID, "RIFF", 4) != 0 || strncmp(header.format, "WAVE", 4) != 0) {
        fprintf(stderr, "The file is not a valid WAV file.\n");
        fclose(file);
        return NULL;
    }

    if (header.audioFormat != 1 || header.bitsPerSample != 16) {
        printf("Only 16-bit PCM format is supported.\n");
        fclose(file);
        return NULL;
    }

    *numSamples = header.subchunk2Size / (header.bitsPerSample / 8) / header.numChannels;
    *framerate = header.sampleRate;
    int16_t *audioData = (int16_t *)malloc(*numSamples * sizeof(int16_t));

    if (!audioData) {
        perror("Memory allocation error for audioData");
        fclose(file);
        return NULL;
    }

    if (header.numChannels == 2) {

        for (size_t i = 0; i < *numSamples; i++) {
            int16_t left,right;
            
            fread(&left, sizeof(int16_t), 1, file);
            fread(&right, sizeof(int16_t), 1, file);
            
            audioData[i] = (int16_t)((left+right) / 2); // Moyenne des canaux
        }
    
    } else {

        fread(audioData, sizeof(int16_t), *numSamples, file);
    }
    fclose(file);
    return audioData; // Retourner le tableau mono
}




int16_t *one_chord(size_t numSamples, float *freq_accord, int32_t framerate, float start_time){

    int16_t *chord = (int16_t *)calloc(numSamples, sizeof(int16_t));
    if (chord == NULL) {
        perror("Memory allocation error for chord");
        return NULL;
    }

    size_t start_sample = (size_t)round(framerate * start_time);
    
    for (size_t b = start_sample; b < numSamples; b++){
        float time = (float)(b-start_sample)/framerate;

        // Enveloppe ADSR simplifiée
        float adsr = (1 - expf(-time * 30)) * expf(-time * 1.2);

        // Somme des ondes
        float signal = 0.0f;
        for (int i = 0; i < 3; i++) {
            signal += sinf(2 * PI * freq_accord[i] * time);
        }

        // Mise à l'échelle et conversion en int16_t
        chord[b] = (int16_t)(9000.0f * adsr * signal);
    }
    return chord;
}




int16_t **all_chords(size_t numSamples, int32_t framerate, float *frequences, float *chords, float *times, int max_length, int *final_length){

    int16_t **ptr_chords_temp = (int16_t **)malloc(max_length * sizeof(void *));
    if (ptr_chords_temp == NULL) {
        perror("Memory allocation error for ptr_chords_temp");
        exit(EXIT_FAILURE);
    }

    int temp = 0;

    for (int i = 0; i < max_length; i++){
        int chord = (int)chords[i];
        if (chord != 0){
            float freq_chord[3] = {
                frequences[(chord-1+7)%7], 
                frequences[(chord+2-1+7)%7], 
                frequences[(chord+4-1+7)%7]
            };
            ptr_chords_temp[temp] = one_chord(numSamples, freq_chord, framerate, times[i]);
            if (ptr_chords_temp[temp] == NULL) {
                perror("Memory allocation error for one_chord");
                for (int j = 0; j < temp; j++) {
                    free(ptr_chords_temp[j]);
                }
                free(ptr_chords_temp);
                return NULL;
            }
            temp+=1;
        }
    }

    int16_t **ptr_chords = (int16_t **)realloc(ptr_chords_temp, temp * sizeof(void *));
    if (ptr_chords == NULL && temp > 0) {
        perror("Memory allocation error for ptr_chords");
        for (int j = 0; j < temp; j++) {
            free(ptr_chords_temp[j]);
        }
        free(ptr_chords_temp);
        return NULL;
    }
    *final_length = temp;

    return ptr_chords;
}




void write_wav(const char *filename, int16_t *data, size_t numSamples, int32_t framerate) {
    WAVHeader header = {0};

    // Initialiser les champs du header
    memcpy(header.chunkID, "RIFF", 4);
    header.chunkSize = 36 + numSamples * sizeof(int16_t);
    memcpy(header.format, "WAVE", 4);
    memcpy(header.subchunk1ID, "fmt ", 4);
    header.subchunk1Size = 16;
    header.audioFormat = 1;
    header.numChannels = 1;
    header.sampleRate = framerate;
    header.byteRate = framerate * sizeof(int16_t);
    header.blockAlign = sizeof(int16_t);
    header.bitsPerSample = 16;
    memcpy(header.subchunk2ID, "data", 4);
    header.subchunk2Size = numSamples * sizeof(int16_t);

    FILE *file = fopen(filename, "wb");
    if (!file) {
        perror("Error writing WAV file");
        return;
    }

    fwrite(&header, sizeof(WAVHeader), 1, file);
    fwrite(data, sizeof(int16_t), numSamples, file);

    fclose(file);
}





int main() {

    const char* file_filenames = "audios.txt";
    FILE *file = fopen(file_filenames,"r");
    if (!file) {
        perror("Error opening the file of file names");
        return EXIT_FAILURE;
    }

    char filename[100];

    while (fgets(filename, 100, file) != NULL){
        
        size_t len = strlen(filename);
        if (len > 0 && filename[len-1] == '\n') {
            filename[len-1] = '\0';
        }
        char *ext = ".wav";
        strcat(filename, ext);

        // clock_t start, end;
        // double time;

        // start = clock();
        printf("File processing : %s ...\n", filename);

        int32_t framerate;
        size_t numSamples;
        char path[100] = "audio/";
        strcat(path, filename);
        int16_t *audioData = read_wav(path, &numSamples, &framerate);

        if (!audioData) {
            fprintf(stderr, "Error : Failed to read WAV file.\n");
            return EXIT_FAILURE;
        }

        // end = clock();
        // time = ((double)(end - start)) / CLOCKS_PER_SEC;
        // printf("Execution time : %.3f seconds\n\n", time);




        // start = clock();
        printf("Reading Matlab results ...\n");

        int length;
        scanf("%d", &length);

        if (length <= 0) {
        fprintf(stderr, "The size of the Matlab results must be greater than 0.\n");
        return EXIT_FAILURE;
        }

        float frequences[7];
        for (int k = 0; k < 7; k++) {
            scanf("%f", &frequences[k]);
        }

        for (int k = 0; k < 7; k++) {
            if (frequences[k] <= 0) {
                fprintf(stderr, "Frequencies must be positive.\n");
                return EXIT_FAILURE;
            }
        }

        float matrix[3][length];
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < length; j++) {
                scanf("%f", &matrix[i][j]);
            }
        }

        // end = clock();
        // time = ((double)(end - start)) / CLOCKS_PER_SEC;
        // printf("Execution time : %.3f seconds\n\n", time);




        // start = clock();
        printf("Adding chords to the original audio ...\n");

        int final_length;

        int16_t **ptr_chords;
        ptr_chords = all_chords(numSamples, framerate, frequences, matrix[1], matrix[2], length, &final_length);
        if (ptr_chords == NULL) {
            fprintf(stderr, "Error generating chords.\n");
            free(audioData); // Libérer les ressources restantes
            return EXIT_FAILURE;
        }

        int16_t *final_audio = (int16_t *)malloc(numSamples*sizeof(int16_t));
        if (final_audio == NULL) {
            perror("Memory allocation error for final_audio");
            for (int b = 0; b < final_length; b++) {
                free(ptr_chords[b]);
            }
            free(ptr_chords);
            free(audioData);
            return EXIT_FAILURE;
        }
        for (size_t a = 0; a < numSamples; a++){
            int32_t sum = audioData[a]*0.4;
            // int32_t sum = 0;

            for (int b = 0; b < final_length; b++){
                sum += ptr_chords[b][a]*0.4;
            }
            if (sum > 32767) sum = 32767; // Saturation haute
            if (sum < -32768) sum = -32768; // Saturation basse
            final_audio[a] = (int16_t)sum;
        }

        // end = clock();
        // time = ((double)(end - start)) / CLOCKS_PER_SEC;
        // printf("Execution time : %.3f seconds\n\n", time);



        // start = clock();
        printf("Creating a new WAV file ...\n");

        char output_path[100] = "results/audios/harmonized_";
        strcat(output_path, filename);

        write_wav(output_path, final_audio, numSamples, framerate);
        printf("WAV file written successfully\n\n");

        // end = clock();
        // time = ((double)(end - start)) / CLOCKS_PER_SEC;
        // printf("Execution time : %.3f seconds\n\n", time);



        for (int b = 0; b < final_length; b++) {
            free(ptr_chords[b]);
        }
        free(ptr_chords);
        free(audioData);
        free(final_audio);
    }
    fclose(file);

    return 0;
}
