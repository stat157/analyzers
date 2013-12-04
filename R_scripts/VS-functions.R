# temporal_etas_em_sample.R                                                 

#                                                                           

# Code to simulate and estimate a temporal ETAS model.                      

#                                                                           

# lmb(t|H_t) = mu + sum_{i:t_i<t} K*exp(alpha*(m_i-m_0))*(t-t_i+c)^(-p)     

#                                                                           

# The parameters of the model are:                                          

#      parms = (mu, K, alpha, c, p)                                         

#                                                                           

# This code assumes p>1 for the Omori Law.  In this case, the Omori Law     

# coincides with a Pareto distribution (power law) with aftershocks         

# theoretically allowed to happen between zero and infinitely many days     

# after the triggering eq.                                                  

#                                                                           



##                                                                          

## f.sim                                                                    

## 2009-04-25                                                               

##                                                                          

## Simulates a temporal ETAS model as a branching process.  The magnitude   

## distribution is a truncated Gutenberg-Richter relationship, i.e. the     

## simulated magnitudes will all fall between m.GR.min and m.GR.max.        

##                                                                          

## Input:   mu      background intensity,   >0                              

##          K       constant                >0                              

##          alpha   productivity            >0, typically log(10)           

##          om.c    modified Omori-Utsu law >0                              

##          om.p    modified Omori-Utsu law >1                              

##          bgTW    background time window on which to simulate bg-events,  

##                  e.g. bgTW=c(0,50000)                                    

##          m0      magnitude threshold.  The ETAS model ignores eqs below  

##                  m0.                                                     

##          m.GR.min                                                        

##                  smallest possible eq.  Note that we usually set m0 equal

##                  to m.GR.min, but this need not be the case.             

##          m.GR.max                                                        

##                  largest possible eq.   m.GR.min <= m0 < m.GR.max        

##          GR.b    parameter of the exponential magnitude distribution.    

##                  Should be about 1*log(10).                              

##          returnTW = NULL                                                 

##                  If NULL, all simulated events will be returned,         

##                  including simulated aftershocks outside the time window 

##                  bgTW.  If a returnTW is specified (e.g. [40000, 50000]) 

##                  then only simulated eqs in that                         

##                  window are returned.  This allows for some "burn-in"    

##                  time, because otherwise our  simulated catalogs will    

##                  have relatively few simulated aftershocks in the early  

##                  part of the  bgTW.                                      

##          quiet=F If TRUE, the function generates more informational      

##                  output.                                                 

##                                                                          

## Output:  list                                                            

##          [[1]]   data.frame with $t   simulated time of eq occurrence in 

##                                       days                               

##                                  $mg  simluated magnitude of eqs         

##          [[2]]   m0                   from input                         

##          [[3]]   dataTW               bgTW or returnTW (if specified)    

##          [[4]]   catalog.BR           branching ratio of simulated       

##                                       catalog (proportion of triggered   

##                                       eqs for *all* simulated eqs, not   

##                                       just the ones in the returnTW.)    

##                                                                          

f.sim = function(mu, K, alpha, om.c, om.p, bgTW, m0, m.GR.min, m.GR.max, GR.b, returnTW = NULL, quiet=F){


        ##                                                                              

        ## Sample the magnitude from a truncated exponential (Gutenberg-Richter)        

        ##                                                                              

        f.sample.mag<-function(how.many){

            max.unif <- 1-exp(-GR.b*(m.GR.max-m.GR.min))

            out <- m.GR.min - log(1-runif(how.many, 0, max.unif))/GR.b

        }


        ##                                                                              

        ## f.E.of.G                                                                     

        ## Computes the expected number of direct aftershocks E(G) for a randomly       

        ## selected eq (with magnitude from a truncated exponential Gutenberg-Richter). 

        ##                                                                              

        ## Input:                                                                       

        ##                                                                              

        ##          pK      constant                >0                                  

        ##          pA      productivity            >0, typically log(10)               

        ##          pC      modified Omori-Utsu law >0                                  

        ##          pP      modified Omori-Utsu law >1                                  

        ##          pB      parameter of the Gutenberg-Richter relationship             

        ##          M.low   lower cut-off magnitude                                     

        ##          M.up    upper cut-off magnitude                                     

        ##                                                                              

        ## Output:          E(G), expected number of direct aftershocks for a randomly  

        ##                  selected eq, a scalar.                                      

        ##                                                                              

        f.E.of.G <- function(pK, pA, pC, pP, pB, M.low, M.up){

            if(pA==pB){

                pB*pK*(M.up-M.low)*pC^(1-pP) / (1-exp(-pB*(M.up-M.low))) / (pP-1)

            }

            else{

                pB*pK/(pB-pA)*pC^(1-pP)/(pP-1)*(1-exp((pA-pB)*(M.up-M.low)))/(1-exp(-pB*(M.up-M.low)))

            }

        }


    E.of.G <- f.E.of.G(K,alpha,om.c, om.p, GR.b, m0, m.GR.max)

    if(!quiet) cat("The expected number of direct aaftershocks for a randomly picked eq is", E.of.G, "\n")

    if(E.of.G > 1) stop("This is an explosive parametrization!!!  ")


    n.bg <- rpois(1, mu*(bgTW[2]-bgTW[1])) # number of independent background eqs

    eq.time <- runif(n.bg, bgTW[1], bgTW[2]) # occurrence time

    eq.mag <- f.sample.mag(n.bg) # magnitude



    ## Simulate aftershocks and aftershocks of aftershocks until done.

    v.exp.n.aft <- K*exp(alpha*(eq.mag-m0))*om.c^(1-om.p)/(om.p-1) # expected number of direct aftershocks


    v.n.aft <- rpois(n.bg, v.exp.n.aft) # number of aftershocks

    n.aft <- sum(v.n.aft) # total number of aftershocks in this generation


    parent.time <- rep(eq.time, v.n.aft)

    parent.mag  <- rep(eq.mag,  v.n.aft)


    j <- 1

    continue <- T

    if(n.aft <= 0) continue <- F

         cat("Generation ",j,"... total pts so far = ",length(eq.time),".... next gen has ",n.aft, "\n") #

    while(continue){

        ## simulate magnitude of aftershock

        aft.mag <- f.sample.mag(n.aft) 


        ## simulate occurrence time of aftershock

        ## if y = runif(1), then new delta times are c(1-y)^(-1/(p-1))-c 

        delta.time <- om.c*(1-runif(n.aft))^(-1/(om.p-1))-om.c

        aft.time <- parent.time+delta.time # occurrence time of aftershocks

    

        ## Simulate number of aftershocks for next generation

        v.exp.n.aft <- K*exp(alpha*(aft.mag-m0))*om.c^(1-om.p)/(om.p-1) # expected number of aftershocks #corrected parent -> aft

        v.n.aft <- rpois(n.aft, v.exp.n.aft) # number of aftershocks

        n.aft <- sum(v.n.aft) # total number of aftershocks in this generation


        ## This will be the parent time and parent mag for the next generation

        parent.time <- rep(aft.time, v.n.aft)

        parent.mag  <- rep(aft.mag,  v.n.aft)


        eq.time <- c(eq.time, aft.time)

        eq.mag  <- c(eq.mag, aft.mag)


        j <- j+1

        if(n.aft <= 0) continue <- F

        cat("Generation ",j,"... total pts so far = ",length(eq.time),".... next gen has ",n.aft, "\n") #

    }


    if(!quiet){

        cat("In total, there are", n.bg , "bg eqs and", length(eq.time)-n.bg, "triggered eqs.\n")

        if(!is.null(returnTW)) cat(   "A returnTW has been specified, so the simulated dataset only contains a total of"

                                    , sum(eq.time >= returnTW[1] & eq.time <= returnTW[2]), "events.\n")

    }

    tot.anz <- length(eq.time)

    catalog.BR <- (tot.anz-n.bg)/tot.anz


    ord <- order(eq.time)

    dat <- data.frame( t = eq.time[ord], mg = eq.mag[ord] )

    out <- list(dat=dat, m0=m0, dataTW=bgTW, catalog.BR=catalog.BR)

    if(is.null(returnTW)){

        return(out)

    }else{

        idx <- out$dat$t >= returnTW[1] & out$dat$t <= returnTW[2]

        out$dat <- out$dat[idx,]

        out$dataTW <- returnTW

        return(out)

    }


}




##                                                                          

## f.est                                                                    

## 2009-04-27                                                               

##                                                                          

## Estimates a temporal ETAS model.                                         

##                                                                          

## Input:   datfr   data.frame with $t   simulated time of eq occurrence in 

##                                       days                               

##                                  $mg  simluated magnitude of eqs         

##          M0          cut-off magnitude                                   

##          estTW       time window of the data set used for estimation     

##          start.mu    starting values for parameter estimation            

##          start.K                                                         

##          start.alpha                                                     

##          start.c                                                         

##          start.p                                                         

##          sig.digits=4                    stopping criterion              

##          extra.sig.digs=2                stopping criterion              

##          p.range=c(1.000000000001, 10)   search range for p              

##          a.range=c(0.1, 10)              search range for alpha          

##          narrowing.steps=4               iterations of outer loop        

##          quiet=T                         if FALSE, there will be verbose 

##                                          output                          

##                                                                          

## Note: The three first inputs can be obtained from the first three        

##       elements of 'out', the output of f.sim(...)                        

##                                                                          

## Output:  mu.hat                                                          

##          K.hat                                                           

##          alpha.hat                                                       

##          c.hat                                                           

##          p.hat                                                           

##                                                                          

f.est <- function(    datfr, M0, estTW

                    , start.mu, start.K, start.alpha, start.c, start.p

                    , sig.digits=4, extra.sig.digs=2 

                    , p.range=c( 1.000000000000001, 15), a.range=c(-10, 20) 

                    , narrowing.steps=4, quiet=T){

    f.find.p <- function(find.p, alpha1, beta1){

        log((find.p-1)/find.p) + 1/(find.p-1) - log(alpha1) - beta1

    }

    f.find.a <- function(find.a, zeta1, eta1){

        sum( (eta1*(Mag-M0)-zeta1) * (curr.c)^(1-curr.p) / (curr.p-1) * exp(find.a*(Mag-M0))  )

    }


    if( length(which(datfr$mg<M0)) > 0 ) stop("There are eqs with magnitude below estM0.")


    ord         <- order(datfr$t) 

    Time        <- datfr$t[ord]

    Mag         <- datfr$mg[ord]

    

    if( sum( Time != datfr$t ) > 0 ) stop("The eq times have to be ordered.  Order the data.frame before passing it to f.est!")

    

    curr.mu     <- start.mu

    curr.K      <- start.K

    curr.alpha  <- start.alpha

    curr.c      <- start.c

    curr.p      <- start.p

    

    Anz         <- length(Time)



#                                                               

#          Start of weiter0 loop                                

#                                                               

    weiter0 <- T

    weiter0.zaehler <- 0

    while(weiter0){

        if(!quiet){

            cat("\n weiter0.zaehler =", weiter0.zaehler, "  narrowing.steps =", narrowing.steps, ".\n")

            cat("Current p.range goes from", p.range[1], "to", p.range[2], "\n")

            cat("Current a.range goes from", a.range[1], "to", a.range[2], "\n")

        }


        weiter      <- T

            weiter.zaehler <-1

            while(weiter){

            last.mu         <- curr.mu

            last.K          <- curr.K

            last.alpha      <- curr.alpha

            last.c          <- curr.c

            last.p          <- curr.p 

        

                # Find probability vector

                mag.part        <- curr.K*exp(curr.alpha*(Mag-M0))

                miss.prob.list  <- list()

                miss.L.hat      <- 0

                miss.l.i        <- rep(0,Anz)

                numb.bg.eqs     <- 0

                for(i in 2:Anz){

                    time.part   <- ((Time[i]-Time[1:(i-1)])+curr.c)^(-curr.p)

                    v.g         <- time.part * mag.part[1:(i-1)]

                    Nenner      <- curr.mu + sum(v.g) 

                    v.prob.i            <- v.g/Nenner

                    sum.v.prob.i        <- sum(v.prob.i)

                    miss.L.hat          <- miss.L.hat + sum.v.prob.i 

                    miss.l.i[1:(i-1)]   <- miss.l.i[1:(i-1)] + v.prob.i

                    miss.prob.list[[i]] <- v.prob.i

                    numb.bg.eqs         <- numb.bg.eqs + (1-sum.v.prob.i)

                }

                curr.mu <- numb.bg.eqs/(estTW[2]-estTW[1])


            # Find estimates for K and alpha  

                Zeta1   <- 1/miss.L.hat

                Eta1    <- 1/sum((Mag-M0)*miss.l.i)

                curr.alpha  <- uniroot(f.find.a, a.range, zeta1=Zeta1, eta1=Eta1)[[1]]

                curr.K      <- miss.L.hat / ( curr.c^(1-curr.p) / (curr.p-1) * sum(exp(curr.alpha*(Mag-M0))) )

            

            # Find estimates for c and p    

                Alpha1 <- 0

                Beta1  <- 0

                for(i in 2:Anz){

                    Alpha1 <- Alpha1 + sum( miss.prob.list[[i]] /    (Time[i] - Time[1:(i-1)] + curr.c) ) 

                    Beta1  <- Beta1  + sum( miss.prob.list[[i]] * log(Time[i] - Time[1:(i-1)] + curr.c) ) 

                }

                Alpha1 <- Alpha1 / miss.L.hat

                Beta1  <- Beta1  / miss.L.hat

        

                weiter2     <- T

                weiter.zaehler2 <- 1

                while(weiter2){

                    last.c2 <- curr.c

                    last.p2 <- curr.p

                    curr.p  <- uniroot(f.find.p, p.range, alpha1=Alpha1, beta1=Beta1)[[1]]

                    curr.c  <- (curr.p-1)/(curr.p*Alpha1)

                    weiter.zaehler2 <- weiter.zaehler2 + 1

                    weiter2 <- ! (( signif(last.p2-1, sig.digits+extra.sig.digs)==signif(curr.p-1, sig.digits+extra.sig.digs) ) & ( signif(last.c2, sig.digits+extra.sig.digs)==signif(curr.c, sig.digits+extra.sig.digs) )  )

                    if(weiter.zaehler2>200) { weiter2 <- F ; cat("Label 1 (check code) \n") }

                }

                

            if(!quiet){

                cat( substr(date(),12,19), "Step", weiter.zaehler, "   mu:", curr.mu, "K:", curr.K, "alpha:", curr.alpha, "c:", curr.c, "p:", curr.p, "\n" )

                flush.console()

            }

            weiter.zaehler  <- weiter.zaehler + 1

            weiter          <- !(       ( signif(last.mu,       sig.digits)  == signif(curr.mu,     sig.digits) )  & 

                                        ( signif(last.c,        sig.digits)  == signif(curr.c,      sig.digits) )  & 

                                        ( signif(last.p-1,      sig.digits)  == signif(curr.p-1,    sig.digits) )  & 

                                        ( signif(last.K,        sig.digits)  == signif(curr.K,      sig.digits) )  & 

                                        ( signif(last.alpha,    sig.digits)  == signif(curr.alpha,  sig.digits) )      )

            }

            

    ################################################################################################

    if(weiter0.zaehler < narrowing.steps){

        weiter0.zaehler<-weiter0.zaehler+1

        p.range <- c( max(1.000000000001, curr.p    -((p.range[2]-p.range[1])/4)) , curr.p    +((p.range[2]-p.range[1])/4) )

        a.range <- c( max(0.01,           curr.alpha-((a.range[2]-a.range[1])/4)) , curr.alpha+((a.range[2]-a.range[1])/4) )        

    }else{ weiter0 <- F }

    ################################################################################################


    }

    

    #                                                               

    #          End of weiter0 loop                                  

    #                                                               

    

    out <- list(mu.hat=curr.mu, K.hat=curr.K, alpha.hat=curr.alpha, c.hat=curr.c, p.hat=curr.p)

    return(out)

}





