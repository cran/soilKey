## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>"
)
library(soilKey)

## ----scene, eval = FALSE------------------------------------------------------
# # Field GPS coordinates of the planned profile pit.
# field_lat <- -22.7
# field_lon <- -43.7

## ----spatial-guide, eval = FALSE----------------------------------------------
# guide <- soil_classes_at_location(
#   lat        = field_lat,
#   lon        = field_lon,
#   system     = "wrb2022",
#   source_url = "https://files.isric.org/soilgrids/latest/data/wrb/MostProbable.vrt"
# )
# 
# guide$distribution
# #> # Ranked candidate classes:
# #> # rsg_code  rsg_name      probability
# #> # FR        Ferralsols    0.62
# #> # AC        Acrisols      0.21
# #> # NT        Nitisols      0.12
# #> # CM        Cambisols     0.05
# guide$typical_attributes
# #> # Per-class diagnostic thresholds to confirm in the field.

## ----vlm, eval = FALSE--------------------------------------------------------
# res <- classify_from_documents(
#   pdf      = "perfil_042_descricao.pdf",
#   image    = "perfil_042_parede.jpg",
#   report   = "perfil_042.html",
#   provider = "ollama"  # default; uses gemma4:e4b
# )
# 
# res$classifications$wrb$name
# #> [1] "Geric Ferric Rhodic Chromic Ferralsol (Clayic, Humic, Dystric, Ochric, Rubic)"
# res$classifications$sibcs$name
# #> [1] "Latossolos Vermelhos Distroficos tipicos, argilosa, moderado"
# res$classifications$usda$name
# #> [1] "Rhodic Hapludox"

## ----pedon-from-canonical-----------------------------------------------------
# For a runnable demo without Ollama / a real PDF, reuse the
# canonical Ferralsol fixture -- the downstream code is the same.
pedon <- make_ferralsol_canonical()

## ----spectral-analogy, eval = FALSE-------------------------------------------
# # Hypothetical: a real OSSL South-America library with WRB labels
# # obtained via `download_ossl_subset_with_labels()`.
# ossl_lib <- download_ossl_subset_with_labels(
#   region          = "south_america",
#   max_distance_km = 10
# )
# 
# # Pull the surface-horizon Vis-NIR scan from the populated pedon.
# query_spectrum <- pedon$spectra$vnir[1, ]
# 
# spectral <- classify_by_spectral_neighbours(
#   spectrum     = query_spectrum,
#   ossl_library = ossl_lib,
#   k            = 25,
#   region       = list(lat = field_lat, lon = field_lon,
#                       radius_km = 500)
# )
# spectral$distribution
# #> # class    n_neighbours  probability
# #> # FR              22       0.88
# #> # AC               2       0.08
# #> # NT               1       0.04
# spectral$neighbours
# #> # The 25 closest OSSL profiles + their distances + labels.

## ----classify-----------------------------------------------------------------
cls_wrb   <- classify_wrb2022(pedon, on_missing = "silent")
cls_sibcs <- classify_sibcs(pedon, include_familia = TRUE)
cls_usda  <- classify_usda(pedon)

cls_wrb$name
cls_sibcs$name
cls_usda$name

# Each ClassificationResult carries the full key trace, the per-
# attribute provenance, and an evidence grade A/B/C/D.
cls_wrb$evidence_grade
length(cls_wrb$trace)         # number of RSGs tested before assignment

## ----report-html, eval = FALSE------------------------------------------------
# results <- list(wrb = cls_wrb, sibcs = cls_sibcs, usda = cls_usda)
# report(results, file = file.path(tempdir(), "perfil_042.html"),
#        pedon = pedon)

## ----report-qgis, eval = FALSE------------------------------------------------
# results <- list(wrb = cls_wrb, sibcs = cls_sibcs, usda = cls_usda)
# report_to_qgis(
#   pedon           = pedon,
#   classifications = results,
#   file            = file.path(tempdir(), "perfil_042.gpkg"),
#   report_html     = file.path(tempdir(), "perfil_042.html")
# )

## ----diagram, eval = FALSE----------------------------------------------------
# # Pipeline summary:
# #
# #   field GPS      ->  soil_classes_at_location()         "what to expect"
# #                                  |
# #                                  v
# #   PDF + photo    ->  classify_from_documents() (Gemma 4)  populates PedonRecord
# #                                  |
# #                                  v
# #   Vis-NIR scan   ->  classify_by_spectral_neighbours()    spectral prior
# #                                  |
# #                                  v
# #                  ->  classify_wrb2022()  + classify_sibcs() + classify_usda()
# #                                  |       (the deterministic step -- canonical)
# #                                  v
# #                  ->  report() / report_to_qgis()         deliverables

