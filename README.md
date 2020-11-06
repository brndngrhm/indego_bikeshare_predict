# Indego Bikeshare Prediction Model

### About

In this project I am focusing several objectives:

 * Developing a time series model with exogenous regressors using `prophet`
 * Servicing the model as an API
 * Deploy the model using Docker 
 * Writing more robust, modular R code
 * Writing unit tests
 
 This project is **not** about developing the best time series model to predict daily Indego trips. I am likely going to just use the `prophet` defaults.
 
### Docker resources

 *  https://towardsdatascience.com/deploy-machine-learning-pipeline-on-cloud-using-docker-container-bec64458dc01
 *  https://towardsdatascience.com/build-a-docker-container-with-your-machine-learning-model-3cf906f5e07e
 
 
 API
 lets other non R users consume your R work
 ML as a service deployed via an API - how?  
  - do you also need to make an app to interact with api?
  - how do others interact with a published api? does the api need a website?
 
 docker
 lets others reproduce your R work
 ML as a service deployed via docker
 
 
 ML as a service
  - you need someway of exposing your model
  expose just predictions or do you want a user to interact with them?
  could use rmd/shiny, or other web service like an api
  next level is to put the API in a docker container and deploy using docker
  
  