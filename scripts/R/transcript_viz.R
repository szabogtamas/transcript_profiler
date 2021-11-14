############################################################################
#                                                                          #
#   Shortcuts for plotting transcript features with Gviz                   #
#                                                                          #
############################################################################

library(Gviz)
options(ucscChromosomeNames = FALSE)


#' Plot gene models for available transcripts
#' 
#' @param gene string               Gene symbol to filter by
#' @param Tx TxDB                   TxDB with transcripts
#' @param db ensebmldb              A species-specific subset of WNSEMBL
#' @param fig_path string           Path to the figure output
#' 
#' @return plot                     Plot showing block models for transripts
plot_trancript_models <- function(gene, Tx, db, fig_path=NULL){
    
    chr <- as.character(unique(seqnames(Tx)))
    region_start = min(Tx$start)
    region_end = max(Txf$end)

    genome_location_track <- GenomeAxisTrack()

    genome_region_track <- db %>%
        getGeneRegionTrackForGviz(
            chromosome=chr, start=region_start, end=region_end,
            featureIs="tx_biotype",
            filter=AnnotationFilterList(
                GeneNameFilter(gene),
                GeneIdFilter("ENS", "startsWith")
            )
        ) %>%
        GeneRegionTrack(
            name="", transcriptAnnotation="transcript", background.title="white"
        )
    
    if(!is.null(fig_path)){
        pdf(fig_path, width=7.2, height=3.6)
        plotTracks(
            list(genome_location_track, genome_region_track),
            main=paste("Aligned protein sequence variants of", params$gene_symbol)
        )
        graphics.off()
        }

    plotTracks(list(genome_location_track, genome_region_track))

}