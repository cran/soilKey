## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>"
)
library(soilKey)

## ----build-pedon--------------------------------------------------------------
pr <- make_ferralsol_canonical()
pr

## ----horizons-table-----------------------------------------------------------
knitr::kable(
  pr$horizons[, .(top_cm, bottom_cm, designation,
                  munsell_hue_moist, munsell_value_moist, munsell_chroma_moist,
                  clay_pct, oc_pct, cec_cmol, bs_pct,
                  ph_h2o, ph_kcl)]
)

## ----classify-----------------------------------------------------------------
res <- classify_wrb2022(pr)
res

## ----resolve-principal--------------------------------------------------------
qres <- resolve_wrb_qualifiers(pr, "FR")
qres$principal

## ----principal-table, echo = FALSE--------------------------------------------
data.frame(
  Qualifier   = qres$principal,
  Why = c(
    Geric   = "ECEC = sum of bases + Al_KCl <= 1.5 cmol+/kg fine earth in some layer of the upper 100 cm. Layer 4 (Bw1, top = 65 cm) has ECEC = 1.18 cmol+/kg.",
    Ferric  = "Iron-rich subsoil (Fe_dcb >= 5%); fe_dcb_pct hits 8-9% in this fixture.",
    Rhodic  = "Hue 2.5YR moist, value < 4 in 25-150 cm. Bw1 has value = 4 (failing in some layers but BA satisfies value 3).",
    Chromic = "Hue redder than 7.5YR + chroma > 4 in 25-150 cm subsoil. Bw1 chroma = 6 satisfies."
  )[qres$principal],
  row.names = NULL
)

## ----principal-trace----------------------------------------------------------
trace_df <- do.call(
  rbind,
  lapply(names(qres$trace), function(q) {
    t <- qres$trace[[q]]
    data.frame(qualifier = q,
               passed    = if (is.null(t$passed)) NA else t$passed,
               note      = t$note %||% "")
  })
)
head(trace_df, 12)

## ----resolve-suppl------------------------------------------------------------
qres$supplementary

## ----suppl-table, echo = FALSE------------------------------------------------
data.frame(
  Qualifier = qres$supplementary,
  Why = c(
    Clayic  = "Clay >= 60 % over a layer thicker than 30 cm in the upper 100 cm; Bw1 has clay = 60% over 65 cm.",
    Humic   = "Weighted OC >= 1 % in the upper 50 cm; weighted OC ~ 1.1 % here.",
    Dystric = "BS < 50 % throughout 20-100 cm; BS = 13-24 % across all four upper layers.",
    Ochric  = "OC >= 0.2 % in upper 10 cm + no mollic + no umbric; surface has OC = 2.0 %.",
    Rubic   = "Hue <= 5YR + chroma >= 4 in upper 100 cm (less strict than Rhodic). 2.5YR / 6 satisfies."
  )[qres$supplementary],
  row.names = NULL
)

## ----format-------------------------------------------------------------------
format_wrb_name(
  rsg_name      = "Ferralsols",
  principal     = qres$principal,
  supplementary = qres$supplementary
)

## ----families-----------------------------------------------------------------
str(soilKey:::.wrb_qualifier_families)

## ----suppress-demo------------------------------------------------------------
soilKey:::.suppress_qualifier_siblings(
  c("Mollic", "Calcic", "Hypocalcic", "Protocalcic", "Cambic")
)

## ----grade--------------------------------------------------------------------
res$evidence_grade

## ----report, eval = FALSE-----------------------------------------------------
# # Pass the three classifications as a list:
# results <- list(
#   classify_wrb2022(pr),
#   classify_sibcs(pr, include_familia = TRUE),
#   classify_usda(pr)
# )
# out_html <- file.path(tempdir(), "perfil_ferralsol.html")
# report(results, file = out_html, pedon = pr)
# 
# # Or pass the pedon directly and let report() run the three keys:
# report(pr, file = out_html)
# 
# # Same content as PDF (requires LaTeX):
# # report(pr, file = file.path(tempdir(), "perfil_ferralsol.pdf"))

## ----summary, echo = FALSE----------------------------------------------------
cat(sprintf("WRB 2022 name : %s\n", res$name))
cat(sprintf("Assigned RSG  : %s\n", res$rsg_or_order))
cat(sprintf("Principal     : %s\n", paste(res$qualifiers$principal,     collapse = ", ")))
cat(sprintf("Supplementary : %s\n", paste(res$qualifiers$supplementary, collapse = ", ")))
cat(sprintf("Evidence grade: %s\n", res$evidence_grade))

