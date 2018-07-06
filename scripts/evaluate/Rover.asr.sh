#!/bin/bash

if (( $# != 3 )); then
  echo "Not enough parameters: $0 testset hyp_dir out_dir"
  exit
fi

test_set=$1
rover_dir=$2
out_dir=$3
mkdir -p ${out_dir}

# /data/ctc/eval
rover_string=""
for hyp in ${rover_dir}/*.s; do
  name=${hyp##*/}
  ctm_name=${out_dir}/${name}.ctm
  /root/anaconda3/bin/python /opt/SLT.KIT/scripts/evaluate/text2ctm.py $hyp /data/orig/eval/${test_set}/IWSLT.${test_set}/test-db.yaml ${ctm_name}.tmp
  sort +0 -1 +1 -2 +2nb -3 ${ctm_name}.tmp > ${ctm_name}
  #rm ${ctm_name}.tmp
  rover_string="${rover_string} -h ${ctm_name} ctm"
done

rover_ctm=${out_dir}/rover.${test_set}.ctm
rover_ctm_sorted=${out_dir}/rover.${test_set}.ctm.sorted
rover_s=${out_dir}/rover.${test_set}.s

/opt/sctk-2.4.10/bin/rover ${rover_string} -o ${rover_ctm} -m avgconf -a 1.0 -c 0.0

rm -f ${rover_ctm_sorted}
# resort ctm
while IFS='' read -r line || [[ -n "$line" ]]; do
# tst2010.talkid785
    line=`echo "$line" | sed 's/.en//g'`
    grep $line $rover_ctm >> ${rover_ctm_sorted}
done < /data/orig/eval/${test_set}/IWSLT.${test_set}/FILE_ORDER
echo ${rover_ctm_sorted}

awk '{print $5}' ${rover_ctm_sorted} | tr '\n' ' ' > ${rover_s}


mkdir -p ${out_dir}/${test_set}

/opt/SLT.KIT/scripts/evaluate/Eval.asr.sh ${test_set} ${rover_s} ${out_dir}/${test_set}

