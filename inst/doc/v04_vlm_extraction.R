## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>"
)
library(soilKey)

## ----mock---------------------------------------------------------------------
mock <- MockVLMProvider$new(responses = list())
class(mock)

## ----schema-peek, eval = requireNamespace("jsonlite", quietly = TRUE)---------
sch <- jsonlite::fromJSON(soilKey:::load_schema("horizon"),
                            simplifyVector = FALSE)
length(sch$properties$horizons$items$properties)
head(names(sch$properties$horizons$items$properties), 12)

## ----mock-response------------------------------------------------------------
horizon_json <- '{
  "horizons": [
    {
      "top_cm": 0,
      "bottom_cm": 15,
      "designation": "A",
      "munsell_moist": {"hue": "2.5YR", "value": 3, "chroma": 4,
                          "confidence": 0.85, "source_quote": "vermelho-escuro"},
      "clay_pct": {"value": 50, "confidence": 0.9, "source_quote": "muito argilosa (50%)"},
      "oc_pct"  : {"value": 2.0, "confidence": 0.85, "source_quote": "C org. 2.0%"}
    },
    {
      "top_cm": 15,
      "bottom_cm": 65,
      "designation": "Bw1",
      "munsell_moist": {"hue": "2.5YR", "value": 3, "chroma": 6,
                          "confidence": 0.85, "source_quote": "vermelho"},
      "clay_pct": {"value": 60, "confidence": 0.9, "source_quote": "muito argilosa"},
      "oc_pct"  : {"value": 1.2, "confidence": 0.85, "source_quote": "C org. 1.2%"}
    }
  ]
}'

## ----validate-or-retry, eval = requireNamespace("jsonlite", quietly = TRUE) && requireNamespace("jsonvalidate", quietly = TRUE)----
mock <- MockVLMProvider$new(responses = list(horizon_json))

res <- soilKey:::validate_or_retry(
  provider    = mock,
  prompt      = "extract horizons from <fake document>",
  schema      = "horizon",
  max_retries = 0L
)

str(res, max.level = 2)

## ----apply, eval = requireNamespace("jsonlite", quietly = TRUE) && requireNamespace("jsonvalidate", quietly = TRUE)----
pr <- PedonRecord$new(
  site = list(id = "VLM-demo", lat = -22.5, lon = -43.7,
                country = "BR", parent_material = "gneiss"),
  horizons = data.table::data.table(top_cm = numeric(0), bottom_cm = numeric(0))
)

added <- soilKey:::apply_horizons_extraction(pr, res$data, overwrite = TRUE)
cat("Provenance entries added:", added, "\n")

# Inspect what landed in the horizons table.
pr$horizons[, .(top_cm, bottom_cm, designation,
                munsell_hue_moist, munsell_value_moist, munsell_chroma_moist,
                clay_pct, oc_pct)]

## ----grade, eval = requireNamespace("jsonlite", quietly = TRUE) && requireNamespace("jsonvalidate", quietly = TRUE)----
prov <- pr$provenance
head(prov[, .(horizon_idx, attribute, source, confidence)])

## ----ollama, eval = FALSE-----------------------------------------------------
# # Local Gemma 4 edge -- multimodal text + image (and audio).
# provider <- vlm_provider("ollama")             # default: gemma4:e4b
# # provider <- vlm_provider("ollama", model = "gemma4:31b")  # frontier
# 
# extract_horizons_from_pdf(
#   pedon       = pr,
#   pdf_path    = "field-reports/perfil-LV-001.pdf",
#   provider    = provider,
#   max_retries = 3L
# )

## ----ellmer, eval = FALSE-----------------------------------------------------
# # install.packages("ellmer")
# 
# # Anthropic Claude (needs ANTHROPIC_API_KEY in the environment).
# provider <- vlm_provider("anthropic")          # default: claude-sonnet-4-7
# 
# # Or OpenAI / Google in the same one-liner shape:
# # provider <- vlm_provider("openai")           # default: gpt-4o
# # provider <- vlm_provider("google")           # default: gemini-2.0-pro
# 
# extract_horizons_from_pdf(
#   pedon       = pr,
#   pdf_path    = "field-reports/perfil-LV-001.pdf",
#   provider    = provider,
#   max_retries = 3L
# )

## ----one-liner, eval = FALSE--------------------------------------------------
# res <- classify_from_documents(
#   pdf      = "perfil_042_descricao.pdf",
#   image    = "perfil_042_parede.jpg",
#   report   = "perfil_042.html"            # optional output report
# )
# 
# res$classifications$wrb$name
# #> "Geric Ferric Rhodic Chromic Ferralsol (Clayic, Humic, Dystric, Ochric, Rubic)"
# 
# res$classifications$sibcs$name
# #> "Latossolos Vermelhos Distroficos tipicos, argilosa, moderado"
# 
# res$classifications$usda$name
# #> "Rhodic Hapludox"

