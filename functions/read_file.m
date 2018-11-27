function result = read_file(filename)
    fileID = fopen(filename,'r');
    result = fread(fileID);
    fclose(fileID);    
end