ods listing close; 

ods listing gpath="/courses/d28dc0adba27fe300/data_output";


/* Encuestas de Estructura Salarial */
/* http://www.ine.es/dyngs/INEbase/es/operacion.htm?c=Estadistica_C&cid=1254736177025&menu=resultados&secc=1254736195110&idp=1254735976596# */

libname lib '/home/doloreslorente0/my_content/data_input';

data salarial (drop=TSexo TJornad TContra anos2);
 set lib.ees_2014 (keep=ordenccc sexo control tipocon anos2
 				   rename= (sexo=Tsexo control=TJornad tipocon=TContra) );
*identificación de las variables;
	if TSexo=   '1' then SEXO= 'HOMBRE';  else Sexo= 'MUJER';
	if TJornad= '1' then JORNADA= 'TIEMPO COMPLETO';  else JORNADA= 'TIEMPO PARCIAL';
	if TContra= '1' then CONTRATO= 'DURACION INDEFINIDA ';  else CONTRATO= 'DURACION DETERMINADA ';
	
*tramificación de la edad;
	if anos2=  '01' then EDAD = 'MENOS 19 AÑOS ';  else if anos2= '02' then EDAD = 'DE 20 A 29 ';
	 else if anos2= '03' then EDAD = 'DE 30 A 39 ';  else if anos2= '04' then EDAD = 'DE 40 A 49 ';
	  else if anos2= '05' then EDAD = 'DE 50 A 59 ';  else if anos2= '06' then EDAD = 'MAS DE 59 ';
	  
*identificación de las variables;	  
	if TSexo=   '1' then Nsexo= 1;  else Nsexo= 0;
	if TJornad= '1' then Njornada= 1;  else Njornada= 0;
	if TContra= '1' then NContrato= 1;  else NContrato= 0;
	Nedad=input(anos2,best16.);
run;

proc sort NODUPKEY data= salarial out=salarial (drop=ordenccc );
 BY ordenccc; 
run;





/*Analisis datos: frecuencias, missings*/
proc freq data=salarial; run;


/*Analisis de outliers*/
proc MEANS data= salarial MAXDEC=2 N MEAN STD MIN MAX; *estadisticos;
var nSexo;
class _all_;
run;



/* CREACION DE VARIABLES DUMMY O FICTICIAS */

*Ordenar las categorias de la variable(s) dummy;
proc sort data= salarial; BY Nedad; run;

*Creacion de variables dummy o variables ficticias ;
data salarial (drop=i);
 set salarial;
 array dummys Edad_1 - Edad_6;	  
  do i=1 to 6;	 
   if Nedad = i then dummys(i)= 1; else dummys(i)= 0;
  end;
run;

*Visualizacion de las variables ;
proc freq data=salarial; 
tables Nedad*Edad_1*Edad_2*Edad_3*Edad_4*Edad_5*Edad_6
/  LIST NOCUM  ; 
run;



/*Macro seleccion modelo: Procedimiento Logistico
t_input  = Tabla Input
vardepen = Variable Dependiente
varindep = Variable(s) Independiente(s)
interaccion  = Variable(s) que interaccionan
semi_ini = Valor Inicial de la semilla
semi_fin = Valor Final de la semilla 
 */

%macro logistic (t_input, vardepen, varindep, interaccion, semi_ini, semi_fin );
ods trace on /listing;
%do semilla=&semi_ini. %to &semi_fin.;

 ods output EffectInModel= efectoslog;/*Test de Wald de efectos en el modelo*/
 ods output FitStatistics= ajustelog; /*"Estadisticos de ajuste", AIC */
 ods output ParameterEstimates= estimalog;/*"Estimadores de parametro"*/
 ods output ModelBuildingSummary=modelolog; /*Resumen modelo, efectos*/
 ods output RSquare=ajusteRlog; /*R-cuadrado y Max-rescalado R-cuadrado*/

 proc logistic data=&t_input. EXACTOPTIONS (seed=&semilla.) ;
  class &varindep.; 
  model &vardepen. = &varindep. &interaccion. 
     / selection=stepwise details rsquare NOCHECK;
 run;

 data un1; i=12; set efectoslog; set ajustelog; point=i; run;
 data un2; i=12; set un1; set estimalog; point=i; run;
 data un3; i=12; set un2; set modelolog; point=i; run;
 data union&semilla.; i=12; set un3; set ajusteRlog; point=i; run;

 proc append  base=t_models  data=union&semilla.  force; run;
 proc sql; drop table union&semilla.; quit; 

%end;
ods html close; 
proc sql; drop table efectoslog,ajustelog,ajusteRlog,estimalog,modelolog; quit;

%mend;


%logistic (salarial, Nsexo, Njornada Ncontrato Edad_1-Edad_6, Nsexo*Njornada Nsexo*Ncontrato Nsexo*Edad_4 Nsexo*Edad_5 Nsexo*Edad_6, 12345, 12350);


/*Analisis de los resultados obtenidos de la macro*/
proc freq data=t_models (keep=effect ProbChiSq);  tables effect*ProbChiSq /norow nocol nopercent; run;
proc sql; select distinct * from t_models (keep=effect nvalue1 rename=(nvalue1=RCuadrado)) order by RCuadrado desc; quit;
proc sql; select distinct * from t_models (keep=effect StdErr) order by StdErr; quit;



/*Tabla de clasificacion*/
proc freq data = salarial; tables Nsexo*Njornada /norow nocol nopercent relrisk; run;
proc freq data = salarial; tables Nsexo*Edad_6  /norow nocol nopercent relrisk;  run;
proc freq data = salarial; tables Nsexo*Edad_5 /norow nocol nopercent relrisk;  run;



ods graphics on;

/*Tabla de sensibilidad y especificidad para distintos puntos de corte y Curva ROC*/
proc logistic data=salarial desc  PLOTS(MAXPOINTS=NONE); 
 model Nsexo = Nsexo*Njornada Nsexo*Edad_6 Edad_5 /ctable pprob = (.05 to 1 by .05)  outroc=roc;
run;


