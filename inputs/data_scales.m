scales = {
        % gammes mineure naturel
        'Do minor natural',   {'Do', 'Re', 'Red', 'Fa', 'Sol', 'Sold', 'Lad'};
        'Re flat minor natural',  {'Dod', 'Red', 'Mi', 'Fad', 'Sold', 'La', 'Si'};
        'Re minor natural',   {'Re', 'Mi', 'Fa', 'Sol', 'La', 'Lad', 'Do'};
        'Mi flat minor natural',  {'Red', 'Fa', 'Fad', 'Sold', 'Lad', 'Si', 'Dod'};
        'Mi minor natural',   {'Mi', 'Fad', 'Sol', 'La', 'Si', 'Do', 'Re'};
        'Fa minor natural',   {'Fa', 'Sol', 'Sold', 'Lad', 'Do', 'Dod', 'Red'};
        'Fa sharp minor natural',  {'Fad', 'Sold', 'La', 'Si', 'Dod', 'Re', 'Mi'};
        'Sol minor natural',  {'Sol', 'La', 'Lad', 'Do', 'Re', 'Red', 'Fa'};
        'La flat minor natural', {'Sold', 'Lad', 'Si', 'Dod', 'Red', 'Mi', 'Fad'};
        'La minor natural',   {'La', 'Si', 'Do', 'Re', 'Mi', 'Fa', 'Sol'};
        'Si flat minor natural',  {'Lad', 'Do', 'Dod', 'Red', 'Fa', 'Fad', 'Sold'};
        'Si minor natural',   {'Si', 'Dod', 'Re', 'Mi', 'Fad', 'Sol', 'La'};

        % gammes majeure
        'Do Major',   {'Do', 'Re', 'Mi', 'Fa', 'Sol', 'La', 'Si'};
        'Re flat Major',  {'Dod', 'Red', 'Fa', 'Fad', 'Sold', 'Lad', 'Do'};
        'Re Major',   {'Re', 'Mi', 'Fad', 'Sol', 'La', 'Si', 'Dod'};
        'Mi flat Major',  {'Red', 'Fa', 'Sol', 'Sold', 'Lad', 'Do', 'Re'};
        'Mi Major',   {'Mi', 'Fad', 'Sold', 'La', 'Si', 'Dod', 'Red'};
        'Fa Major',   {'Fa', 'Sol', 'La', 'Lad', 'Do', 'Re', 'Mi'};
        'Fa sharp Major',  {'Fad', 'Sold', 'Lad', 'Si', 'Dod', 'Red', 'Fa'};
        'Sol Major',  {'Sol', 'La', 'Si', 'Do', 'Re', 'Mi', 'Fad'};
        'La flat Major', {'Sold', 'Lad', 'Do', 'Dod', 'Red', 'Fa', 'Sol'};
        'La Major',   {'La', 'Si', 'Dod', 'Re', 'Mi', 'Fad', 'Sold'};
        'Si flat Major',  {'Lad', 'Do', 'Re', 'Red', 'Fa', 'Sol', 'La'};
        'Si Major',   {'Si', 'Dod', 'Red', 'Mi', 'Fad', 'Sold', 'Lad'};
    };
    save('data_scales.mat', 'scales');
    disp('Scales saved.');