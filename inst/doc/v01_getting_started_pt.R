## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>"
)

## ----run-app, eval = FALSE----------------------------------------------------
# library(soilKey)
# run_classify_app()   # abre um app Shiny em uma única tela no navegador

## ----quick-start--------------------------------------------------------------
library(soilKey)

pedon <- make_ferralsol_canonical()   # Latossolo Vermelho canônico
classify_wrb2022(pedon, on_missing = "silent")$name
classify_sibcs(pedon)$name
classify_usda(pedon, on_missing = "silent")$name

## ----build-pedon--------------------------------------------------------------
meu_pedon <- PedonRecord$new(
  site = list(
    id              = "exemplo-001",
    lat             = -22.5,
    lon             = -43.7,
    country         = "BR",
    parent_material = "gnaisse"
  ),
  horizons = data.frame(
    top_cm      = c(0,  15, 65, 130),
    bottom_cm   = c(15, 65, 130, 200),
    designation = c("A", "AB", "Bw1", "Bw2"),
    munsell_hue_moist    = rep("2.5YR", 4),
    munsell_value_moist  = c(3, 3, 4, 4),
    munsell_chroma_moist = c(4, 6, 6, 6),
    clay_pct = c(50, 55, 60, 60),
    silt_pct = c(15, 10, 8,  8),
    sand_pct = c(35, 35, 32, 32),
    cec_cmol = c(8, 5.5, 5.0, 4.8),
    bs_pct   = c(24, 14, 13, 13),
    ph_h2o   = c(4.8, 4.7, 4.8, 4.9),
    oc_pct   = c(2.0, 0.6, 0.3, 0.2)
  )
)

## ----classify-three-systems---------------------------------------------------
res_wrb   <- classify_wrb2022(meu_pedon, on_missing = "silent")
res_sibcs <- classify_sibcs(meu_pedon, include_familia = TRUE)
res_usda  <- classify_usda(meu_pedon,  on_missing = "silent")

res_wrb$name
res_sibcs$name
res_usda$name

## ----classify-all-------------------------------------------------------------
todos <- classify_all(meu_pedon, on_missing = "silent")
todos$summary

## ----trace--------------------------------------------------------------------
res_wrb$trace

## ----prov---------------------------------------------------------------------
meu_pedon$add_measurement(
  horizon_idx = 4,
  attribute   = "clay_pct",
  value       = 60,
  source      = "predicted_spectra",
  confidence  = 0.85,
  notes       = "Vis-NIR PLSR-local, OSSL South-America library",
  overwrite   = TRUE
)

## ----cross-system-------------------------------------------------------------
todos <- classify_all(meu_pedon, on_missing = "silent")
data.frame(
  Sistema = c("WRB 2022", "SiBCS 5ª ed.", "USDA ST 13"),
  Nome    = c(todos$wrb$name, todos$sibcs$name, todos$usda$name)
)

