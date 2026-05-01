function Mapset = create_mapset()
    
    chars = ['a':'z', ' ', '.', ',', '!', ';', ''''];
    
    Mapset = cell(2, 32); 
    
    for i = 1:32
        Mapset{1, i} = chars(i);
        Mapset{2, i} = dec2bin(i-1, 5); 
    end
end