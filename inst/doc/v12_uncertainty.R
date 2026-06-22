## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  eval     = FALSE
)

## ----run----------------------------------------------------------------------
# library(soilKey)
# 
# p <- make_ferralsol_canonical()
# u <- classify_with_uncertainty(p, n = 200, system = "wrb2022")
# u
# #> <soilkey_uncertainty>  system=wrb2022  level=rsg
# #>   baseline    : Ferralsols
# #>   MC runs     : 200 (200 successful)
# #>   entropy     : 0.000
# #>   posterior   :
# #>     Ferralsols                       100.0%
# #>   most decisive attribute: ...

## ----fields-------------------------------------------------------------------
# u$posterior     # named numeric vector, P(class), sums to 1
# u$top1          # the modal class
# u$entropy       # Shannon entropy -- 0 for a certain result
# u$sensitivity   # data.table(attribute, importance)

## ----provenance---------------------------------------------------------------
# # Mark every clay value as a bare assumption (grade E).
# p_assumed <- make_ferralsol_canonical()
# for (i in seq_len(nrow(p_assumed$horizons))) {
#   p_assumed$add_measurement(i, "clay_pct",
#                             p_assumed$horizons$clay_pct[i],
#                             source = "user_assumed", confidence = 0.2,
#                             overwrite = TRUE)
# }
# 
# classify_with_uncertainty(p,         n = 200)$entropy   # low  -- measured
# classify_with_uncertainty(p_assumed, n = 200)$entropy   # high -- assumed

## ----sensitivity--------------------------------------------------------------
# u$sensitivity
# #>      attribute importance
# #> 1     clay_pct      0.18
# #> 2     cec_cmol      0.06
# #> ...

## ----robustness---------------------------------------------------------------
# # Identical to every previous release:
# classification_robustness(p, system = "wrb2022", n = 100)
# 
# # Opt in to grade-scaled perturbation:
# classification_robustness(p, system = "wrb2022", n = 100,
#                           provenance_aware = TRUE)

