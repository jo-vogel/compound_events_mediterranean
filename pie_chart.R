# Pie chart for change vector analysis

library(RColorBrewer)
library(BBmisc)

colors2 <- c(rainbow(8),rainbow(1)) # same color at start and end
colors <- rainbow(30)
colors2[4] <-colors[10] # make coloring nicer
colors2[3] <-colors[6] # make coloring nicer
# colors2 <- colors2[c(2:8,1,2)] # shift colors
colors2 <- colors2[c(4:8,1:3,4)]


yellow <- brewer.pal(8,"Accent")[4]
orange <- brewer.pal(8,"Accent")[3]
blue <- brewer.pal(8,"Accent")[5]
rose <- brewer.pal(8,"Accent")[6]
green <- brewer.pal(8,"Accent")[1]
cyan <- "cadetblue2"
cols <- inlmisc::GetColors(n = 10,scheme = "smooth rainbow")
red <- cols[9]
purple <- cols[3]

colors2[8] <- yellow
colors2[7] <- orange
colors2[5] <- rose
colors2[3] <- blue
colors2[1] <- green;colors2[9] <- green
colors2[2] <- cyan
colors2[6] <- red
colors2[4] <- purple


slices <- rep(45,8)
a <- seq(0,1,length.out=1000)
# a2 <- normalize(a,method="range",range=c(0.27,0.35))
# b <- cos(a)
# b2 <- normalize(b,method="range",range=c(0.20,0.27))
b <- cos(asin(a))
a2 <- normalize(a,method="range",range=c(0.19,0.27))
b2 <- normalize(b,method="range",range=c(0.27,0.34))

# labels <- c("red","orange","yellow","green","cyan","dark blue","purple","rose")
# labels <- c("","orange","yellow","green","","dark blue","purple","rose")
# png(file="D:/user/vogelj/compound_events_mediterran/Output/Plots/pie_chart_change_vector_analysis_v2.png",height=10,width=10,unit="cm", pointsize = 6, bg = "white", res = 1000, restoreConsole = TRUE, type = "windows")
pdf(file="D:/user/vogelj/compound_events_mediterran/Output/Plots/pie_chart_change_vector_analysis_v2.pdf", height=10/2.54, width=10/2.54, pointsize = 6)

par(mar=c(0,0,0,2))
pie(slices,labels="",col=colors2[1:8], clockwise=T, init.angle = 90 + 22.5)
## text(x=0,y=0.9,labels="red")
## text(x=0,y=- 0.9,labels="cyan")
# text("Warm spells",x=0.5,y=-0.075, font=2, cex=2)
# text("Droughts",x=-0.075,y=0.5,srt=90, font=2, cex=2)
text("Number of \n warm spells",x=0.5,y=-0.18, font=2, cex=2.2)
text("Number of \n droughts",x=-0.18,y=0.5,srt=90, font=2, cex=2.2)
arrows(x0=0,y0=0,x1=0,y1=1,lwd=2)
arrows(x0=0,y0=0,x1=1,y1=0, lwd=2)
# arrows(x0=0.2,y0=0.2,x1=0.8,y1=0.5,lwd=4)
arrows(x0=0.2,y0=0.2,x1=0.8,y1=0.8,lwd=4)
text(x=0.8,y=0.9,"1999 - 2018", font=2,cex=2,col="tomato4")
text(x=0.32,y=0.12,"1979 - 1998", font=2,cex=2,col="tomato4")
# text("Magnitude", x=0.865, y=0.5, font=2, cex=1.8,col="DarkGoldenrod4")
# text("Angle", x=0.5, y=0.28, font=2, cex=1.8,col="DarkGoldenrod4")
text("Angle", x=0.23, y=0.4, font=2, cex=2,col="DarkGoldenrod4")
text("Magnitude", x=0.55, y=0.4, font=2, cex=2,col="DarkGoldenrod4",srt=45)
lines(a2,b2,lwd=3.5)
# points(0.28,0.225,pch=19) # remove
points(0.2,0.2, col='tomato4',pch=4,cex=3,lwd=4)
points(0.8,0.8, col='tomato4',pch=4,cex=3,lwd=4)
# points(0.2,0.2, col='tomato4',pch=4,cex=8,lwd=3)
# points(0.8,0.8, col='tomato4',pch=21,cex=3,bg="tomato4")

dev.off()
# plot(1,xlab="",ylab="",type="n",bty='L',xaxt='n',yaxt='n')
# mtext("Warm spells", side=1, line=1)
# mtext("Droughts", side=2, line=1)


# Vector graphic
png(file="D:/user/vogelj/compound_events_mediterran/Output/Plots/change_vector_analysis_examplary_vector.png",height=10,width=10,unit="cm", pointsize = 6, bg = "white", res = 1000, restoreConsole = TRUE, type = "windows")
par(mar=c(3, 3, 1, 2) + 0.1)
plot(c(0,1.1),c(0,1),type='n',ylab="",xlab="",xaxt='n',yaxt='n',bty='L')
mtext("Droughts",side=2,line=1.3,font=2,cex=2)
mtext("Warm spells",side=1,line=1.3,font=2,cex=2)
arrows(x0=0.2,y0=0.2,x1=0.8,y1=0.5,lwd=4)
text(x=0.58,y=0.22,"Direction", font=2,cex=2)
text(x=0.95,y=0.42,"Magnitude", font=2,cex=2)
text(x=0.2,y=0.15,"1979 - 1998", font=2,cex=2,col="cadetblue4")
text(x=0.8,y=0.55,"1999 - 2018", font=2,cex=2,col="cadetblue4")
dev.off()