ods listing close; 

ods listing gpath="/courses/d28dc0adba27fe300/data_output";

libname lib '/home/soypab0/my_courses/PabloLanga/my_project';

data origin_data;
	set lib.bank_additional_full;
run;

*Analizamos la frecuencia;
proc freq data=origin_data (keep=job marital education default housing loan contact month day_of_week ); run;

proc MEANS data= origin_data MEAN Q1 Q3 N MAX MIN; *estadisticos;
run;



*Tratamiento de datos (one hot encoding variable categoricas, outliers);
data origin_data (keep=admin bluecollar entrepreneur housemaid management retired selfemployed services student technician unemployed unknownjob divorced married single unknownmarital educationN defaultno defaultyes defaultunk housingno housingyes housingunk loanno loanyes loanunk contactN monthN day_of_weekN yN ageN durationN campaingN empvarrateN conspriceidxN consconfidxN euribos3mN nremployedN);
	set lib.bank_additional_full;
	if job= 'admin.' then admin= 1;  else admin= 0;
	if job= 'blue-collar' then bluecollar= 1;  else bluecollar= 0;
	if job= 'entrepreneur' then entrepreneur= 1;  else entrepreneur= 0;
	if job= 'housemaid' then housemaid= 1;  else housemaid= 0;
	if job= 'management' then management= 1;  else management= 0;
	if job= 'retired' then retired= 1;  else retired= 0;
	if job= 'self-employed' then selfemployed= 1;  else selfemployed= 0;
	if job= 'services' then services= 1;  else services= 0;
	if job= 'student' then student= 1;  else student= 0;
	if job= 'technician' then technician= 1;  else technician= 0;
	if job= 'unemployed' then unemployed= 1;  else unemployed= 0;
	if job= 'unknown' then unknownjob= 1;  else unknownjob= 0;
	if marital= 'divorced' then divorced= 1;  else divorced= 0;
	if marital= 'married' then married= 1;  else married= 0;
	if marital= 'single' then single= 1;  else single= 0;
	if marital= 'unknown' then unknownmarital= 1;  else unknownmarital= 0;
	if education= 'illiterate' then educationN= 1;
	if education= 'basic.4y' then educationN= 2;
	if education= 'basic.6y' then educationN= 3;
	if education= 'basic.9y' then educationN= 4;
	if education= 'high.school' then educationN= 5;
	if education= 'professional.course' then educationN= 6;
	if education= 'university.degree' then educationN= 7;
	if education= 'unknown' then educationN= 3.5;
	if default= 'no' then defaultno= 1;  else defaultno= 0; 
	if default= 'yes' then defaultyes= 1;  else defaultyes= 0;
	if default= 'unknown' then defaultunk= 1;  else defaultunk= 0;
	if housing= 'no' then housingno= 1;  else housingno= 0;
	if housing= 'yes' then housingyes= 1;  else housingyes= 0;
	if housing= 'unknown' then housingunk= 1;  else housingunk= 0;
	if loan= 'no' then loanno= 1;  else loanno= 0;
	if loan= 'yes' then loanyes= 1;  else loanyes= 0;
	if loan= 'unknown' then loanunk= 1;  else loanunk= 0;
	if contact= 'cellular' then contactN= 1;  else contactN= 0;
	if month= 'mar' then monthN= 3;
	if month= 'apr' then monthN= 4;
	if month= 'may' then monthN= 5;
	if month= 'jun' then monthN= 6;
	if month= 'jul' then monthN= 7;
	if month= 'aug' then monthN= 8;
	if month= 'sep' then monthN= 9;
	if month= 'oct' then monthN= 10;
	if month= 'nov' then monthN= 11;
	if month= 'dec' then monthN= 12;
	if day_of_week= 'mon' then day_of_weekN= 1;
	if day_of_week= 'tue' then day_of_weekN= 2;
	if day_of_week= 'wed' then day_of_weekN= 3;
	if day_of_week= 'thu' then day_of_weekN= 4;
	if day_of_week= 'fri' then day_of_weekN= 5;
	if y= 'no' then yN= 0; else yN= 1;
	if age 				> 80.75 	then ageN 			=80.75		;else ageN 			  	= age 			;	
	if duration 		> 644.5 	then durationN 		=644.5		;else durationN 		= duration 		;
	if campaing 		> 6 		then campaingN 		=6			;else campaingN 		= campaing 		;
	if emp.var.rate 	> 6.2 		then empvarrateN 	=6.2		;else empvarrateN 		= emp.var.rate 	;
	if cons.price.idx 	> 95.374 	then conspriceidxN 	=95.374		;else conspriceidxN 	= cons.price.idx; 	
	if cons.conf.idx 	> -26.95 	then consconfidxN 	=-26.95		;else consconfidxN  	= cons.conf.idx ;	
	if euribos3m 		> 10.391 	then euribos3mN 	=10.391		;else euribos3mN 	  	= euribos3m 	;	
	if nr.employed 		> 5421.6 	then nremployedN 	=5421.6		;else nremployedN 	  	= nr.employed 	;	
	if age 				< -1.75		then ageN 			=-1.75		;else ageN 			  	= age 			;	
	if duration 		< -223.5	then durationN 		=-223.5		;else durationN 		= duration 		;
	if campaing 		< -2		then campaingN 		=-2			;else campaingN 		= campaing 		;
	if emp.var.rate 	< -6.6		then empvarrateN 	=-6.6		;else empvarrateN 		= emp.var.rate 	;
	if cons.price.idx 	< 91.695 	then conspriceidxN 	=91.695		;else conspriceidxN 	= cons.price.idx; 	
	if cons.conf.idx 	< -52.15 	then consconfidxN 	=-52.15		;else consconfidxN  	= cons.conf.idx ;	
	if euribos3m 		< -4.086 	then euribos3mN		=-4.086		;else euribos3mN		= euribos3m 	;	
	if nr.employed 		< 4905.6 	then nremployedN 	=4905.6		;else nremployedN 	  	= nr.employed 	;
run; 


proc corr data=origin_data ;   run;

/* MACRO VALIDACIÓN CRUZADA PARA REGRESIÓN NORMAL */
%macro cruzada(archivo,vardepen,ngrupos, varindep);
data final; run;
%do semilla=12355 %to 12365;/*<<<<<******AQUI SE PUEDEN CAMBIAR LAS SEMILLAS */
data dos; set &archivo; u=ranuni(&semilla);
proc sort data=dos; by u; run;
data dos ; retain grupo 1; set dos nobs=nume;
 if _n_>grupo*nume/&ngrupos then grupo=grupo+1; run;
data fantasma; run;
%do exclu=1 %to &ngrupos;
data tres; set dos; if grupo ne &exclu then vardep=&vardepen;
proc reg data=tres noprint;/*<<<<<******SE PUEDE QUITAR EL NOPRINT */
model vardep= &varindep.;/*<<<<<*** REEMPLAZAR POR EL CONJUNTO DE VAR INDEPENDIENTES */
output out=sal p=predi; run;
data sal;set sal;resi2=(&vardepen-predi)**2;if grupo=&exclu then output;run;
data fantasma;set fantasma sal;run;
%end;
proc means data=fantasma sum noprint; var resi2;
output out=sumaresi sum=suma; run;
data sumaresi; set sumaresi; semilla=&semilla;
data final (keep=suma semilla); set final sumaresi; if suma=. then delete; run;
%end;
proc print data=final;run;
%mend;

/*Regresión lineal ****************************************************/
/*%cruzada(origin_data,yN,5,admin bluecollar entrepreneur housemaid management retired selfemployed services student technician unemployed divorced married single  educationN defaultno defaultyes housingno housingyes loanno contactN monthN day_of_weekN ageN durationN empvarrateN conspriceidxN consconfidxN nremployedN);*/
%cruzada(origin_data,yN,5,entrepreneur management student selfemployed housingno loanno ageN durationN);
data final1; set final; modelo=1; run;

%cruzada(origin_data,yN,5,entrepreneur management student selfemployed housingno loanno ageN durationN educationN services retired housemaid);
data final2; set final; modelo=2; run;

%cruzada(origin_data,yN,5,admin bluecollar  retired selfemployed services student technician unemployed divorced married single );
data final3; set final; modelo=3; run;

proc means data=final1; run;
proc means data=final2; run;
proc means data=final3; run;


proc reg data=origin_data;  model yN = entrepreneur management student selfemployed housingno loanno ageN durationN educationN services retired housemaid / tol vif collin; run;*/


/* Modelo GLM  ********************************************************/;


proc glmselect data=origin_data;
   model yN = entrepreneur management student selfemployed housingno loanno ageN durationN educationN services retired housemaid
         		 ageN*entrepreneur ageN*management ageN*student ageN*selfemployed ageN*housingno ageN*loanno ageN*retired ageN*services ageN*housemaid 
         / selection=stepwise(select=SL) stats=all;
run;

proc glm data=origin_data;
  model yN = entrepreneur student selfemployed durationN educationN retired housemaid student*ageN selfemployed*ageN housingno*ageN ageN*retired ageN*services ageN*housemaid / solution e;
run;

/*Red Neuronal ********************************************************/

/* redes neuronales con funcion de activacion tangente hiperbolica,
   metodo de particion validacion cruzada, con 6 nodos y 20 semillas. 
	t_input  = Tabla Input
	vardepen = Variable Dependiente
	nparam   = Numero de Parametros
	nnodos   = Numero de Nodos
	semi_ini = Valor Inicial de la semilla
	semi_fin = Valor Final de la semilla
	factiva = funcion de activacion (tanh=tangente hiperbolica; LIN=funcion de activacion lineal).NORMALMENTE PARA DATOS NO LINEALES MEJOR ACT=TANH
	varindep = Variable(s) Independiente(s)
*/

%macro cruzaneural(t_input,vardepen,nparam,nnodos, semi_ini, semi_fin, factiva, varindep );
data t_output;run;
%do semilla=&semi_ini. %to &semi_fin.;
data dos;set &t_input.; u=ranuni(&semilla.); run;
proc sort data=dos; by u; run;

data dos;
retain grupo 1;
set dos nobs=nume;
if _n_>grupo*nume/&nparam. then grupo=grupo+1;
run;

data fantasma;run;
%do exclu=1 %to &nparam.;
data trestr tresval;
set dos;if grupo ne &exclu. then output trestr; else output tresval; run;

PROC DMDB DATA=trestr dmdbcat=catatres;
target &vardepen.;
var &vardepen. &varindep.; run;

proc neural data=trestr dmdbcat=catatres random=789 
validata=tresval;
input &varindep.;

target &vardepen.;
hidden &nnodos. / act=&factiva.;
prelim 30;
train maxiter=1000 outest=mlpest technique=dbldog;
score data=tresval role=valid out=sal ;
run;

data sal;set sal;resi2=(p_&vardepen.-&vardepen.)**2;run;
data fantasma;set fantasma sal;run;
%end;
proc means data=fantasma sum noprint;var resi2;
output out=sumaresi sum=suma;
run;
data sumaresi;set sumaresi;semilla=&semilla.;
data t_output (keep=suma semilla);set t_output sumaresi;if suma=. then delete;run;
%end;
proc sql; drop table dos,trestr,tresval,fantasma,mlpest,sumaresi,sal,_namedat; quit;
%mend;


/* Modelo 1 */   
%cruzaneural(origin_data, yN, 3, 4, 12355, 12355, lin, entrepreneur management student selfemployed ageN durationN educationN retired );
data modelo1; set t_output; modelo='Modelo 1'; run;

/* Modelo 1 */   
%cruzaneural(origin_data, yN, 3, 4, 12355, 12355, tanh, entrepreneur management student selfemployed ageN durationN educationN retired);
data modelo2; set t_output; modelo='Modelo 2'; run;

/*union de las tablas*/ 
data t_output; set modelo1 modelo2; run;

/* Analisis de sumas de los errores */
proc means data=t_output; class modelo; var suma; run;


/* ejecucion del modelo, primero carga el catalogo*/
proc dmdb data=origin_data dmdbcat=archivocat;
class yN;
target yN;
var entrepreneur management student selfemployed ageN durationN educationN retired;
run;

proc neural data=origin_data dmdbcat=archivocat random=789;
input  entrepreneur management student selfemployed ageN durationN educationN retired;
target yN;
hidden 4 / act=tanh;
prelim 30;
train maxiter=1000 outest=mlpest technique=dbldog;
score data=origin_data role=valid out=sal_prediccion ;
run;


/* Modelo Regresión logística  ********************************************************/;


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


%logistic (origin_data, yN, entrepreneur management student selfemployed housingno loanno ageN, , 12355, 12365);
%logistic (origin_data, yN, entrepreneur management student selfemployed housingno  ageN, , 12355, 12365);
%logistic (origin_data, yN, entrepreneur management student selfemployed housingno loanno, , 12355, 12365);


/*Analisis de los resultados obtenidos de la macro*/
proc freq data=t_models (keep=effect ProbChiSq);  tables effect*ProbChiSq /norow nocol nopercent; run;
proc sql; select distinct * from t_models (keep=effect nvalue1 rename=(nvalue1=RCuadrado)) order by RCuadrado desc; quit;
proc sql; select distinct * from t_models (keep=effect StdErr) order by StdErr; quit;


ods graphics on;

/*Tabla de sensibilidad y especificidad para distintos puntos de corte y Curva ROC*/
proc logistic data=origin_data desc  PLOTS(MAXPOINTS=NONE); 
 model yN = entrepreneur management student selfemployed housingno loanno ageN /ctable pprob = (.05 to 1 by .05)  outroc=roc;
run;


/*Seleccion de los clientess*/;

proc glm data=origin_data; 
  model yN = entrepreneur student selfemployed durationN educationN retired housemaid student*ageN selfemployed*ageN housingno*ageN ageN*retired ageN*services ageN*housemaid ;
  output out=pout predicted=pyN;
run;

proc sort data=pout out=poutsort;By pyN;run;

proc sql outobs=4118;
	select * from pout order by pyN;
run;

PROC SURVEYSELECT data=pout out=poutAleatorio method=SRS N=2059; run;
