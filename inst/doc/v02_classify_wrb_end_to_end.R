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
fr <- unlist(yaml::read_yaml(system.file("rules/wrb2022/qualifiers.yaml",
                                         package = "soilKey"))$rsg_qualifiers$FR$principal)
rank <- vapply(qres$principal, function(q)
  which(vapply(strsplit(fr, "/", fixed = TRUE), function(a) q %in% a, logical(1)))[1],
  integer(1))
data.frame(Qualifier = qres$principal, `Rank in Chapter 4` = rank,
           check.names = FALSE, row.names = NULL)

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
  Reference = vapply(qres$supplementary, function(q) {
    fn <- get0(paste0("qual_", tolower(q)), envir = asNamespace("soilKey"))
    r <- tryCatch(if ("rsg_code" %in% names(formals(fn))) fn(pr, rsg_code = "FR") else fn(pr),
                  error = function(e) NULL)
    if (is.null(r$reference)) "" else r$reference
  }, character(1)),
  row.names = NULL
)

## ----format-------------------------------------------------------------------
format_wrb_name(
  rsg_name      = "Ferralsols",
  principal     = qres$principal,
  supplementary = qres$supplementary
)

## ----redundant----------------------------------------------------------------
soilKey:::.drop_redundant_qualifiers(c("Calcaric", "Hypereutric"),
                                     c("Calcaric", "Hypereutric"))

## ----families-----------------------------------------------------------------
str(soilKey:::.wrb_qualifier_families)
soilKey:::.suppress_qualifier_siblings(
  c("Mollic", "Hypercalcic", "Calcic", "Protocalcic", "Cambic")
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
# report(results, file = "perfil_ferralsol.html", pedon = pr)
# 
# # Or pass the pedon directly and let report() run the three keys:
# report(pr, file = "perfil_ferralsol.html")
# 
# # Same content as PDF (requires LaTeX):
# # report(pr, file = "perfil_ferralsol.pdf")

## ----strict, eval = FALSE-----------------------------------------------------
# # A profile with 32 % clay above a vertic horizon: a Vertisol under the
# # default gate, but below the 35 % strict floor.
# classify_wrb2022(pr, strict = FALSE)$rsg_or_order  # default
# classify_wrb2022(pr, strict = TRUE)$rsg_or_order   # Tier-3 strict

## ----summary, echo = FALSE----------------------------------------------------
cat(sprintf("WRB 2022 name : %s\n", res$name))
cat(sprintf("Assigned RSG  : %s\n", res$rsg_or_order))
cat(sprintf("Principal     : %s\n", paste(res$qualifiers$principal,     collapse = ", ")))
cat(sprintf("Supplementary : %s\n", paste(res$qualifiers$supplementary, collapse = ", ")))
cat(sprintf("Evidence grade: %s\n", res$evidence_grade))

