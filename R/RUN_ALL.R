
# Ensure the script runs in the directory where the script file is located
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

random_seed = 123

Sps_ini_file_template = "../msaWrapper_SPSignature_oclass_template.ini"
Sps_iterations = 200
Enet_iterations = 20
ini.data <- ini::read.ini(sub("../", "", Sps_ini_file_template))
Sps_regression_folder <- ini.data$`OUTCOME PREDICTION: MULTI-RISK SCORE APPLICATION`$`regression dir`

setwd("Make_Train_Test_Sets/")
source("Make_train_test_sets_matchRandomTrain.R") 
setwd("..")


setwd("dotblot/"); rmarkdown::render("Dotblot Analysis.Rmd"); setwd("..")
setwd("dl_GAN32/"); rmarkdown::render("Deep Learning Analysis.Rmd"); setwd("..")
setwd("flow/"); rmarkdown::render("Flow Cytometry Analysis.Rmd"); setwd("..")
setwd("texrad/"); rmarkdown::render("TexRad Analysis.Rmd"); setwd("..")

setwd("flow_dl_GAN32/"); rmarkdown::render("Flow DL Analysis.Rmd"); setwd("..")
setwd("flow_texrad/"); rmarkdown::render("Flow TexRad Analysis.Rmd"); setwd("..")
setwd("texrad_dl_GAN32/"); rmarkdown::render("TexRad DL Analysis.Rmd"); setwd("..")

setwd("flow_texrad_dl_GAN32/"); rmarkdown::render("Flow TexRad DL Analysis.Rmd"); setwd("..")
setwd("flow_texrad_dl_GAN32_features/"); rmarkdown::render("Flow TexRad DL Features Analysis.Rmd"); setwd("..")
setwd("flow_texrad_dl_GAN32_signatures/"); rmarkdown::render("Flow TexRad DL Signatures Analysis.Rmd"); setwd("..")

rmarkdown::render("Overall Results_GAN32.Rmd")

