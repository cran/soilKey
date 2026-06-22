## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  fig.width  = 6,
  fig.height = 4
)
library(soilKey)

## ----profile-data-------------------------------------------------------------
horizontes <- data.table::data.table(
  top_cm                = c(0,    20,   55,   115,  170),
  bottom_cm             = c(20,   55,   115,  170,  220),
  designation           = c("A",  "AB", "Bt1","Bt2","BC"),
  munsell_hue_moist     = c("10YR","7.5YR","5YR","2.5YR","2.5YR"),
  munsell_value_moist   = c(4,     4,     4,     3,     3),
  munsell_chroma_moist  = c(3,     5,     6,     6,     6),
  structure_grade       = c("moderate", "moderate",
                              "strong", "strong", "moderate"),
  structure_type        = c("granular", "subangular blocky",
                              "subangular blocky",
                              "subangular blocky",
                              "subangular blocky"),
  clay_films_amount     = c(NA, "few", "common", "common", "few"),
  clay_pct              = c(18,   28,   45,   42,   38),
  silt_pct              = c(30,   25,   20,   22,   24),
  sand_pct              = c(52,   47,   35,   36,   38),
  ph_h2o                = c(5.5,  5.3,  5.0,  5.0,  5.1),
  ph_kcl                = c(4.4,  4.3,  4.1,  4.1,  4.2),
  oc_pct                = c(1.5,  0.6,  0.3,  0.2,  0.2),
  cec_cmol              = c(8.0,  6.0,  5.5,  4.5,  4.0),
  bs_pct                = c(35,   25,   20,   18,   20),   # V baixa -> distrofico
  al_cmol               = c(0.5,  0.8,  1.2,  1.5,  1.4),
  ca_cmol               = c(2.0,  1.4,  1.0,  0.7,  0.7),
  mg_cmol               = c(0.6,  0.4,  0.3,  0.2,  0.2),
  k_cmol                = c(0.10, 0.06, 0.04, 0.03, 0.03),
  na_cmol               = c(0.02, 0.02, 0.02, 0.02, 0.02),
  bulk_density_g_cm3    = c(1.30, 1.40, 1.45, 1.45, 1.42)
)
horizontes <- soilKey:::ensure_horizon_schema(horizontes)
str(horizontes[, .(designation, top_cm, bottom_cm, ph_h2o, clay_pct, bs_pct)])

## ----pedon--------------------------------------------------------------------
perfil <- PedonRecord$new(
  site = list(
    id        = "RJ-1-Itaguai",
    lat       = -22.86,
    lon       = -43.78,
    country   = "BR",
    state     = "RJ",
    municipality = "Itaguai",
    parent_material = "sedimentos argilosos do Terciario",
    survey_year = 2003,
    reference_source = "Embrapa Solos (2003) - Levantamento RJ"
  ),
  horizons = horizontes
)
perfil

## ----diagnostics--------------------------------------------------------------
# B textural (SiBCS Cap 5 / WRB argic): gradiente de argila
bt   <- soilKey::B_textural(perfil)
arg  <- soilKey::argic(perfil)
cat("B_textural (SiBCS):", bt$passed,
    "  argic (WRB):",     arg$passed, "\n")

# Atividade da argila (SiBCS Cap 5)
ta <- soilKey:::atividade_argila_alta(perfil)
cat("atividade_argila_alta:", ta$passed, "\n")

# Saturacao por bases (V%) -- distrofico se V < 50
distr <- soilKey::distrofico(perfil)
cat("distrofico:", distr$passed, "\n")

## ----classify-all-------------------------------------------------------------
res <- soilKey::classify_all(perfil, on_missing = "silent")
names(res)

## ----sibcs--------------------------------------------------------------------
print(res$sibcs)

## ----wrb----------------------------------------------------------------------
print(res$wrb)

## ----usda---------------------------------------------------------------------
print(res$usda)

## ----comparison---------------------------------------------------------------
data.frame(
  Sistema  = c("SiBCS 5a", "WRB 2022", "USDA-ST 13a"),
  Classe   = c(res$sibcs$name, res$wrb$name, res$usda$name),
  EvidGrade = c(res$sibcs$evidence_grade %||% NA,
                  res$wrb$evidence_grade   %||% NA,
                  res$usda$evidence_grade  %||% NA)
)

## ----report, eval = FALSE-----------------------------------------------------
# res$sibcs$report(
#   file  = "perfil_RJ1.html",
#   format = "html",
#   pedon = perfil
# )
# # Ou, para os tres sistemas em um arquivo:
# soilKey::report(
#   list(res$sibcs, res$wrb, res$usda),
#   file  = "perfil_RJ1_triplo.html",
#   format = "html",
#   pedon = perfil
# )

## ----mapbiomas, eval = FALSE--------------------------------------------------
# sibcs_no_mapa <- soilKey::lookup_mapbiomas_solos(
#   coords      = c(perfil$site$lon, perfil$site$lat),
#   raster_path = "soil_data/mapbiomas/mapbiomas_solos_30m_2023.tif",
#   legend      = data.frame(
#     value      = c(3),
#     class_name = c("Argissolo Vermelho-Amarelo")
#   )
# )
# sibcs_no_mapa
# #> [1] "Argissolo Vermelho-Amarelo"

## ----soilgrids, eval = FALSE--------------------------------------------------
# ph_topsoil <- soilKey::lookup_soilgrids(
#   coords   = c(perfil$site$lon, perfil$site$lat),
#   property = "phh2o",  depth = "0-5cm", quantile = "mean"
# )
# clay_subsoil <- soilKey::lookup_soilgrids(
#   coords   = c(perfil$site$lon, perfil$site$lat),
#   property = "clay",   depth = "30-60cm", quantile = "mean"
# )
# cat("SoilGrids pH (0-5cm):", ph_topsoil,
#     " | clay subsoil (30-60cm):", clay_subsoil, "%\n")

