#! /usr/bin/env nextflow

nextflow.enable.dsl=2

/*************************************
 nextflow nanoQCtrim
 *************************************/

freebayes_container = 'quay.io/biocontainers/freebayes:1.3.5--py38ha193a2f_3'
samtools19_container = 'quay.io/biocontainers/samtools:1.9--h10a08f8_12'

def helpMessage() {
    log.info isuGIFHeader()
    log.info """
     Usage:
     The typical command for running the pipeline is as follows:
 nextflow run main.nf --fastaReference genomeFile.fasta --bam /full/path/input/file.bam --vcf outputPrefix -profile singularity,nova

     Mandatory arguments:

     --fastqs                      fastq files to run nanoplot on. (/data/*.fastq)

     Optional arguments:
 --help 	 		Display this help message
   --outdir		Specify output directory ('./out_dir')
   --queueSize		Max number of jobs submitted at one time (18)
   --fasta-reference 	Input genome file to run freebayes on ("yourGenome.fasta")
   --vcf			Output VCF file name ("out.vcf")
 --bam			Bam input file ("In.bam")
   --options 		Freebayes options ("--min-mapping-quality 0 --min-coverage 3 --min-supporting-allele-qsum 0 --ploidy 2 --min-alternate-fraction 0.2 --max-complex-gap 0")
   --regionSize 		Size of the regions to split the file into (25000)
 --windowSize		size of windows to run freebayes on
    """
}

// Show help message
if (params.help) {
  helpMessage()
  exit 0
}

// === Define processes
process createFastaIndex {
  container = "$samtools19_container"
  publishDir "${params.outdir}", mode: 'copy', pattern: '*fai'

  input:
  path(genome)

  output:
  path("*.fai")

  script:
  """
  samtools faidx ${genome}
  """
}

process createIntervals {
  input:
  path(fai)
  
  output:
  stdout()
  
  script:
  """
  fasta_generate_regions.py ${fai} ${params.windowSize}
  """
}

process runFreebayes {
  errorStrategy 'retry'
  container = "$freebayes_container"
  
  output:
  file('*.vcf') into window_vcf
  
  input:
  tuple path(fai), path(genome), path(bam), val(region)
  
  script:
  """
  freebayes --region ${region} ${params.options} --bam ${bam} --vcf ${params.vcf}"_"${region}".vcf" --fasta-reference ${genome}
  """
}

process combineVCF {
  
  publishDir "${params.outdir}", mode: 'copy',pattern: "${params.vcf}.vcf"
  
  input:
  path(vcfs)
  
  script:
  
  """
  cat $vcfs |  vcffirstheader > ${params.vcf}.vcf
  """
}

def isuGIFHeader() {
  // Log colors ANSI codes
  c_reset = params.monochrome_logs ? '' : "\033[0m";
  c_dim = params.monochrome_logs ? '' : "\033[2m";
  c_black = params.monochrome_logs ? '' : "\033[1;90m";
  c_green = params.monochrome_logs ? '' : "\033[1;92m";
  c_yellow = params.monochrome_logs ? '' : "\033[1;93m";
  c_blue = params.monochrome_logs ? '' : "\033[1;94m";
  c_purple = params.monochrome_logs ? '' : "\033[1;95m";
  c_cyan = params.monochrome_logs ? '' : "\033[1;96m";
  c_white = params.monochrome_logs ? '' : "\033[1;97m";
  c_red = params.monochrome_logs ? '' :  "\033[1;91m";
  
  return """    -${c_dim}--------------------------------------------------${c_reset}-
  ${c_white}                                ${c_red   }\\\\------${c_yellow}---//       ${c_reset}
  ${c_white}  ___  ___        _   ___  ___  ${c_red   }  \\\\---${c_yellow}--//        ${c_reset}
  ${c_white}   |  (___  |  | / _   |   |_   ${c_red   }    \\-${c_yellow}//         ${c_reset}
  ${c_white}  _|_  ___) |__| \\_/  _|_  |    ${c_red  }    ${c_yellow}//${c_red  } \\        ${c_reset}
  ${c_white}                                ${c_red   }  ${c_yellow}//---${c_red  }--\\\\       ${c_reset}
  ${c_white}                                ${c_red   }${c_yellow}//------${c_red  }---\\\\       ${c_reset}
  ${c_cyan}  isugifNF/nanoQCtrim  v${workflow.manifest.version}       ${c_reset}
  -${c_dim}--------------------------------------------------${c_reset}-
  """.stripIndent()
}

workflow {
  ref_ch = channel.fromPath(params.fastaReference, checkIfExists:true)
  bam_ch = channel.fromPath(params.bam, checkIfExists:true)

  windows_ch = ref_ch | createFastaIndex | createIntervals | splitText(){it.trim()} 

  createFastaIndex.out |
    combine(ref_ch) |
    combine(bam_ch) |
    combine(windows_ch) |
    runFreebayes |
    collect |
    combineVCF
}