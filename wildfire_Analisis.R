#----------------------Alondra Sánchez Molina 
#----Mineria de datos - Proyecto final 

#Analysis of Wildfire Activity in the Western United States 

#--------------Cargando librerias 
library(ggplot2)
library(lubridate)
library(dplyr)

wildfire = read.csv("RFiles/StudyArea.csv",header=TRUE,sep=",",na.strings = '')


#--------------Exploración inicial
str(wildfire)
dim(wildfire)
colnames(wildfire)
head(wildfire)
summary(wildfire)

View(wildfire)
#--------------

#--------------Preprocesamiento y preparación de los datos
wildfire <- wildfire[, -c(1,3:6,10,13)] 
wildfire <- filter(wildfire, TOTALACRES >= 1000)

sum(is.na(wildfire))   
wildfire <- wildfire[complete.cases(wildfire),]
sum(is.na(wildfire))   

wildfire$STARTDATED <- as.Date(wildfire$STARTDATED, "%m/%d/%y %H:%M")
wildfire$OUTDATED <- as.Date(wildfire$OUTDATED, "%m/%d/%y %H:%M")

wildfire <- mutate(wildfire, 
              DECADE = ifelse(YEAR_ %in% 1980:1989, "1980-1989", 
                       ifelse(YEAR_ %in% 1990:1999, "1990-1999", 
                       ifelse(YEAR_ %in% 2000:2009, "2000-2009", 
                       ifelse(YEAR_ %in% 2010:2016, "2010-2016", "-99")))))

totdias <- wildfire$OUTDATED - wildfire$STARTDATED
totdias
totdias <- as.numeric(totdias)
wildfire <- cbind(wildfire,DAYS_ON_FIRE=c(totdias))

View(wildfire)
#--------------

#--------------�Ha aumentado o disminuido el n�mero de incendios forestales en las �ltimas d�cadas?  
wildfire %>%
  select(STATE, year = YEAR_, ACRES = TOTALACRES, CAUSE) %>%
  group_by(year) %>%
  summarize(count=n()) %>%
  ggplot(mapping = aes(x=year, y=count)) + geom_point() + geom_smooth(method=lm, se=TRUE) + ggtitle("Incremento de incendios forestales - 1980-2016") + xlab("A�o") + ylab("N�mero de incendios forestales")

#Por estados
wildfire %>%
  select(STATE, year = YEAR_, ACRES = TOTALACRES, CAUSE) %>%
  group_by(STATE, year) %>%
  summarize(cnt = n()) %>%
  ggplot(mapping = aes(x=year, y=cnt)) + geom_point() + facet_wrap(~STATE) + geom_smooth(method=lm, se=TRUE) + ggtitle("Cantidad de incendios por estado y a�o") + xlab("A�o") + ylab("Cantidad de incendios")
#--------------

#--------------�Ha aumentado la superficie quemada con el tiempo?   1er Pred
wildfire %>%
  select(STATE, year = YEAR_, ACRES = TOTALACRES, CAUSE) %>%
  group_by(year) %>%
  summarize(totalacres = sum(ACRES)) %>%
  ggplot(mapping = aes(x=year, y=log(totalacres))) + geom_point() + geom_smooth(method=lm, se=TRUE) + ggtitle("Total de acres quemados") + xlab("A�o") + ylab("Log de Total de acres quemadas")

grp <- group_by(wildfire, STATE, YEAR_)
sm <- summarize(grp, totalacres = sum(TOTALACRES))
ggplot(data=sm, aes(x=YEAR_, y=totalacres, colour=STATE)) + geom_point(aes(colour = STATE)) + stat_smooth(method=lm, se=FALSE) + ggtitle("Tendencia de crecimiento por estado") + xlab("A�o") + ylab("Total de acres quemados")

#Crecimiento de incendios a lo largo de los a�os por tipo
sum(wildfire$CAUSE == "Human")
sum(wildfire$CAUSE == "Natural")
(2325/7020)*100

wildfire %>%
  select(STATE, year = YEAR_, ACRES = TOTALACRES, CAUSE) %>%
  filter(CAUSE %in% c('Human', 'Natural')) %>%
  group_by(CAUSE, year) %>%
  summarize(totalacres = sum(ACRES)) %>%
  ggplot(mapping = aes(x=year, y=log(totalacres), colour=CAUSE)) + geom_point() + geom_smooth(method=lm, se=FALSE) + ggtitle("Total de acres quemados") + xlab("A�o") + ylab("Log del total de acres quemados")
#--------------

#--------------�Est� aumentando el tama�o de los incendios forestales individuales con el tiempo?
#Graficar por decadas el total de acres quemados
grp <- group_by(wildfire, DECADE)
sm <- summarize(grp, mean(TOTALACRES))
names(sm) <- c("Decada", "Promedio de acres quemadas")
ggplot(data=sm) + geom_col(mapping = aes(x=sm$Decada, y=sm$`Promedio de acres quemadas`), fill="#FB8F67") + ggtitle("Aumento de acres quemados por decada")
#--------------

#--------------�Ha aumentado la duraci�n de la temporada de incendios con el tiempo?    2da Pred
wildfire %>%
  select(ORGANIZATI, STATE, year = YEAR_, ACRES = TOTALACRES, CAUSE, STARTDATED) %>%
  mutate(DOY = yday(STARTDATED)) %>%
  group_by(year) %>%
  summarize(dtEarly = min(DOY, na.rm=TRUE), dtLate = max(DOY, na.rm=TRUE)) %>%
  ggplot()  + geom_line(mapping = aes(x=year, y=dtEarly, color='B'))  + geom_line(mapping = aes(x=year, y=dtLate, color='R')) + 
              geom_smooth(method=lm, se=TRUE, aes(x=year, y=dtEarly, color="B")) + geom_smooth(method=lm, se=TRUE, aes(x=year, y=dtLate, color="R")) + xlab("A�o") + ylab("Dia del a�o") + 
              scale_colour_manual(name = "Simbolog�a", values = c("R" = "#456990", "B" = "#EF767A"), labels = c("Primer incendio", "Ultimo incendio")) + ggtitle("Temporada de incendios forestales")

#--------Dias de duraci�n de los incendios
grp <- group_by(wildfire, DECADE)
sm <- summarize(grp, mean(DAYS_ON_FIRE))
View(sm)
names(sm) <- c("Decada", "No. promedio de d�as")
ggplot(data=sm) + geom_col(mapping = aes(x=sm$Decada, y=sm$`No. promedio de d�as`), fill="#FB8F67") + ggtitle("D�as de duraci�n por decada")
#--------------

#--------------�La superficie quemada difiere seg�n la organizaci�n federal?
wildfire %>%
  select(ORG = ORGANIZATI, STATE, year = YEAR_, ACRES = TOTALACRES, CAUSE, STARTDATED) %>%
  filter(ORG %in% c('BIA', 'BLM', 'FS', 'FWS', 'NPS')) %>%
  group_by(ORG, year) %>%
  summarize(meanacres = mean(ACRES)) %>%
  ggplot(mapping = aes(x=year, y=log(meanacres))) + geom_point() + facet_wrap(~ORG) + geom_smooth(method=lm, se=TRUE) + ggtitle("Superficie quemada por organizaci�n federal") + xlab("A�o") + ylab("Log del total de acres quemados")
#--------------

#--------------Predicciones
View(wildfire)

wildfirePred <- wildfire[, -c(3:5)] 
 
wildfirePred$ORGANIZATI <- as.factor(wildfirePred$ORGANIZATI)
wildfirePred <- filter(wildfirePred, CAUSE == "Human" | CAUSE == "Natural" | CAUSE == "Undetermined")
wildfirePred$CAUSE <- as.factor(wildfirePred$CAUSE)
wildfirePred$STATE <- as.factor(wildfirePred$STATE)
wildfirePred$DECADE <- as.factor(wildfirePred$DECADE)

View(wildfirePred)

#---Superficie quemada (tama�o de los incendios) ACRES
wildfire_pred_lm <- lm(TOTALACRES ~ ORGANIZATI + CAUSE + STATE + DECADE + DAYS_ON_FIRE, data = wildfirePred)
summary(wildfire_pred_lm)

acres_pred <- predict(wildfire_pred_lm, 
                      data.frame(ORGANIZATI = "NPS", CAUSE = "Human",  STATE = "California", DECADE = "2010-2016", DAYS_ON_FIRE = 10))
acres_pred


#---Dias de duraci�n de los incendios DAYS_ON_FIRE
wildfire_predDays_lm <- lm(DAYS_ON_FIRE ~ ORGANIZATI + CAUSE + STATE + TOTALACRES + DECADE , data = wildfirePred)
summary(wildfire_predDays_lm)

days_pred <- predict(wildfire_predDays_lm, 
                      data.frame(ORGANIZATI = "FS", CAUSE = "Human",  STATE = "Arizona",TOTALACRES = 1000, DECADE = "2010-2016"))
days_pred
