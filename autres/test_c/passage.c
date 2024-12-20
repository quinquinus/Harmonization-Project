#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    // double value;
    // printf("Resultats lus depuis MATLAB :\n");
    // while (scanf("%lf", &value) != EOF) {
    //     printf("%.2f ", value);
    // }
    // printf("\n");
    // return 0;
    char var[30] = "caca";
    char *var2 = "mou";

    strcat(var, var2);
    printf("%s", var);

}