############################################################################
#                                                                          #
#   Defines some functions that simplify downloading from Uniprot          #
#                                                                          #
############################################################################

uniprot_base_url <- "https://www.uniprot.org/uploadlists/"
uniprot_api_url <- "www.ebi.ac.uk/proteins/api"

options(ucscChromosomeNames = FALSE)


#' Pasrse the XML file returned by UniProt for a single entry
#' 
#' @param uni_acc string          Accession of UniProt entry
#' 
#' @return data.frame             All protein features annotated in UniProt plus the sequence.
parse_uniprot <- function(uni_acc){
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
  
  select(features, ACCESSION, type, category, description, begin, end, SEQ)
}