function temps = fonction(nbre1, nbre2, nbre3, bpm)
    temps = ((nbre1 - 1)*4 + (nbre2 - 1)/4 + nbre3/24/4)/(bpm/60);
end
bpm = 136;
disp(fonction(15, 13, 0, bpm));