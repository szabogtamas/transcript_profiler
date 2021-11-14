############################################################################
#                                                                          #
#   Defines some functions that simplify downloading from Uniprot          #
#                                                                          #
############################################################################

uniprot_base_url <- "https://www.uniprot.org/uploadlists/"
uniprot_api_url <- "www.ebi.ac.uk/proteins/api"


#' Pasrse the XML file returned by UniProt for a single entry
#' 
#' @param uni_acc string          Accession of UniProt entry
#' @param uniprot_api_url string  The base url for UniProt API
#' 
#' @return data.frame             All protein features annotated in UniProt plus the sequence.
parse_uniprot <- function(uni_acc, uniprot_api_url=uniprot_api_url){
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


#' Map IDs (typically ENSEMBL) to UniProt Accession
#' 
#' @param raw_ids vector          The IDs to be mapped
#' @param id_code string          The string representing the type of the IDs to be mapped
#' @param uniprot_base_url string The base url for UniProt mapping API
#' 
#' @return data.frame             All protein features annotated in UniProt plus the sequence.
map_uniprot <- function(id_code="ENSEMBL_PRO_ID", uniprot_base_url=uniprot_base_url){
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