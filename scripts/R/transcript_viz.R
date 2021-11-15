############################################################################
#                                                                          #
#   Shortcuts for plotting transcript features with Gviz                   #
#                                                                          #
############################################################################

library(ggplot2)
library(Gviz)
options(ucscChromosomeNames = FALSE)
color_names <- c("#E64B35B2", "#4DBBD5B2", "#00A087B2", "#3C5488B2", "#F39B7FB2", "#8491B4B2")


#' Plot gene models for available transcripts
#' 
#' @param gene string               Gene symbol to filter by
#' @param Tx TxDB                   TxDB with transcripts
#' @param db ensebmldb              A species-specific subset of ENSEMBL
#' @param fig_path string           Path to the figure output
#' 
#' @return plot                     Plot showing block models for transcripts
plot_trancript_models <- function(gene, Tx, db, fig_path=NULL){
    
    chr <- as.character(unique(seqnames(Tx)))
    region_start = min(start(Tx))
    region_end = max(end(Tx))
    
    tx_feat <- Tx %>%
        as.data.frame() %>%
        select(tx_biotype)

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
            ., name="", transcriptAnnotation="transcript", background.title="white",
            #fill=color_names[as.numeric(factor(.$feature))],
            #fill=color_names[as.numeric(factor(tx_feat[.$transcript,]))],
            utr=color_names[1], utr3=color_names[1], utr5=color_names[1],
            nonsense_mediated_decay=color_names[2], protein_coding=color_names[3]
        )
    
    if(!is.null(fig_path)){
        pdf(fig_path, width=7.2, height=3.6)
        plotTracks(
            list(genome_location_track, genome_region_track),
            main=paste("Aligned protein sequence variants of", gene)
        )
        graphics.off()
        }

    plotTracks(list(genome_location_track, genome_region_track))

}


#' Plot aligned block as pseudo-genomic ranges
#' 
#' @param gene string               Gene symbol to filter by
#' @param aligned_ranges GRanges    Alignment converted into genomic ranges
#' @param fig_path string           Path to the figure output
#' 
#' @return plot                     Plot showing block models for isoforms
plot_alignment_models <- function(gene, aligned_ranges, fig_path=NULL){
    
    genome_location_track <- GenomeAxisTrack()

    aligned_region_track <- aligned_ranges %>%
        makeGRangesFromDataFrame(keep.extra.columns=TRUE) %>%
        GeneRegionTrack(
            name="", transcriptAnnotation="transcript",
            background.title="white"
        )
    
    if(!is.null(fig_path)){
        pdf(fig_path, width=7.2, height=3.6)
        plotTracks(
            list(aligned_region_track, genome_location_track),
            main=paste("Aligned protein sequence variants of", gene)
        )
        graphics.off()
        }

    plotTracks(list(aligned_region_track, genome_location_track))

}


#' Plot aligned block as pseudo-genomic ranges
#' 
#' @param protein_features data.frame   Protein features extracted from UniProt
#' @param category_code string          The feature category to plot
#' @param msa_position_map data.frame   Mapping between AA position and alignment pos
#' @param entity string                 Suffix to be displayed in title
#' @param fig_path string               Path to the figure output
#' @param use_type boolean              If the type column should be used instead of description
#' 
#' @return ggplot                       Plot showing block models for transripts
plot_features_on_alignment <- function(protein_features, category_code, msa_position_map, entity, fig_path=NULL, use_type=FALSE){
    
    if (use_type) protein_features$description <- protein_features$type
    
    p <- protein_features %>%
        filter(category == category_code) %>%
        distinct(ACCESSION, begin, end, description) %>%
        arrange(description) %>%
        mutate(
            pos = purrr::map2(begin, end, seq)
        ) %>%
        unnest(pos) %>%
        left_join(msa_position_map, by=c("ACCESSION", pos="Original_pos")) %>%
        ggplot(aes(x=pos, y=description)) +
        geom_tile() +
        facet_grid(ACCESSION~., scales="free_y", space="free_y") +
        expand_limits(y = c(1, 4)) +
        xlim(1, NULL) +
        theme_bw() +
        theme(
            #axis.text.x = element_text(angle=30, hjust=1),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank()
        ) +
        labs(x = "", y = "", title = paste(category_code, "annotated in Uniprot for", entity))
    
    if(!is.null(fig_path)) ggsave(fig_path, p, width=7.2, height=3.6)
    
    p

}