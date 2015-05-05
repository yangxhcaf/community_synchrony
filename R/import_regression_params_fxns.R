#' Import and format growth parameters for IPM
#' 
#' @author Andrew Tredennick
#' @param do_site Focal site (character scalar).
#' @param species_list Character vector of four letter species' codes.
#' @param Nyrs Number of random effects years.
#' @param Gdata Growth parameters matrix from regression output.

format_growth_params <- function(do_site, species_list, Nyrs, Gdata){
  Nspp <- length(species_list)
  Gpars <- list(intcpt=rep(NA,Nspp),intcpt.yr=matrix(0,Nyrs,Nspp), 
                intcpt.gr=matrix(0,6,Nspp),
                slope=rep(NA,Nspp),slope.yr=matrix(0,Nyrs,Nspp),
                nb=matrix(0,Nspp,Nspp),alpha=matrix(NA,Nspp,Nspp),
                sigma2.a=rep(NA,Nspp),sigma2.b=rep(NA,Nspp))
  
  for(i in 1:Nspp){
    Gpars$intcpt[i]=Gdata$Intercept[1]
    tmp=which(names(Gdata)=="Group")
    if(length(tmp)>0) Gpars$intcpt.gr[,i]=Gdata$Group[!is.na(Gdata$Group)] 
    Gpars$intcpt.yr[,i]=Gdata$Intercept.yr
    Gpars$slope[i]=Gdata$logarea.t0[1]
    # random effects on slope
    tmp=which(names(Gdata)=="logarea.t0.yr")
    if(length(tmp)>0) Gpars$slope.yr[,i]=Gdata[,tmp]
    # get competition coefficients
    tmp=paste("crowd",1:length(sppList),sep="")
    tmp=which(is.element(names(Gdata),tmp))
    if(length(tmp)>0) Gpars$nb[i,]=as.numeric(Gdata[1,tmp])
    
    Gpars$alpha[i,]=Gdata$alpha[1:length(sppList)]
    Gpars$sigma2.a[i]=Gdata$sigma.a[1]
    Gpars$sigma2.b[i]=Gdata$sigma.b[1]
  } # next i
  return(Gpars)
} # end function




#' Import and format survival parameters for IPM
#' 
#' @author Andrew Tredennick
#' @param do_site Focal site (character scalar).
#' @param species_list Character vector of four letter species' codes.
#' @param Nyrs Number of random effects years.
#' @param Sdata Survival parameters matrix from regression output.

format_survival_params <- function(do_site, species_list, Nyrs, Sdata){
  Nspp <- length(species_list)
  Spars <- list(intcpt=rep(NA,Nspp),intcpt.yr=matrix(0,Nyrs,Nspp),
                slope=rep(NA,Nspp),slope.yr=matrix(0,Nyrs,Nspp),
                nb=matrix(0,Nspp,Nspp),intcpt.gr=matrix(0,6,Nspp),
                alpha=matrix(NA,Nspp,Nspp))
  
  for(i in 1:Nspp){
    Spars$intcpt[i] <- Sdata$Intercept[1]
    
    tmp <- which(names(Sdata)=="Group")
    if(length(tmp)>0) 
      Spars$intcpt.gr[,i] <- Sdata$Group[!is.na(Sdata$Group)] # get spatial average
    
    tmp <- which(names(Sdata)=="Intercept.yr")
    if(length(tmp)>0) 
      Spars$intcpt.yr[,i] <- Sdata$Intercept.yr
    
    Spars$slope[i] <- Sdata$logarea[1]
    
    # random effects on slope
    tmp <- which(names(Sdata)=="logarea.yr")
    if(length(tmp)>0)
      Spars$slope.yr[,i] <- Sdata[,tmp]
    
    # get competition coefficients
    tmp <- paste("crowd",1:length(sppList),sep="")
    tmp <- which(is.element(names(Sdata),tmp))
    if(length(tmp)>0)
      Spars$nb[i,] <- as.numeric(Sdata[1,tmp])
    
    Spars$alpha[i,]=Sdata$alpha[1:length(sppList)]
  } # next i
  return(Spars)
} # end of function

