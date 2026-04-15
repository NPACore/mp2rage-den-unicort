% 20260129 - attempt 3
% 20260203 - should have .nii not .nii.gz! no need for spm bids. see 00_bids-t1-only.bash for uncompressing
function prov = spm_unicort(varargin)

  %addpath('/opt/ni_tools/matlab_toolboxes/spm25/spm/')
  addpath('/opt/ni_tools/spm') % spm_jobman; spatial.preproc
  bdir = [getenvor('BIDS', '../Data/bids/'), '/*/'];

  SKIP_EXISTING = isempty(getenv('REDO')); % default to skip unless REDO is set
  DRYRUN = ~isempty(getenv('DRYRUN')); % show don't do when DRYRUN env variable is set
  if nargin == 0 || strcmp(varargin{1},'all')
    input_file_list = fullfile(bdir,'sub-*','anat','sub-*_DEN*.nii');
  else
    % any existing path should merge b/c missing_table extracts and joins on sub+ses+den?
    input_file_list = {varargin{:}}
  end

  % find denoised (file labeled with  regularization like *_DEN-11*)
  % and find unicort applied (file name prefixed with 'm')
  cort_list = fullfile(bdir,'sub-*','anat', 'msub-*_DEN*.nii');
  T = missing_table('DEN', input_file_list, 'CORT', cort_list); 
  if isempty(T.DEN), error('Cannot find any DEN-* images to work on. See denoise.m'); end

  mia = cellfun(@isempty,T.CORT);
  if SKIP_EXISTING
     anat_to_run = T.DEN(mia);
  else
     anat_to_run = T.DEN;
  end

  n_exist = nnz(~mia);
  n_den = size(T,1);
  n_to_run = size(anat_to_run,1);
  fprintf('Running for %d/%d *DEN-* (%d already have msub*_DEN*-nii)\n', ...
     n_to_run, n_den, n_exist)

  if n_den > 0 && n_den == n_exist 
     warning('have all created, nothing to do')
     prov = [];
     return
  end
  if isempty(anat_to_run), error('No DEN-* images to work on.'); end
  % UNICORT SPM data-driven inhomogeneity correction
  % using initial code tested/stored in ../MP2RAGE_sample/00c_unicor.bash  ../MP2RAGE_sample/unicor_config.m ../MP2RAGE_sample/spm_unicor.m
  
  % The key variable for the right table must have unique values.
  
  % configure
  matlabbatch{1}.spm.spatial.preproc.channel.vols  = cellstr(anat_to_run); % cellstr not needed?
  matlabbatch{1}.spm.spatial.preproc.channel.biasreg  = 0.001;
  matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm  = 60;
  matlabbatch{1}.spm.spatial.preproc.channel.write  = [1, 1];
  matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
  matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
  matlabbatch{1}.spm.spatial.preproc.warp.reg = [0, 0.001, 0.5, 0.05, 0.2];
  matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
  matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
  matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
  matlabbatch{1}.spm.spatial.preproc.warp.write = [0, 0];

  if DRYRUN
     disp('DRYRUN! not running for:')
     disp(matlabbatch{1}.spm.spatial.preproc.channel.vols)
     prov = []
     return
  end
  
  % run
  [~,prov] = spm_jobman('run',matlabbatch);
end

%% working from spm_unicor_20260129.m on 20260202
% anat = spm_BIDS(bdir,'data', 'modality','anat', 'type','T1w'); % cell of file paths
% anat = cellfun(@(x)replace(x, '.gz',''), anat, 'Uni', 0)
% anat =
%  1x1 cell array
%
%    {'/Volumes/Hera/Projects/SPA/scripts/mri/preproc/unicort_UNI/sub-11823/ses-1ptx/anat/sub-11823_ses-1ptx_T1w.nii'}
%
%% where code is from:
% which spm_jobman
% /home/ni_tools/matlab_toolboxes/spm12-head/spm_jobman.m
% >> which spm_BIDS
% /home/ni_tools/matlab_toolboxes/spm12-head/spm_BIDS.m

% doesn't change error below
% /home/ni_tools/matlab_toolboxes/spm_bids/spm_BIDS_App.m
% spm('defaults','fmri');
% spm_jobman('initcfg'),
%% Error when trying to use nii.gz instead of .nii
% Item 'Volumes', field 'val': Number of matching files (0) less than required (1).
% Item channel: No field(s) named
% Volumes
% Error using spm_jobman>fill_run_job (line 482)
% No executable modules, but still unresolved dependencies or incomplete module inputs.
% 
% Error in spm_jobman (line 257)
%         sts = fill_run_job('run', cjob, varargin{3:end});
% 
% Error in spm_unicort (line 22)
% [~,prov] = spm_jobman('run',matlabbatch),
% 
% ------
% dbstop spm_jobman 257
% ...
% varargin{3:end} is empty.
