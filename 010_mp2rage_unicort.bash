#!/usr/bin/env bash
# denoise with default regularization (11; change with MP2RAGE_REGULARIZATION)
# 20260325WF - init
BIDS=${BIDS:-../Data/bids/}
dryrun matlab -r 'try, denoise(); spm_unicort(); catch e, e, end; quit'

# msub (unicort) + _DEN (RobustCombination) recompressed to T1w 
mapfile -t uniden_files < <(find $BIDS -iname 'm*.nii' -ipath '*/anat/*')
for uniden in "${uniden_files[@]}"; do
  ! [[ $uniden =~ (.*)/m(sub-.*)_DEN-[0-9.]+.nii ]] && echo "unexpected filename $uniden not like msub*_DEN*.nii" && continue
  t1w=${BASH_REMATCH[1]}/${BASH_REMATCH[2]}_T1w.nii.gz
  test -r $t1w && echo "# already have $uniden as $t1w" && continue
  [ -n "${DRYRUN:-}" ] && echo "# DRYRUN: gzip --stdout $uniden > $t1w" && continue
  gzip --stdout $uniden > $t1w
done 
