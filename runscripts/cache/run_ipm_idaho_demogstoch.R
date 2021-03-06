##  Script to run IPM simulations for each site.

rm(list=ls(all=TRUE))
library(communitySynchrony)
library(IPMdoit)

do_env_const_vec <- TRUE
do_demo_stoch_vec <- TRUE
sim_names <- "DEMO"

Gpars_all <- readRDS("../results/growth_params_list.RDS")
Spars_all <- readRDS("../results/surv_params_list.RDS")
Rpars_all <- readRDS("../results/recruit_parameters.RDS")

# site_list <- names(Gpars_all)
site_list <- "Montana"
output_list <- list()

for(do_site in site_list){
  Gpars_tmp <- Gpars_all[[do_site]]
  Spars_tmp <- Spars_all[[do_site]]
  Rpars_tmp <- Rpars_all[[do_site]]
  
#   if(do_site=="Idaho"){
#     spp_list <- names(Gpars_tmp)
#     Rp <- as.data.frame(Rpars_tmp)
#     Rp$species <- c(rep(spp_list, each=4),
#                     rep(spp_list, each=1),
#                     rep(spp_list, each=6),
#                     rep(spp_list, each=1),
#                     rep(spp_list, each=1),
#                     rep(spp_list, each=22),
#                     rep(spp_list, each=412),
#                     rep(spp_list, each=1),
#                     rep(spp_list, each=1))
#     Rp <- subset(Rp, species!="ARTR")
#     colid <- which(colnames(Rp)=="species")
#     Rp <- Rp[,-colid]
#     Rp$species <- c(rep(c("ARTR", "fine", "fine", "fine"), 3),
#                     rep("fine", (nrow(Rp)-12)))
#     Rp <- subset(Rp, species=="fine")
#     colid <- which(colnames(Rp)=="species")
#     Rpars_tmp <- as.matrix(Rp[,-colid])
#   }
#   
#   if(do_site=="Idaho"){
#     id <- which(names(Gpars_tmp)=="ARTR")
#     Gpars_tmp <- Gpars_tmp[-id]
#     Spars_tmp <- Spars_tmp[-id] 
#   }
  
  spp_list <- names(Gpars_tmp)
  Nyrs <- nrow(Gpars_tmp[[1]])
  
  #Import and format parameters
  site_path <- paste("../data/", do_site, sep="")
  Gpars <- format_growth_params(do_site = do_site, species_list = spp_list, 
                                Nyrs = Nyrs, Gdata_species = Gpars_tmp)
  Spars <- format_survival_params(do_site = do_site, species_list = spp_list, 
                                  Nyrs = Nyrs, Sdata_species = Spars_tmp)
  Rpars <- format_recruitment_params(do_site = do_site, species_list = spp_list, 
                                     Nyrs = Nyrs, Rdata_species = Rpars_tmp,
                                     path_to_site_data = site_path)
  
  # Set iteration matrix dimensions and max genet sizes by site
  # these are all taken from Chu and Adler 2015 (Ecological Monographs)
  if(do_site=="Arizona"){
    iter_matrix_dims <- c(50,50)
    max_size <- c(170,40)
  }
  if(do_site=="Idaho"){
    iter_matrix_dims <- c(50,75,50,75)
    max_size <- c(3000,202,260,225)
  }
  if(do_site=="Kansas"){
    iter_matrix_dims <- c(75,50,75)
    max_size <- c(1656,823,2056)
  }
  if(do_site=="Montana"){
    iter_matrix_dims <- c(75,50,5,50)
    max_size <- c(2500,130,22,100)
  }
  if(do_site=="NewMexico"){
    iter_matrix_dims <- c(50,50)
    max_size <- c(600,1300)
  }
  
  stoch_results <- list()
  print(paste("Doing", do_site))
  for(stoch in 1:length(sim_names)){
    do_env_const <- do_env_const_vec[stoch]
    do_demo_stoch <- do_demo_stoch_vec[stoch]
    n_spp <- Nspp <- length(spp_list)
    A=10000
    tlimit=500
    burn_in=500
    spp_list=spp_list
    Nyrs=Nyrs; constant=do_env_const
    iter_matrix_dims=iter_matrix_dims; max_size=max_size
    Rpars=Rpars; Spars=Spars; Gpars=Gpars
    demographic_stochasticity=do_demo_stoch
    spp_interact=TRUE
    
    source("run_ipm_source.R") #returns covSave matrix
    colnames(covSave) <- spp_list
  } # end stochasticity loop
} # end site loop

# Save the output
# saveRDS(covSave, "../results/idaho_ipm_demogstoch_only_fromPACKAGE.RDS")

