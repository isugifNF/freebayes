# freebayes
Freebayes parallelization using nextflow


   Usage:
      The typical command for running the pipeline is as follows:
        nextflow run main.nf --fastaReference genomeFile.fasta --bam /full/path/input/file.bam --vcf outputPrefix -profile singularity,nova

      Mandatory arguments:

      --fastqs                      fastq files to run nanoplot on. (/data/*.fastq)

      Optional arguments:
        --help                  Display this help message
        --outdir                Specify output directory ('./out_dir')
        --queueSize             Max number of jobs submitted at one time (18)
        --fasta-reference       Input genome file to run freebayes on ("yourGenome.fasta")
        --vcf                   Output VCF file name ("out.vcf")
        --bam                   Bam input file ("In.bam")
        --options               Freebayes options ("--min-mapping-quality 0 --min-coverage 3 --min-supporting-allele-qsum 0 --ploidy 2 --min-alternate-fraction 0.2 --max-complex-gap 0")
        --regionSize            Size of the regions to split the file into (25000)


