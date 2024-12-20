fs = 44100;
t = 0.5;
notes = [
    % liste des notes (frequences en hertz)
];

y = [];
for i = 1:length(notes)
    t_note = 0:1/fs:t; 
    note_wave = sin(2 * pi * notes(i) * t_note);
    y = [y, note_wave]; 
end

y = y / max(abs(y));  
sound(y, fs);  



