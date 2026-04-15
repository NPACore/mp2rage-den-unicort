function T = t_add_subsess(T, path_vec)
  T.sub = regexp(path_vec,'sub-\d{5}','match', 'once');
  T.ses = regexp(path_vec, '(?<=bids/)[^/]*','match','once');
end
