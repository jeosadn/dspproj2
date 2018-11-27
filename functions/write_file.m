function write_file(filename, data)
    fileID = fopen(filename,'w');
    fwrite(fileID,data);
    fclose(fileID);
end