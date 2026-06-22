## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  eval     = FALSE
)

## ----launch-------------------------------------------------------------------
# library(soilKey)
# 
# # The professional multi-tab app (default).
# run_classify_app()
# 
# # Equivalent, explicit:
# run_classify_app(ui = "pro")
# 
# # The original single-page CSV uploader (v0.9.39 layout):
# run_classify_app(ui = "classic")

## ----deps---------------------------------------------------------------------
# install.packages(c("shiny", "DT", "bslib", "shinyWidgets", "plotly"))

## ----vlm----------------------------------------------------------------------
# options(soilKey.vlm_chat = ellmer::chat_anthropic())
# run_classify_app()

## ----raster-------------------------------------------------------------------
# options(soilKey.test_raster = "/path/to/a/wrb_raster.tif")

