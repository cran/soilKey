## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>"
)
library(soilKey)

## ----classify-three-----------------------------------------------------------
pr <- make_ferralsol_canonical()

w <- classify_wrb2022(pr, on_missing = "silent")
s <- classify_sibcs (pr, on_missing = "silent")
u <- classify_usda  (pr, on_missing = "silent")

data.frame(
  System  = c("WRB 2022", "SiBCS 5", "USDA"),
  Class   = c(w$rsg_or_order, s$rsg_or_order, u$rsg_or_order),
  Full    = c(w$name, s$name, u$name)
)

## ----cross-table--------------------------------------------------------------
fxs <- list(
  Ferralsol  = make_ferralsol_canonical(),
  Acrisol    = make_acrisol_canonical(),
  Lixisol    = make_lixisol_canonical(),
  Luvisol    = make_luvisol_canonical(),
  Nitisol    = make_nitisol_canonical(),
  Vertisol   = make_vertisol_canonical(),
  Andosol    = make_andosol_canonical(),
  Histosol   = make_histosol_canonical(),
  Podzol     = make_podzol_canonical(),
  Cambisol   = make_cambisol_canonical(),
  Gleysol    = make_gleysol_canonical(),
  Plinthosol = make_plinthosol_canonical()
)

tab <- do.call(rbind, lapply(names(fxs), function(nm) {
  pr <- fxs[[nm]]
  data.frame(
    Fixture = nm,
    WRB     = classify_wrb2022(pr, on_missing = "silent")$rsg_or_order,
    SiBCS   = classify_sibcs (pr, on_missing = "silent")$rsg_or_order,
    USDA    = classify_usda  (pr, on_missing = "silent")$rsg_or_order
  )
}))
knitr::kable(tab)

## ----ferralsol-three-detail---------------------------------------------------
pr <- make_ferralsol_canonical()
w  <- classify_wrb2022(pr, on_missing = "silent")
s  <- classify_sibcs (pr, on_missing = "silent")
u  <- classify_usda  (pr, on_missing = "silent")

cat("WRB principal qualifiers:    ",
    paste(w$qualifiers$principal,     collapse = ", "), "\n")
cat("WRB supplementary qualifiers:",
    paste(w$qualifiers$supplementary, collapse = ", "), "\n")
cat("SiBCS subordem (2nd level):  ", s$rsg_or_order,    "\n")
cat("USDA suborder / great group: ", u$rsg_or_order,    "\n")

## ----sibcs-mapping------------------------------------------------------------
sibcs_expectations <- c(
  Ferralsol  = "Latossolos",
  Acrisol    = "Argissolos",
  Lixisol    = "Argissolos",
  Luvisol    = "Argissolos",
  Nitisol    = "Nitossolos",
  Vertisol   = "Vertissolos",
  Andosol    = "Cambissolos",   # Cambissolo Háplico Tb (Andic-leaning)
  Histosol   = "Organossolos",
  Podzol     = "Espodossolos",
  Plinthosol = "Plintossolos"
)

actual <- vapply(names(sibcs_expectations), function(nm) {
  fx <- get(paste0("make_", tolower(nm), "_canonical"))()
  classify_sibcs(fx, on_missing = "silent")$rsg_or_order
}, character(1))

data.frame(
  fixture       = names(sibcs_expectations),
  expected      = unname(sibcs_expectations),
  actual        = actual,
  match         = actual == sibcs_expectations
)

