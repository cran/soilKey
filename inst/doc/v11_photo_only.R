## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  eval     = FALSE
)

## ----run----------------------------------------------------------------------
# library(soilKey)
# 
# res <- classify_from_photos(
#   images   = list(profile = "perfil.jpg", fieldsheet = "ficha.jpg"),
#   lat      = -22.74,
#   lon      = -43.68,
#   country  = "BR",
#   provider = ellmer::chat_anthropic()   # any ellmer chat object
# )
# 
# res$wrb$name            # e.g. "Rhodic Ferralsol (Clayic, ...)"
# res$wrb$evidence_grade  # "D" -- VLM-extracted; or "C" with a prior
# res$summary             # one row per system

## ----images-vector------------------------------------------------------------
# res <- classify_from_photos("perfil.jpg", lat = -22.74, lon = -43.68,
#                             provider = ellmer::chat_anthropic())

## ----provider-----------------------------------------------------------------
# # Testing / offline: a mock provider returning a canned, schema-valid response
# mock <- MockVLMProvider$new(responses = list(my_canned_munsell_json))
# classify_from_photos("perfil.jpg", lat = -22.7, lon = -43.6, provider = mock)

## ----soilgrids----------------------------------------------------------------
# p <- make_cambisol_canonical()
# p$horizons$clay_pct <- NA_real_
# 
# # Live: fetch the six SoilGrids 2.0 depth slices via the ISRIC REST API.
# apply_soilgrids_depth_prior(p)
# 
# # Offline / reproducible: pass the six-slice profiles directly.
# apply_soilgrids_depth_prior(
#   p,
#   depth_profiles = list(clay_pct = c(18, 20, 24, 28, 30, 30)))

## ----grade--------------------------------------------------------------------
# grades <- compute_per_attribute_evidence_grade(res$pedon)
# grades            # data.table(horizon_idx, attribute, grade)

