# Deploy plumber API to digital ocean droplet

# Packages ----
library(plumber)
library(plumberDeploy)
library(analogsea)

# Provision Digital Ocean droplet
plumber_do <- plumberDeploy::do_provision(name = "plumber", 
                                          region = "sfo2")
# Install R packages on droplet
install_r_package(plumber_do, "ggplot2")
install_r_package(plumber_do, "formattable")
install_r_package(plumber_do, "here")
install_r_package(plumber_do, "purrr")
install_r_package(plumber_do, "darksky")
install_r_package(plumber_do, "janitor")
install_r_package(plumber_do, "dplyr")

# Publish API to droplet
plumberDeploy::do_deploy_api(droplet = plumber_do,
                             path = "indego_forecast",
                             localPath = "./api/",
                             port = 8383,
                             forward = TRUE,
                             docs = TRUE)
