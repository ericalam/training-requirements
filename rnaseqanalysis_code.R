# Use DESeq2 for the differential gene expression analysis. Find the DEGs between your conditions of interest.
# load in data (SRP043078)
load("Datasets/rse_gene.Rdata")
rse_gene

# sample info; add prefix to column names
sra <- read.csv("Datasets/SraRunTable.txt")
head(sra)

colnames(sra) <- paste0("sra_", colnames(sra))
# choose variable
sra_var <- paste0("sra_", "Genotype")
# reorganize and recheck
sra <- sra[match(colData(rse_gene)$run, sra$sra_Run), ]
identical(colData(rse_gene)$run, as.character(sra$sra_Run))

# append variable
condition <- sra[, sra_var]
colData(rse_gene) <- cbind(colData(rse_gene), condition)
dim(colData(rse_gene))
colData(rse_gene)[, 1:ncol(colData(rse_gene))]

# SE to DDS
dds <- DESeqDataSet(rse_gene, ~condition)

# check quality (can take out step)
rld <- rlog(dds)
plotPCA(rld)

# perform DE analysis; get result out... log2(mutant/WT)
dds$condition <- relevel(dds$condition, ref = "siBCL6;etopic expression of WT BCL6")
dds <- DESeq(dds)
res <- results(dds, contrast = c("condition", "siBCL6;etopic expression of BCL6 RD2 mutant", "siBCL6;etopic expression of WT BCL6"))

# check quality 
plotMA(res) # variance at low expression can be extreme (gray - not significant)

# normalize/fix (prob not good; apeglm looks best)
resnorm <- lfcShrink(dds = dds, res = res, type = "normal", coef = 2)
plotMA(resnorm)

resapeg <- lfcShrink(dds = dds, type = "apeglm", coef = 2)
plotMA(resapeg)

resashr <- lfcShrink(dds = dds, res = res, type = "ashr", coef = 2)
plotMA(resashr)

# create results table and annotate genes
write.table(res, file = "allgenes_adjp0.01_lfc1_bm20.txt", 
            sep = "\t", col.names = TRUE, row.names = TRUE)

row.names(res) <- gsub("\\..*","",row.names(res))
head(res)

anno <- AnnotationDbi::select(org.Hs.eg.db, rownames(res),
                              columns=c("ENSEMBL", "ENTREZID", "SYMBOL", "GENENAME"), 
                              keytype="ENSEMBL")
res <- cbind(ENSEMBL = rownames(res), res)
anno_res <- left_join(as.data.frame(res), anno)
head(anno_res)

# enrichr 
anno_res %>%
  dplyr::filter(padj < 0.01 & log2FoldChange > 2) %>%
  readr::write_csv(file = "over_expressed_genes.csv")
anno_res %>%
  dplyr::filter(padj < 0.01 & log2FoldChange < -2) %>%
  readr::write_csv(file = "under_expressed_genes.csv")

# filter criteria for statistically significant results
pThr        <- 0.01   
logFCThr    <- 1      
baseMeanThr <- 20   

idx <- which(anno_res$padj <= pThr & 
               abs(anno_res$log2FoldChange) >= logFCThr & 
               anno_res$baseMean >= baseMeanThr)
anno_sigres <- anno_res[idx, ]
summary(anno_sigres)


# Create a PCA plot colored by the condition of interest
row.names(dds) <- gsub("\\..*","",row.names(dds))
rld <- rlog(dds)
plotPCA(rld, intgroup = "condition")

# Create a Volcano Plot (of all genes)
EnhancedVolcano(anno_res, lab = anno_res$SYMBOL, x = "log2FoldChange", 
                y = "padj", border = "full", borderWidth = 1.5, borderColour = "black",
                gridlines.major = FALSE, gridlines.minor = FALSE, title = "Mutant Bcl6 vs WT")

# Create a heatmap showing the top 20 over- and under-expressed DEGs
orderedsigres <- anno_sigres[order(anno_sigres$log2FoldChange, decreasing = TRUE), ]
mat <- assay(rld)
annotation <- as.data.frame(colData(rld)["condition"])
id1 <- orderedsigres$ENSEMBL
id2 <- orderedsigres$SYMBOL
topDEG <- mat[id1,]
rownames(topDEG) <- id2
top20DEG <- head(topDEG, n = 20)
rownames(annotation) <- colnames(rld)

pheatmap(top20DEG, scale = "row", clustering_distance_rows = "correlation",
         annotation_col = annotation, main = "Top 20 over-expressed DEGs")

orderedsigres <- anno_sigres[order(anno_sigres$log2FoldChange), ]
mat <- assay(rld)
annotation <- as.data.frame(colData(rld)["condition"])
id1 <- orderedsigres$ENSEMBL
id2 <- orderedsigres$SYMBOL
topDEG <- mat[id1,]
rownames(topDEG) <- id2
top20DEG <- head(topDEG, n = 20)
rownames(annotation) <- colnames(rld)

pheatmap(top20DEG, scale = "row", clustering_distance_rows = "correlation",
         annotation_col = annotation, main = "Top 20 under-expressed DEGs")


# Do GSEA on the results and plot the top 5 pathways
# arrange by padj
anno_res2 <- anno_res %>%
  arrange(padj) %>%
  mutate(gsea_metric = -log10(padj) * sign(log2FoldChange))
# get rid of inf from ~0 padj values
anno_res2 <- anno_res2 %>%
  mutate(padj = case_when(padj == 0 ~ .Machine$double.xmin,
                          TRUE ~ padj)) %>%
  mutate(gsea_metric = -log10(padj) * sign(log2FoldChange))
# remove NAs and order by GSEA;
anno_res2 <- anno_res2 %>%
  filter(! is.na(gsea_metric)) %>%
  arrange(desc(gsea_metric))
# histogram (can take out)
hist(anno_res2$gsea_metric, breaks = 100)
# ranked GSEA vector
rnk <- anno_res2 %>%
  select(SYMBOL, gsea_metric) %>%
  distinct(SYMBOL, .keep_all = TRUE) %>%
  deframe()
# get gene sets
gene_sets <- msigdbr(species = "Homo sapiens", category = "C7")
gene_sets <- gene_sets %>%
  select(gs_name, gene_symbol)
# run GSEA
gseares <- GSEA(geneList = rnk, TERM2GENE = gene_sets)
gseares_df <- as.data.frame(gseares)

# top 5 pathways
top_pathways <- gseares_df %>%
  top_n(n = 5, wt = NES) %>%
  pull(ID)

top_pathways_plot <- lapply(top_pathways, function(pathway){
  gseaplot(gseares, geneSetID = pathway, title = pathway)
})
top_pathways_plot <- ggarrange(plotlist = top_pathways_plot, labels = "AUTO", align = "hv")

ggsave(top_pathways_plot, filename = "top_up_GSEA.png", height = 25, width = 45)

knitr::include_graphics("top_up_GSEA.png")