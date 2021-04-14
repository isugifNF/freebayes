# freebayes

Freebayes parallelization using nextflow

## Installation


You will need a working version of nextflow, [see here](https://www.nextflow.io/docs/latest/getstarted.html#requirements) on how to install nextflow. Nextflow modules are avialable on some of the HPC computing resources.

<details><summary>See modules on HPC clusters</summary>

```
# === Nova
module load gcc/7.3.0-xegsmw4 nextflow
module load singularity
NEXTFLOW=nextflow

# === Condo
module load gcc/7.3.0-xegsmw4 nextflow
module load singularity
NEXTFLOW=nextflow

# === Ceres
module load nextflow
# singularity already available, no need for module
NEXTFLOW=nextflow

# === Atlas (will need a local install of nextflow and will need the --account "projectname" flag)
module load singularity
NEXTFLOW=/project/isu_gif_vrsc/programs/nextflow
```

</details>

```
nextflow run isugifNF/freebayes --help -r main
```

Usage:<br/>
  The typical command for running the pipeline is as follows:<br/>
  `nextflow run main.nf --fastaReference genomeFile.fasta --bam /full/path/input/file.bam --vcf outputPrefix -profile singularity,nova`
 
```
N E X T F L O W  ~  version 20.07.1
Launching `isugifNF/freebayes` [stupefied_davinci] - revision: 0c1655da96 [draft_dsl2]
----------------------------------------------------
                                \\---------//       
  ___  ___        _   ___  ___    \\-----//        
   |  (___  |  | / _   |   |_       \-//         
  _|_  ___) |__| \_/  _|_  |        // \        
                                  //-----\\       
                                //---------\\       
  isugifNF/freebayes  v1.0.0       
----------------------------------------------------
Usage:
     The typical command for running the pipeline is as follows:
     nextflow run main.nf --fastaReference genomeFile.fasta --bam /full/path/input/file.bam --vcf outputPrefix -profile singularity,nova

Mandatory arguments:
   --fastqs                      fastq files to run nanoplot on. (/data/*.fastq)

Optional arguments:
   --help 	 	Display this help message
   --outdir		Specify output directory ('./out_dir')
   --queueSize		Max number of jobs submitted at one time (18)
   --fasta-reference 	Input genome file to run freebayes on ("yourGenome.fasta")
   --vcf			Output VCF file name ("out.vcf")
   --bam			Bam input file ("In.bam")
   --options 		Freebayes options ("--min-mapping-quality 0 --min-coverage 3 --min-supporting-allele-qsum 0 --ploidy 2 --min-alternate-fraction 0.2 --max-complex-gap 0")
   --regionSize 		Size of the regions to split the file into (25000)
   --windowSize		size of windows to run freebayes on
```
