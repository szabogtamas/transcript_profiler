############################################################################
#                                                                          #
#   Shortcuts for aligning sequence variants (isoforms)                    #
#                                                                          #
############################################################################


#' Align protein isoform sequences and write the alignment to FASTA
#' 
#' @param protein_seqs AAStringSet  Amino acid sequences of isoforms
#' @param alignment_fn string       Path to the FASTA output
#' @param return_seqs boolean       Wether the aligned sequences should be returned (or just write to file)
#' 
#' @return AAStringSet              The aligned sequences (if return is not prevented).
align_isoforms <- function(protein_seqs, alignment_fn, return_seqs=TRUE){
    
    prot_msa_list <- protein_seqs %>%
      msa() %>%
      msaConvert("bios2mds::align")

    export.fasta(prot_msa_list, outfile=alignment_fn)

    alignment_fn %>%
      readLines() %>%
      gsub("NA$", "", .) %>%
      writeLines(alignment_fn)
    
    if (return_seqs) readAAStringSet(alignment_fn)

}