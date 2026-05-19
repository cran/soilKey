## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>"
)
library(soilKey)

## ----partial-pedon------------------------------------------------------------
pr_full   <- make_ferralsol_canonical()
pr_partial <- pr_full$clone(deep = TRUE)
pr_partial$horizons[3:5, c("cec_cmol", "bs_pct") := NA]

pr_partial$horizons[, .(top_cm, bottom_cm, designation,
                        clay_pct, cec_cmol, bs_pct, oc_pct)]

## ----classify-partial---------------------------------------------------------
res_partial <- classify_wrb2022(pr_partial, on_missing = "silent")
res_partial$rsg_or_order
res_partial$evidence_grade

## ----build-prior--------------------------------------------------------------
# Synthetic prior consistent with the gneiss-Mata-Atlantica context:
# Ferralsols dominate, with a tail of Acrisols and Cambisols.
prior <- data.table::data.table(
  rsg_code    = c("FR", "AC", "CM", "AL"),
  probability = c(0.62, 0.20, 0.12, 0.06)
)
prior

## ----consistency-check--------------------------------------------------------
chk <- prior_consistency_check(rsg_code = "FR", prior = prior, threshold = 0.05)
chk

## ----inconsistent-------------------------------------------------------------
prior_consistency_check(rsg_code = "AL", prior = prior, threshold = 0.05)

## ----soilgrids-call, eval = FALSE---------------------------------------------
# prior <- spatial_prior_soilgrids(pr_partial, buffer_m = 250)

## ----ossl-call, eval = FALSE--------------------------------------------------
# fill_from_spectra(
#   pr_partial,
#   library     = "ossl",
#   region      = "south_america",
#   properties  = c("clay_pct", "cec_cmol", "bs_pct", "oc_pct"),
#   method      = "mbl",
#   preprocess  = "snv+sg1",
#   k_neighbors = 100L,
#   ossl_library = "/path/to/ossl-soilsite-vnir.parquet"
# )

## ----mock-predict-------------------------------------------------------------
preds <- list(
  list(idx = 3, attribute = "cec_cmol", value = 5.5, confidence = 0.78),
  list(idx = 3, attribute = "bs_pct",   value = 14,  confidence = 0.72),
  list(idx = 4, attribute = "cec_cmol", value = 4.9, confidence = 0.79),
  list(idx = 4, attribute = "bs_pct",   value = 13,  confidence = 0.74),
  list(idx = 5, attribute = "cec_cmol", value = 4.7, confidence = 0.70),
  list(idx = 5, attribute = "bs_pct",   value = 13,  confidence = 0.71)
)

pr_filled <- pr_partial$clone(deep = TRUE)
for (p in preds) {
  pr_filled$add_measurement(
    horizon_idx = p$idx,
    attribute   = p$attribute,
    value       = p$value,
    source      = "predicted_spectra",
    confidence  = p$confidence,
    overwrite   = TRUE
  )
}

pr_filled$horizons[, .(top_cm, bottom_cm, cec_cmol, bs_pct)]

## ----show-provenance----------------------------------------------------------
prov <- pr_filled$provenance
prov[source == "predicted_spectra", .(horizon_idx, attribute, source, confidence)]

## ----classify-filled----------------------------------------------------------
res_filled <- classify_wrb2022(pr_filled, on_missing = "silent")
res_filled$rsg_or_order
res_filled$evidence_grade
res_filled$name

## ----combine-priors-----------------------------------------------------------
combined <- combine_priors(
  priors = list(
    soilgrids = data.table::data.table(rsg_code = c("FR", "AC", "CM"),
                                          probability = c(0.62, 0.20, 0.18)),
    embrapa   = data.table::data.table(rsg_code = c("FR", "AC", "NT"),
                                          probability = c(0.55, 0.30, 0.15))
  ),
  weights = c(soilgrids = 0.6, embrapa = 0.4)
)
combined

