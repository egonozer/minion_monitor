#!/bin/bash

## path = $1
## number = $2

sbatch <<EOT
#!/bin/bash
#SBATCH --job-name="guppy_$2"
#SBATCH -A <account ID>
#SBATCH -p <queue>
#SBATCH -t 8:00:00
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=3G
#SBATCH --gres=gpu:p100:1
#SBATCH --mail-user=<email address>
#SBATCH --mail-type=FAIL
#SBATCH -o "${1}/guppy_${2}.out.txt"
#SBATCH	-e "${1}/guppy_${2}.err.txt"

</path/to/>guppy_basecaller \
  --config dna_r9.4.1_450bps_hac.cfg \
  --barcode_kits EXP-NBD103 \
  --trim_barcodes \
  --device auto \
  --qscore_filtering \
  --progress_stats_frequency 60 \
  -i ${1}/fast5_${2} \
  -s ${i}fastq_${2}

EOT