function TT = missing_table(left, l_glob, right, r_glob, varargin)
% MISSING_TABLE - name two named globs.
%                 optionally a function to parse the glob

if isempty(varargin)
   func = @t_add_subsess;
else
   func = varargin{1};
end

%left = 'bcor'
%l_glob = dir(fullfile(bdir, 'sub-*/ses-*/anat/msub-*_UNIT1.nii'));
L = tbl_w_mergecols(left, l_glob, func);
R = tbl_w_mergecols(right, r_glob, func);

TT = outerjoin(L, R, 'Keys',{'sub','ses'});
end

function T = tbl_w_mergecols(name, vec, func)
  if strcmp(class(vec),'char')
     vec = dir_to_path(dir(vec));
  end 
  T = table(vec, 'VariableNames',{name});
  T = func(T, vec);
end
