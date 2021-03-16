# wildfire-analysis
### Análisis de incendios forestales del oeste de EE. UU 
***
#### Problemática :fire:
El análisis se limitará a los estados de California, Arizona, Nuevo México, Colorado, Utah, Nevada, Utah, Oregón, Washington, Idaho, Montana, y Wyoming. 
Interés en la oleada de grandes incendios forestales, categorizados como incendios que queman más de 1,000 acres. 

Interrogantes específicas pautadas en [Actividad.pdf](Actividad.pdf).
***

#### Datos :pencil:
Los datos fueron recuperados de la base de datos federal de ocurrencia de incendios forestales, proporcionada por el Servicio Geológico de EE. UU. (USGS) para visualizar el cambio en la actividad de los incendios forestales de 1980 a 2016.

https://wildfire.cr.usgs.gov/firehistory/data.html

El dataset StudyArrea.csv, cuenta con los siguientes atributos:
* FID. Número de id.
* ORGANIZATI. Agencia que reportó el incendio.
* UNIT. Unidad que reportó el incendio.
* SUBUNIT. Subunidad que reportó el incendio.
* SUBUNIT2. Unidad identificadora de reporte (USFS District Number).
* FIRENAME. El nombre del evento de incendio forestal.
* CAUSE. Causa categorizada por el USFS.
* YEAR_. Año del incendio.
* STARTDATED. Fecha de descubrimiento del incendio forestal.
* CONTRDATED. Fecha en que se controló el incendio forestal.
* OUTDATED. Fecha en que se declaró extinguido el incendio forestal.
* STATE. Estado en el cual sucedió el incendio.
* STATE_FIPS. Código FIPS.
* TOTALACRES. Acres en el momento de control.

Además se generan nuevos. 
***
#### Herramientas :hammer:
Se utiliza como lenguaje de programación R y como IDE RStudio. 

Para la generación de modelos se utiliza Regresión lineal. 
***
#### Resultados :chart_with_upwards_trend:
Los resultados obtenidos se detallan en el archivo [Analisis.pdf](Analisis.pdf).
***
