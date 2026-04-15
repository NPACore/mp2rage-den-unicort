function T = t_add_subsess_DEN(T, path_vec)
  T.sub = regexp(path_vec,'sub-\d{5}','match', 'once');
  T.ses = regexp(path_vec, 'ses-[^/_-]*','match','once');
  T.den = regexp(path_vec, '_DEN-\d+','match','once');
end
