############################################################################
#                                                                          #
#   Defines some functions that simplify downloading from Uniprot          #
#                                                                          #
############################################################################

default_uniprot_base_url <- "https://www.uniprot.org/uploadlists/"
default_uniprot_api_url <- "www.ebi.ac.uk/proteins/api"


#' Pasrse the XML file returned by UniProt for a single entry
#' 
#' @param uni_acc string          Accession of UniProt entry
#' @param uniprot_api_url string  The base url for UniProt API
#' 
#' @return data.frame             All protein features annotated in UniProt plus the sequence.
parse_uniprot <- function(uni_acc, uniprot_api_url){
  uniprot_entry <- uni_acc %>%
    file.path(uniprot_api_url, "proteins", .) %>%
    GET() %>%
    content()
  
  features <- uniprot_entry$features %>%
    purrr::map_dfr(as.data.frame) %>%
    mutate(
      ACCESSION = uni_acc,
      SEQ = uniprot_entry$sequence$sequence
    )
  if (is.null(features$description)) features$description <- NA
  
  if(nrow(features) < 1) {
    data.frame(
      features=c(), ACCESSION=c(), type=c(), category=c(), description=c(),
      begin=c(), end=c(), SEQ=c()
    )
  } else {
    select(features, ACCESSION, type, category, description, begin, end, SEQ)
  }
  
}


#' Map IDs (typically ENSEMBL) to UniProt Accession
#' 
#' @param raw_ids vector          The IDs to be mapped
#' @param uniprot_base_url string The base url for UniProt mapping API
#' @param id_code string          The string representing the type of the IDs to be mapped
#' 
#' @return data.frame             All protein features annotated in UniProt plus the sequence.
map_uniprot <- function(raw_ids, uniprot_base_url, id_code="ENSEMBL_PRO_ID"){
  uniprot_base_url %>% 
    GET(
        query = list(
        from = id_code, to = "ACC", format = "tab",
        query = paste(raw_ids, collapse=" ")
        )
    ) %>%
    content() %>%
    read.csv(text=., sep="\t", stringsAsFactors=FALSE)
}


#' Pasrse the XML file returned by UniProt for a single entry
#' 
#' @param raw_ids vector          The IDs to be mapped
#' @param uniprot_api_url string  The base url for UniProt API
#' @param uniprot_base_url string The base url for UniProt mapping API
#' @param id_code string          The string representing the type of the IDs to be mapped
#' 
#' @return data.frame             All protein features annotated in UniProt plus the sequence.
entries_from_uniprot <- function(raw_ids, uniprot_api_url=default_uniprot_api_url, uniprot_base_url=default_uniprot_base_url, id_code="ENSEMBL_PRO_ID"){
  uniprot_id_mapping <- map_uniprot(
    raw_ids, uniprot_base_url=uniprot_base_url, id_code=id_code
  )
  
  protein_features <- uniprot_id_mapping$To %>%
    purrr::map_dfr(parse_uniprot, uniprot_api_url=uniprot_api_url) %>%
    left_join(uniprot_id_mapping, by=c(ACCESSION="To")) %>%
    dplyr::rename(ID = From) %>%
    distinct()
}


#' Pasrse the XML file returned by UniProt for a single entry
#' 
#' @param protein_features data.frame  Protein features retrieved from UniProt
#' @param fasta_path string            Path to the FASTA output
#' 
#' @return AAStringSet                 Protein sequences from UniProt.
extract_up_seqs <- function(protein_features, fasta_path=NULL){
  
  protein_seqs <- protein_features %>%
    distinct(ACCESSION, SEQ) %>%
    {setNames(.$SEQ, .$ACCESSION)} %>%
    AAStringSet()
  
  if(!is.null(fasta_path)) writeXStringSet(protein_seqs, fasta_path)
  
  protein_seqs
  
}


#' Extract nucleotide sequences from a TwoBit genome file
#' @param gene string               Gene symbol to filter by
#' @param db ensebmldb              A species-specific subset of ENSEMBL
#' @param genome_seq TwoBit         A species-specific TwoBit file containing all sequences
#' @param fasta_path string         Path to the FASTA output
#' 
#' @return DNAStringSet             Nucleotide sequences of given transcripts.
dna_seq_from_ensembl <- function(gene, db, genome_seq, fasta_path=NULL){
  nt_seqs <- db %>%
    exonsBy(
      by = "tx",
      filter = AnnotationFilterList(
        GeneNameFilter(gene),
        GeneIdFilter("ENS", "startsWith")
      )
    ) %>%
    extractTranscriptSeqs(genome_seq, .)
  
  if(!is.null(fasta_path)) writeXStringSet(nt_seqs, fasta_path)
  
  nt_seqs
  
}


#' Extract amino acid sequences for given transcripts from ENSEMBL
#' @param gene string               Gene symbol to filter by
#' @param db ensebmldb              A species-specific subset of ENSEMBL
#' @param fasta_path string         Path to the FASTA output
#' 
#' @return AAStringSet              Amino Acid sequences of given transcripts.
aa_seq_from_ensembl <- function(gene, db, fasta_path=NULL){
  protein_seqs <- proteins(
    db, return.type = "AAStringSet",
    filter = AnnotationFilterList(
      GeneNameFilter(params$gene_symbol),
      GeneIdFilter("ENS", "startsWith")
    )
  )
  
  if(!is.null(fasta_path)) writeXStringSet(protein_seqs, fasta_path)
  
  protein_seqs
  
}