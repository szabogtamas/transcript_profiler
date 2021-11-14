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


#' Convert the alignment of isoforms into GRanges
#' 
#' @param aligned_seqs AAStringSet  Aligned isoform sequences
#' 
#' @return GRanges                  The blocks of sequences shared between isoforms.
convert_alignment_to_ranges <- function(aligned_seqs){
    
    aligned_ranges <- aligned_seqs %>%
        as.list() %>%
        purrr::map_dfr(
            function(x) {
            x %>%
                stringr::str_locate_all('[A-Z]+') %>%
                data.frame() %>%
                mutate(
                seqname = "P0",
                strand = "+"
                )
            }, .id="transcript"
        )

}


#' Convert the alignment of isoforms into GRanges
#' 
#' @param aligned_ranges GRanges    Blocks of amino acids as alignment ranges.
#' 
#' @return data.frame               Mapping between original positions and positions on alignment.
map_aligned_positions <- function(aligned_ranges){

    aligned_ranges %>%
        dplyr::rename(ACCESSION = transcript) %>%
        mutate(
            Aligned_pos = purrr::map2(start, end, seq)
        ) %>%
        unnest(Aligned_pos) %>%
        arrange(ACCESSION, Aligned_pos) %>%
        group_by(ACCESSION) %>%
        mutate(
            Original_pos = seq(1, n())
        ) %>%
        ungroup() %>%
        select(ACCESSION, Original_pos, Aligned_pos)

}