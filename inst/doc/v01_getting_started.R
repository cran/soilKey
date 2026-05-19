## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>"
)

## ----run-demo, eval = FALSE---------------------------------------------------
# library(soilKey)
# run_demo()  # opens a one-screen Shiny app in your browser

## ----quick-start--------------------------------------------------------------
library(soilKey)

pedon <- make_ferralsol_canonical()      # canonical Latossolo Vermelho
classify_wrb2022(pedon, on_missing = "silent")$name
classify_sibcs(pedon)$name
classify_usda(pedon, on_missing = "silent")$name

## ----build-pedon--------------------------------------------------------------
my_pedon <- PedonRecord$new(
  site = list(
    id              = "example-001",
    lat             = -22.5,
    lon             = -43.7,
    country         = "BR",
    parent_material = "gneiss"
  ),
  horizons = data.frame(
    top_cm      = c(0,  15, 65, 130),
    bottom_cm   = c(15, 65, 130, 200),
    designation = c("A", "Bw1", "Bw2", "C"),
    clay_pct    = c(50, 60,  65,  60),
    silt_pct    = c(15, 10,  8,   8),
    sand_pct    = c(35, 30,  27,  32),
    cec_cmol    = c(8,  5,   4.5, 4),
    bs_pct      = c(20, 12,  10,  11),
    ph_h2o      = c(4.8, 4.9, 5.0, 5.1),
    oc_pct      = c(2.0, 0.4, 0.2, 0.1)
  )
)

my_pedon$validate()

## ----fixture-list-------------------------------------------------------------
fixtures <- list(
  Ferralsol  = make_ferralsol_canonical(),
  Luvisol    = make_luvisol_canonical(),
  Acrisol    = make_acrisol_canonical(),
  Lixisol    = make_lixisol_canonical(),
  Alisol     = make_alisol_canonical(),
  Chernozem  = make_chernozem_canonical(),
  Kastanozem = make_kastanozem_canonical(),
  Phaeozem   = make_phaeozem_canonical(),
  Calcisol   = make_calcisol_canonical(),
  Gypsisol   = make_gypsisol_canonical(),
  Solonchak  = make_solonchak_canonical(),
  Cambisol   = make_cambisol_canonical(),
  Plinthosol = make_plinthosol_canonical(),
  Podzol     = make_podzol_canonical(),
  Gleysol    = make_gleysol_canonical(),
  Vertisol   = make_vertisol_canonical()
)

ferralsol <- fixtures$Ferralsol
ferralsol

## ----ferralic-----------------------------------------------------------------
ferralic(ferralsol)

## ----matrix, results='asis'---------------------------------------------------
diagnostics <- c("argic", "ferralic", "mollic", "calcic", "gypsic", "salic",
                  "cambic", "plinthic", "spodic",
                  "gleyic_properties", "vertic_properties")

mat <- vapply(fixtures, function(p) {
  vapply(diagnostics, function(d) {
    fn <- get(d, envir = asNamespace("soilKey"))
    isTRUE(fn(p)$passed)
  }, logical(1))
}, logical(length(diagnostics)))

knitr::kable(t(mat))

## ----argic-derived------------------------------------------------------------
acrisol(make_acrisol_canonical())$passed
lixisol(make_lixisol_canonical())$passed
alisol (make_alisol_canonical())$passed
luvisol(make_luvisol_canonical())$passed

## ----mollic-derived-----------------------------------------------------------
chernozem (make_chernozem_canonical())$passed
kastanozem(make_kastanozem_canonical())$passed
phaeozem  (make_phaeozem_canonical())$passed

## ----classify-fr--------------------------------------------------------------
classify_wrb2022(ferralsol)

## ----classify-all-------------------------------------------------------------
classifications <- vapply(fixtures, function(p) {
  classify_wrb2022(p, on_missing = "silent")$rsg_or_order
}, character(1))
data.frame(fixture = names(classifications), assigned_rsg = classifications)

## ----provenance---------------------------------------------------------------
ferralsol_v <- make_ferralsol_canonical()

# Mark the Bw1 clay value as predicted from spectroscopy
ferralsol_v$add_measurement(
  horizon_idx = 4,
  attribute   = "clay_pct",
  value       = 60,
  source      = "predicted_spectra",
  confidence  = 0.85,
  overwrite   = TRUE
)

classify_wrb2022(ferralsol_v)$evidence_grade

## ----provenance-vlm-----------------------------------------------------------
ferralsol_w <- make_ferralsol_canonical()
ferralsol_w$add_measurement(1, "clay_pct", 50, "extracted_vlm",
                              confidence = 0.7, overwrite = TRUE)
classify_wrb2022(ferralsol_w)$evidence_grade

## ----to-aqp, eval = requireNamespace("aqp", quietly = TRUE)-------------------
spc <- ferralsol$to_aqp()
class(spc)
aqp::profile_id(spc)

## ----ossl, eval = FALSE-------------------------------------------------------
# # Synthetic example -- a profile with measured spectra but missing CEC.
# pr_spec <- make_synthetic_pedon_with_spectra(n_horizons = 4)
# pr_spec$horizons$cec_cmol <- NA_real_   # erase CEC
# 
# # Predict via memory-based learning against the OSSL global library.
# pr_filled <- fill_from_spectra(
#   pedon   = pr_spec,
#   backend = "mbl",         # or "plsr_local" / "pretrained"
#   attrs   = c("cec_cmol")  # which attributes to gap-fill
# )
# 
# # Each predicted cell is logged with provenance source = "predicted_spectra".
# pr_filled$provenance
# classify_wrb2022(pr_filled)$evidence_grade   # B (predicted_spectra present)

## ----prior, eval = FALSE------------------------------------------------------
# prior <- spatial_prior(lon = -43.7, lat = -22.5, source = "auto")
# prior   # data.table of (rsg_code, probability)
# 
# res <- classify_wrb2022(
#   pedon           = ferralsol,
#   prior           = prior,
#   prior_threshold = 0.01   # warn if assigned RSG has prior < 1%
# )
# res$prior_check

## ----vlm-mock, eval = FALSE---------------------------------------------------
# mock <- MockVLMProvider$new(
#   responses = list(
#     list(horizons = list(
#       list(top_cm = 0,  bottom_cm = 15, designation = "A",
#             clay_pct = list(value = 30, confidence = 0.9,
#                             source_quote = "30% clay (table 1)")),
#       list(top_cm = 15, bottom_cm = 65, designation = "Bw",
#             clay_pct = list(value = 55, confidence = 0.85,
#                             source_quote = "Bw horizon, 55% clay"))
#     ))
#   )
# )
# pr_extracted <- extract_horizons_from_pdf(
#   pdf_path = "fieldsheet.pdf",
#   provider = mock          # in production: vlm_provider("anthropic")
# )
# classify_wrb2022(pr_extracted)$evidence_grade   # C or D depending on cell coverage

## ----vlm-real, eval = FALSE---------------------------------------------------
# chat <- vlm_provider("anthropic", model = "claude-sonnet-4-5")
# pr   <- extract_horizons_from_pdf("RADAMBRASIL_perfil_007.pdf",
#                                     provider = chat)
# res  <- classify_wrb2022(pr)
# res

## ----sibcs-demo---------------------------------------------------------------
# A canonical Latossolo (Brazilian Ferralsol equivalent)
pr_lat <- make_latossolo_canonical()
classify_sibcs(pr_lat, on_missing = "silent")$rsg_or_order

# A canonical Argissolo (B textural, low BS)
pr_arg <- make_argissolo_canonical()
classify_sibcs(pr_arg, on_missing = "silent")$rsg_or_order

# A canonical Nitossolo (clay >=35% throughout, B/A <=1.5, cerosidade)
pr_nit <- make_nitossolo_canonical()
classify_sibcs(pr_nit, on_missing = "silent")$rsg_or_order

# Cross-system: the SAME profile classified by both keys
classify_wrb2022(pr_lat, on_missing = "silent")$rsg_or_order
classify_sibcs(pr_lat, on_missing = "silent")$rsg_or_order

## ----sibcs-atributos----------------------------------------------------------
# Atividade da fração argila (Ta vs Tb) per Cap 1, p 30
atividade_argila_alta(make_luvissolo_canonical())$passed   # TRUE  -> Ta
atividade_argila_alta(make_nitossolo_canonical())$passed   # FALSE -> Tb

# Caráter alítico (Cap 1, p 32): Al >= 4 cmol_c/kg + sat Al >= 50% + V < 50%
carater_alitico(make_argissolo_canonical())$passed

