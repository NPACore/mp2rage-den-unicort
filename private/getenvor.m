function res = getenvor(var, defval)
% GETENVOR getenv with a default value if unset
  res = getenv(var);
  if isempty(res), res=defval; end
end
