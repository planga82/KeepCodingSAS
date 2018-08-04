ods listing close; 

ods listing gpath="/courses/d28dc0adba27fe300/data_output";

/*
Fuente: Los datos provienen de un trabajo de un maestro inedito de Carl Hoffstedt. Los datos incluyen 39 secciones del estado de Minnesota y 
la unidad de la tasa es por millon de millas de un vehiculo (una milla es 1,61 km). 
Objetivo: El objetivo de analisis es entender el impacto de las variables que estan bajo el control del dpto. de carreteras, sobre la tasa 
de accidentes automovilisticos en autopista.
*/

data highway; 
  input ADT Trks  Lane  Acpt Sigs   ITG  Slim Len   Lwid Shld  Hwy Rate;
  label ADT = 'numero promedio de traico diario en miles'	
  		Trks  = 'volumen camion como un porcentaje del volumen total' 	
  		Lane = 'numero total de carriles de trafico' 
		Acpt = 'numero de puntos de acceso por kilometro'  
		Sigs  = 'numero de intercambios senalizados por km'  
		ITG  = 'numero de intercambios de tipo autovia'
		Slim = 'limite de velocidad' Len  = 'longitud del segmento de la carretera'  
		Lwid= 'ancho del carril' 	
		Shld = 'ancho exterior de la calzada' 
	   	Hwy= 'indicador del tipo de carretera' 
	   	Rate  = 'tasa de accidentes en autopista'; 

cards;
69 8 8 4.6 0 1.2 55 4.99 12 10 1 4.58
73 8 4 4.4 0 1.43 60 16.11 12 10 1 2.86
49 10 4 4.7 0 1.54 60 9.75 12 10 1 3.02
61 13 6 3.8 0 0.94 65 10.65 12 10 1 2.29
28 12 4 2.2 0 0.65 70 20.01 12 10 1 1.61
30 6 4 24.8 1.84 0.34 55 5.97 12 10 2 6.87
46 8 4 11 0.7 0.47 55 8.57 12 8 2 3.85
25 9 4 18.5 0.38 0.38 55 5.24 12 10 2 6.12
43 12 4 7.5 1.39 0.95 50 15.79 12 4 2 3.29
23 7 4 8.2 1.21 0.12 50 8.26 12 5 2 5.88
23 6 4 5.4 1.85 0.29 60 7.03 12 10 2 4.2
20 9 4 11.2 1.21 0.15 50 13.28 12 2 2 4.61
18 14 2 15.2 0.56 0 50 5.4 12 8 2 4.8
21 8 4 5.4 0 0.34 60 2.96 12 10 2 3.85
27 7 4 7.9 0.6 0.26 55 11.75 12 10 2 2.69
22 9 4 3.2 0 0.68 60 8.86 12 10 2 1.99
19 9 4 11 0.1 0.2 60 9.78 12 10 2 2.01
9 11 2 8.9 0.18 0.18 50 5.49 12 6 2 4.22
12 8 2 12.4 0 0.14 55 8.63 13 6 2 2.76
12 7 4 7.8 0.99 0.05 60 20.31 12 10 2 2.55
15 13 4 9.6 0.12 0.05 55 40.09 12 8 2 1.89
8 8 2 4.3 0 0 60 11.81 12 10 2 2.34
5 9 2 11.1 0.09 0 50 11.39 12 8 2 2.83
5 15 2 6.8 0 0 60 22 12 7 2 1.81
23 6 4 53 2.51 0.56 40 3.58 12 2 3 9.23
13 6 2 17.3 0.93 0.31 45 3.23 12 2 3 8.6
7 8 2 27.3 0.52 0.13 55 7.73 12 8 3 8.21
10 10 2 18 0.07 0 55 14.41 12 6 3 2.93
12 7 2 30.2 0.09 0.09 45 11.54 12 3 3 7.48
9 8 2 10.3 0 0 60 11.1 12 7 3 2.57
4 8 2 18.2 0.14 0 45 22.09 11 3 3 5.77
5 10 2 12.3 0 0 55 9.39 13 1 3 2.9
4 13 2 7.1 0 0 55 19.49 12 4 3 2.97
5 12 2 14 0.1 0 55 21.01 10 8 3 1.84
2 10 2 11.3 0.04 0.04 55 27.16 12 3 3 3.78
3 8 2 16.3 0 0.07 50 14.03 12 4 3 2.76
1 11 2 9.6 0 0 55 20.63 11 4 3 4.27
3 11 2 9 0 0 60 20.06 12 8 0 3.05
1 10 2 10.4 0 0 55 12.91 12 3 0 4.12
; 
run;

/*Analisis frecuencias, missings y outliers*/
proc freq data=HIGHWAY;  run;


/*Analisis Normalidad*/
proc univariate data=highway normal plot;
 var Rate;
 qqplot Rate / NORMAL (MU=EST SIGMA=EST COLOR=RED L=1);
 HISTOGRAM /NORMAL(COLOR=MAROON W=4) CFILL = BLUE CFRAME = LIGR;
 INSET MEAN STD /CFILL=BLANK FORMAT=5.2;
run;


/*Stepwise*/
proc glmselect data=highway;
   class Sigs; 
   model Rate = ADT Trks Lane Acpt Sigs Itg Slim Len Lwid Shld Hwy
				ADT*Sigs Trks*Sigs Lane*Sigs Acpt*Sigs Itg*Sigs Slim*Sigs Len*Sigs Lwid*Sigs Shld*Sigs Hwy*Sigs
         / selection=stepwise(select=SL) stats=all;
run;



/*GLM completo (variables + interacciones=*/
proc glm data=highway;
  class Slim;
  model Rate = Slim Lwid Hwy Lane*Sigs itg*Sigs / solution e;
run; 




/*GLM sin Hwy */

proc glm data=highway;
  class Slim;
  model Rate = Slim Lwid Lane*Sigs itg*Sigs / solution e;
run; 



/*GLM sin Lwid */
proc glm data=highway;
  class Slim;
  model Rate = Slim Lane*Sigs itg*Sigs   / solution e;
run; 


/*GLM sin itg*Sigs */
proc glm data=highway;
  class Slim;
  model Rate = Slim Lane*Sigs  
  / solution e;
run; 


/*GLM sin Lane*Sigs */
proc glm data=highway;
  class Slim;
  model Rate = Slim / solution e;
run; 




/*GLM modelo 2*/

proc glmselect data=highway;
 class Slim;
 model Rate = ADT Trks Lane Acpt Sigs Itg Slim Len Lwid Shld Hwy
			  Slim*ADT Slim*Trks Slim*Lane Slim*Acpt Slim*Sigs Slim*Itg Slim*Len Slim*Lwid Slim*Shld Slim*Hwy
       /selection=backward; 
run;

/*GLM modelo 2 sin significativas*/
proc glm data=highway;
 class Slim;
 model Rate = Sigs Len ADT*Slim Acpt*Slim Itg*Slim /solution e;
run;


/*GLM modelo 2 modelo final*/
proc glm data=highway;
 class Slim;
 model Rate = Sigs 
			  ADT*Slim Acpt*Slim Itg*Slim 
/solution e;
run;






