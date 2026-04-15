function res = denoise(varargin)
  SKIP_EXISTING = isempty(getenv('REDO'));
  DRYRUN = ~isempty(getenv('DRYRUN'));     % show don't do when DRYRUN env variable is set
  bdir = getenvor('BIDS', '../Data/bids/');
  regularization = str2num(getenvor('MP2RAGE_REGULARIZATION','11'));

  suffix=sprintf('DEN-%d.nii', regularization);

  % go back to interactive
  if regularization == 0, regularization = [], end

  if nargin == 0 || strcmp(varargin{1},'all')
     T = missing_table(...
        'UNI', fullfile([bdir '*/'],'sub-*','anat','sub-*UNIT1.nii.gz'), ...
        'DEN', fullfile([bdir '*/'],'sub-*','anat', ['sub-*' suffix])); % 'sub-*_DEN-11.nii'
     anat_to_run = T.UNI(cellfun(@isempty,T.DEN));
  else
     anat_to_run = {varargin{:}}
  end

  if isempty(anat_to_run), error('Cannot find any UNIT1 images'); end

  addpath(getenvor('SPM_TOOLBOX','/opt/ni_tools/spm') )
  addpath(genpath(getenvor('MP2RAGE_TOOLBOX','/opt/ni_tools/matlab_toolboxes/MP2RAGE-related-scripts'))) % uses spm_vol_gz
  for uni = anat_to_run'
     uni=uni{1};
  
     MP2RAGE.filenameUNI=uni; % standard MP2RAGE T1w image;
     % Inversion Time 1 MP2RAGE T1w image; eg. 'data/MP2RAGE_INV1.nii';
     MP2RAGE.filenameINV1=regexprep(uni, '_UNIT1.nii.gz', '_inv-1_MP2RAGE.nii.gz');
     % Inversion Time 2 MP2RAGE T1w image; eg 'data/MP2RAGE_INV2.nii';
     MP2RAGE.filenameINV2=regexprep(uni, '_UNIT1.nii.gz', '_inv-2_MP2RAGE.nii.gz');
     % image without background noise;
     MP2RAGE.filenameOUT=regexprep(uni, '_UNIT1.nii.gz', ['_' suffix])

     if ~exist(MP2RAGE.filenameINV2, 'file')
        warning('Cannot run. Missing %s',MP2RAGE.filenameINV2);
        continue
     end
     if strcmp(MP2RAGE.filenameOUT, MP2RAGE.filenameUNI)
        warning('Out and input name are the same %s', MP2RAGE.filenameUNI)
        continue
     end
     if exist(MP2RAGE.filenameOUT,'file') && SKIP_EXISTING
        warning('denoised file already exists! skipping %s', MP2RAGE.filenameOUT)
        continue
     end

     % returns MP2RAGEimgRobustPhaseSensitive
     if DRYRUN
        fprintf('DRYRUN! not running (regularization=%d)\n', regularization);
        MP2RAGE,
        continue
     end
     [~]=RobustCombination(MP2RAGE, regularization);
  end
end
