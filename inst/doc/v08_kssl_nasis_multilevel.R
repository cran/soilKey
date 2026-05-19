## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>"
)
library(soilKey)

## ----load, eval = FALSE-------------------------------------------------------
# peds <- load_kssl_pedons_with_nasis(
#   gpkg   = "<path>/ncss_labdata.gpkg",
#   sqlite = "<path>/NASIS_Morphological_09142021.sqlite",
#   head   = 3000)
# 
# length(peds)
# #> [1] 2964   # after the 3000-row gpkg slice and the join
# 
# peds[[1]]$horizons[, c("designation", "clay_pct", "munsell_chroma_moist",
#                           "clay_films_amount")]
# #>    designation clay_pct munsell_chroma_moist clay_films_amount
# #> 1: Ap          22.5     3                    NA
# #> 2: Bt1         34.7     4                    common
# #> 3: Bt2         38.3     4                    many

## ----four-levels, eval = FALSE------------------------------------------------
# # Quality filter: profiles with usable clay data and a non-empty
# # subgroup reference label.
# keep <- vapply(peds, function(p) {
#   hz <- p$horizons
#   if (is.null(hz) || nrow(hz) == 0) return(FALSE)
#   if (!any(!is.na(hz$clay_pct))) return(FALSE)
#   !is.null(p$site$reference_usda_subgroup) &&
#     !is.na(p$site$reference_usda_subgroup) &&
#     nzchar(p$site$reference_usda_subgroup)
# }, logical(1))
# peds <- peds[keep]
# 
# for (lvl in c("order", "suborder", "great_group", "subgroup")) {
#   res <- benchmark_run_classification(peds, system = "usda",
#                                          level = lvl, boot_n = 500L)
#   cat(sprintf("%-12s n=%d  top1=%.4f  CI=[%.3f, %.3f]\n",
#                 lvl, res$n_evaluated, res$accuracy_top1,
#                 res$accuracy_ci[1], res$accuracy_ci[2]))
# }

