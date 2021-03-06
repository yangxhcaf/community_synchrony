##  Script to source recruitment regression function

rm(list=ls(all.names=TRUE))

source("recruitment_function_ss.R")

# Set up some paths and lists
path_to_data <- "../../data/"
site_list <- list.files(path_to_data)
removes <- c(grep("*.csv", site_list),
             grep("Climate", site_list),
             grep("Crowding", site_list))
site_list <- site_list[-removes]

recruit_params_site_list <- list()
for(do_site in site_list){
  species_list <- list.files(paste(path_to_data, do_site, "/", sep=""))
  
  i <- 1 #counter
  for(do_species in species_list){
    tmpfile <- paste(path_to_data, do_site, "/", do_species,"/recArea.csv",sep="")
    tmpD <- read.csv(tmpfile)
    
    # Add group info for each site individually, as needed
    if(do_site=="Arizona"){
      tmpD$Group=as.factor(substr(tmpD$quad,1,1))
      tmpD=subset(tmpD,year>=17)
    }
    if(do_site=="Kansas")
      tmpD$Group=as.numeric(tmpD$Group)-1
    if(do_site=="Montana"){
      ##then we moved some specific points:
      tmp2<-which(tmpD$quad=="A12" & tmpD$year==44)
      tmp3<-which(tmpD$quad=="B1"  & tmpD$year==44)
      tmp41<-which(tmpD$quad=="E4" & tmpD$year==33) 
      tmp42<-which(tmpD$quad=="E4" & tmpD$year==34) 
      tmp43<-which(tmpD$quad=="E4" & tmpD$year==43)
      tmp44<-which(tmpD$quad=="E4" & tmpD$year==44)
      tmpD$Group=as.factor(substr(tmpD$quad,1,1)) 
    }
    if(do_site=="NewMexico")
      tmpD$Group=as.factor(substr(tmpD$quad,1,1))
    
    # Get the years right for Kansas
    if(do_site=="Kansas"){
      tmpD <- subset(tmpD, year<68)
      ##to remove some points:
      #for q25
      tmp1<-which(tmpD$quad=="q25")
      #for q27
      tmp2<-which(tmpD$quad=="q27")
      #for q28
      tmp3<-which(tmpD$quad=="q28")
      #for q30
      tmp4<-which(tmpD$quad=="q30")
      #for q31
      tmp5<-which(tmpD$quad=="q31" & (tmpD$year<35 | tmpD$year>39))
      #for q32
      tmp6<-which(tmpD$quad=="q32" & (tmpD$year<35 | tmpD$year>41))
      tmp<-c(tmp1,tmp2,tmp3,tmp4,tmp5,tmp6)
      tmpD<-tmpD[-tmp,]
    }
    
    tmpD$Group <- as.factor(tmpD$Group)
    tmpD <- tmpD[,c("quad","year","NRquad","totParea","Group")]
    names(tmpD)[3] <- paste("R.",species_list[i],sep="")
    names(tmpD)[4] <- paste("cov.",species_list[i],sep="")
    if(i==1){
      D=tmpD
    }else{
      D=merge(D,tmpD,all=T)
    }
    i <- i+1
  } # end species loop
  D[is.na(D)] <- 0  # replace missing values
  
  recruit_params <- recruit_mcmc_ss(dataframe = D, sppList = species_list)
  recruit_params_site_list[[do_site]] <- recruit_params
} # end site loop

# Save the output
saveRDS(recruit_params_site_list, "recruit_ss_parameters.RDS")

