## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>"
)
library(soilKey)

## ----mini-benchmark-----------------------------------------------------------
expected <- c(
  HS = "Histosols", AT = "Anthrosols", TC = "Technosols", CR = "Cryosols",
  LP = "Leptosols", SN = "Solonetz",   VR = "Vertisols", SC = "Solonchaks",
  GL = "Gleysols",  AN = "Andosols",   PZ = "Podzols",   PT = "Plinthosols",
  PL = "Planosols", ST = "Stagnosols", NT = "Nitisols",  FR = "Ferralsols",
  CH = "Chernozems", KS = "Kastanozems", PH = "Phaeozems", UM = "Umbrisols",
  DU = "Durisols",  GY = "Gypsisols", CL = "Calcisols", RT = "Retisols",
  AC = "Acrisols",  LX = "Lixisols",   AL = "Alisols",   LV = "Luvisols",
  CM = "Cambisols", AR = "Arenosols",  FL = "Fluvisols"
)

fixfns <- list(
  HS = make_histosol_canonical,  AT = make_anthrosol_canonical,
  TC = make_technosol_canonical, CR = make_cryosol_canonical,
  LP = make_leptosol_canonical,  SN = make_solonetz_canonical,
  VR = make_vertisol_canonical,  SC = make_solonchak_canonical,
  GL = make_gleysol_canonical,   AN = make_andosol_canonical,
  PZ = make_podzol_canonical,    PT = make_plinthosol_canonical,
  PL = make_planosol_canonical,  ST = make_stagnosol_canonical,
  NT = make_nitisol_canonical,   FR = make_ferralsol_canonical,
  CH = make_chernozem_canonical, KS = make_kastanozem_canonical,
  PH = make_phaeozem_canonical,  UM = make_umbrisol_canonical,
  DU = make_durisol_canonical,   GY = make_gypsisol_canonical,
  CL = make_calcisol_canonical,  RT = make_retisol_canonical,
  AC = make_acrisol_canonical,   LX = make_lixisol_canonical,
  AL = make_alisol_canonical,    LV = make_luvisol_canonical,
  CM = make_cambisol_canonical,  AR = make_arenosol_canonical,
  FL = make_fluvisol_canonical
)

bench <- do.call(rbind, lapply(names(expected), function(code) {
  fx <- fixfns[[code]]()
  res <- classify_wrb2022(fx, on_missing = "silent")
  data.frame(
    fixture  = code,
    target   = expected[[code]],
    assigned = res$rsg_or_order,
    name     = res$name,
    grade    = res$evidence_grade,
    match    = res$rsg_or_order == expected[[code]]
  )
}))

knitr::kable(bench[, c("fixture", "target", "assigned", "match", "grade")])

## ----mini-stats---------------------------------------------------------------
data.frame(
  metric = c("n_profiles", "top1_agreement",
             "indeterminate_rate", "evidence_grade_A",
             "evidence_grade_B"),
  value  = c(nrow(bench),
             mean(bench$match),
             mean(is.na(bench$assigned)),
             mean(bench$grade == "A"),
             mean(bench$grade == "B"))
)

## ----mini-confusion-----------------------------------------------------------
table(target = bench$target, assigned = bench$assigned)

## ----mini-qualifier-----------------------------------------------------------
qualifier_prefix <- vapply(names(expected), function(code) {
  fx <- fixfns[[code]]()
  res <- classify_wrb2022(fx, on_missing = "silent")
  if (length(res$qualifiers$principal) == 0) NA_character_
  else res$qualifiers$principal[1]
}, character(1))

knitr::kable(
  data.frame(fixture          = names(qualifier_prefix),
             principal_prefix = qualifier_prefix),
  caption = "Most-specific principal qualifier per canonical fixture."
)

## ----wosis-protocol, eval = FALSE---------------------------------------------
# library(soilKey)
# 
# # 1. Pull a snapshot of WoSIS profiles via the WoSIS API.
# profiles <- read_wosis_profiles(
#   url     = "https://wosis.isric.org/api/v3/profiles?format=json",
#   page_size = 500L
# )
# 
# # 2. Build a PedonRecord per profile.
# pedons <- lapply(profiles, build_pedon_from_wosis)
# 
# # 3. Classify each through the v0.9.3 key.
# classifications <- lapply(pedons, classify_wrb2022, on_missing = "silent")
# 
# # 4. Compare against the WoSIS-recorded RSG.
# bench <- mapply(function(c, p) {
#   data.frame(
#     profile_id  = p$site$id,
#     target_rsg  = p$site$wosis_rsg,
#     assigned    = c$rsg_or_order,
#     grade       = c$evidence_grade,
#     match       = c$rsg_or_order == p$site$wosis_rsg
#   )
# }, classifications, pedons, SIMPLIFY = FALSE)
# bench <- do.call(rbind, bench)
# 
# # 5. Headline numbers.
# list(
#   n              = nrow(bench),
#   top1           = mean(bench$match, na.rm = TRUE),
#   indeterminate  = mean(is.na(bench$assigned)),
#   pct_grade_A    = mean(bench$grade == "A"),
#   by_rsg         = table(bench$target_rsg, bench$assigned)
# )

## ----canonical-bench, eval = FALSE--------------------------------------------
# source(system.file("benchmarks", "run_wosis_benchmark.R",
#                     package = "soilKey"))
# bench <- run_canonical_benchmark()

## ----retry-demo, eval = FALSE-------------------------------------------------
# source(system.file("benchmarks", "run_wosis_benchmark.R",
#                     package = "soilKey"))
# profs <- read_wosis_profiles_graphql(
#   continent = "South America",
#   n_max     = 100L,
#   page_size = 10L,
#   verbose   = TRUE
# )
# length(profs)
# #> [1] 40   # 100 was requested but server timed out at offset = 40;
# #>          # the partial pull was returned cleanly.

## ----bundled, eval = FALSE----------------------------------------------------
# sample <- load_wosis_sample()
# length(sample$pedons)
# #> [1] 40
# 
# sample$pulled_on
# #> [1] "2026-05-03"
# 
# # Classify offline:
# classify_wrb2022(sample$pedons[[1]])$rsg_or_order

