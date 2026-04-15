function p = dir_to_path(dir_struct)
 p = arrayfun(@(x) fullfile(x.folder,x.name), dir_struct, 'Uni',0);
end
