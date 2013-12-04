
# Load test catalog

socal.dat = read.table("/Users/bonghyunkim/Downloads/socal.txt",header=T)

times = socal.dat$t
mags = socal.dat$mg

# use muhaz if you want to plot hazard

#start = ISOdate(1984,1,1,0,0,0,tz="PST")
#test.start = ISOdate(2004,6,18,0,0,0,tz="PST")
#finish = ISOdate(2010,1,1,0,0,0,tz="PST")
start = ISOdate(1984,1,1,0,0,0)
test.start = ISOdate(2004,6,18,0,0,0)
finish = ISOdate(2010,1,1,0,0,0)

training.period = as.numeric(test.start - start)
test.period = as.numeric(finish - test.start)
period = as.numeric(finish - start)

source("VS-functions.R")

# Here is a CI function
etas.CI <- function(time,t.events,mag.events,m0,mu,K,alpha,c,p){
   mu+sum(K*10^(alpha*(mag.events-m0))/(time-t.events+c)^p)
}

# Placeholders

#timelist = seq(training.period,period,0.1)
timelist=2:training.period

n.training = sum(times<training.period)
n.test = sum(times<period) - n.training

CI.dist=rep(NA,length(timelist))
CI.list=rep(NA,n.training)

CI2.dist=rep(NA,length(timelist))
CI2.list=rep(NA,n.training)

CI3.dist=rep(NA,length(timelist))
CI3.list=rep(NA,n.training)

w2.dist=rep(NA,length(timelist))
w2.list=rep(NA,n.training)

w115.dist=rep(NA,length(timelist))
w115.list=rep(NA,n.training)

w58.dist=rep(NA,length(timelist))
w58.list=rep(NA,n.training)

n.events = sapply(timelist,function(x){sum(times<x)})

# Parameter estimates

mu.hat = .329505837595229
K.hat = .0224702963795154
alpha.hat = 1.5839343640414
c.hat = .037651249192514
p.hat = 1.38508560377488


for(KK in 1:length(timelist)){
   CI.dist[KK]=etas.CI(timelist[KK],times[1:n.events[KK]],
   mags[1:n.events[KK]],m0=3,mu=.1687,K=.04225,alpha=1.034/log(10),c=.01922,p=1.222)}

for(KK in 1:length(timelist)){
   CI2.dist[KK]=etas.CI(timelist[KK],times[1:n.events[KK]],
   mags[1:n.events[KK]],m0=3,mu=mu.hat,K=K.hat,alpha=alpha.hat/log(10),c=c.hat,p=p.hat)}

for(KK in 1:length(timelist)){
   CI3.dist[KK]=etas.CI(timelist[KK],times[1:n.events[KK]],
   mags[1:n.events[KK]],m0=3,mu=0.032,K=0.00345,alpha=1,c=.01,p=1.5)}

w.dist = timelist-times[n.events]

for(KK in 1:length(timelist)){
w2.dist[KK]=min((timelist[KK]-times[1:n.events[KK]])/(2^mags[1:n.events[KK]]))}

for(KK in 1:length(timelist)){
w58.dist[KK]=min((timelist[KK]-times[1:n.events[KK]])/(5.8^mags[1:n.events[KK]]))}

for(KK in 1:length(timelist)){
w115.dist[KK]=(timelist[KK]-times[n.events[KK]])/(1.15^mags[n.events[KK]])}

# Find values at event times

for(KK in 1:length(CI.list)){
   CI.list[KK]=etas.CI(times[1+KK],times[1:(KK)],mags[1:(KK)],
   m0=3,mu=.1687,K=.04225,alpha=1.034/log(10),c=.01922,p=1.222)}

for(KK in 1:length(CI2.list)){
   CI2.list[KK]=etas.CI(times[1+KK],times[1:(KK)],mags[1:(KK)],
   m0=3,mu=mu.hat,K=K.hat,alpha=alpha.hat/log(10),c=c.hat,p=p.hat)}

for(KK in 1:length(CI3.list)){
   CI3.list[KK]=etas.CI(times[1+KK],times[1:(KK)],mags[1:(KK)],
   m0=3,mu=0.032,K=0.00345,alpha=1,c=.01,p=1.5)}

w.list=diff(times[1:n.training])

for(KK in 1:length(w2.list)){
w2.list[KK]=min((times[1+KK]-times[1:(KK)])/(2^mags[1:(KK)]))}

for(KK in 1:length(w58.list)){
w58.list[KK]=min((times[1+KK]-times[1:(KK)])/(5.8^mags[1:(KK)]))}

for(KK in 1:length(w115.list)){
w115.list[KK]=(times[1+KK]-times[(KK)])/(1.15^mags[(KK)])}

# Error diagrams

nu.CI=sapply(CI.dist,function(x){mean(CI.list<x)})
nu.CI=sort(nu.CI,decreasing=T)

nu.CI2=sapply(CI2.dist,function(x){mean(CI2.list<x)})
nu.CI2=sort(nu.CI2,decreasing=T)

nu.CI3=sapply(CI3.dist,function(x){mean(CI3.list<x)})
nu.CI3=sort(nu.CI3,decreasing=T)

nu.w2=sapply(w2.dist,function(x){mean(w2.list>x)})
nu.w2=sort(nu.w2,decreasing=T)

nu.w58=sapply(w58.dist,function(x){mean(w58.list>x)})
nu.w58=sort(nu.w58,decreasing=T)

nu.w115=sapply(w115.dist,function(x){mean(w115.list>x)})
nu.w115=sort(nu.w115,decreasing=T)

nu.auto=sapply(w.dist,function(x){mean(w.list>x)})
nu.auto=sort(nu.auto,decreasing=T)

xx=seq(3,7473,10)
yy=length(xx)

plot(seq(0,1,length.out=yy),nu.CI2[xx],type="l",xlab=expression(tau),ylab=expression(nu),main="Training set error diagrams",ylim=c(0,1),col="green",lty=2)
lines(seq(0,1,length.out=yy),nu.CI[xx],col="blue",lty=3)
lines(seq(0,1,length.out=yy),nu.auto[xx],col="red",lty=4)
lines(seq(0,1,length.out=yy),nu.w58[xx],col="black",lty=1)
legend(.45,1,c("Temporal ETAS","Space-time ETAS","Automatic alarms","Mag-dependent automatic"),lty=c(2,3,4,1),col=c("green","blue","red","black"))

#Function to generate error diagram
#data = Earth Quake Data
#params = parameter for the ETAS Function
plotErrorDiagram = function(data, params) {
  CI_Dist = #Generate Estimated Confidence Interval Distance for timeperiod of interest using the ETAS function and appropriate Parameters
  CI_List = #Generate Confidence Interval Distance for each of the earthquake data points using the ETAS function and appropriate Parameters
  #Generate error point given specific confidence interval
  errorPoint = sapply(CI_Dist, function(ci) {mean(CI_List > ci)}
  timePeriod = #Sequence of Time Period
  #Generates the plot for the error diagram
  plot(seq(0,1,length(timePeriod)), errorPoint[timePeriod],type = "l", xlab=expression(tau), ylab=expression(nu),main = "Training set Error Diagram", col="red")
}

etasMode = function(params) {
  #Simply implement the ETAS Model.
}
