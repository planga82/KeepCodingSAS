
data procesionaria; 
  input identificacion X1 X2 X3 X4 X5 X6 X7 X8 X9 X10 X11;
  label x1='altitud' 
        x2='pendiente' 
        x3='num pinos por 5 areas' 
        x4='altura centro'
	    x5='diametro' 
	    x6='densidad poblacion' 
	    x7='orientacion' 
	    x8='altura dominante' 
        x9='num estratos vegetacion' 
        x10='mezcla poblacion' 
        x11='num nidos procesionaria por arbol'
		y='num nidos procesionaria por arbol (log)'; 
		Y=log(x11); 
   cards;
1  1200 22 1  4.0 14.8 1.0 1.1 5.9 1.4 1.4 2.37
2  1342 28 8  4.4 18.0 1.5 1.5 6.4 1.7 1.7 1.47
3  1231 28 5  2.4  7.8 1.3 1.6 4.3 1.5 1.4 1.13
4  1254 28 18 3.0  9.2 2.3 1.7 6.9 2.3 1.6 0.85
5  1357 32 7  3.7 10.7 1.4 1.7 6.6 1.8 1.3 0.24
6  1250 27 1  4.4 14.8 1.0 1.7 5.8 1.3 1.4 1.49
7  1422 37 22 3.0  8.1 2.7 1.9 8.3 2.5 2.0 0.30
8  1309 46 7  5.7 19.6 1.5 1.3 7.8 1.8 1.6 0.07
9  1127 24 2  3.5 12.6 1.0 1.7 4.9 1.5 2.0 3.00
10 1075 34 9  4.3 12.0 1.6 1.8 6.8 2.0 2.0 1.21
11 1166 24 17 5.5 16.7 2.4 1.5 11.5 2.9 1.7 0.38
12 1182 41 32 5.4 21.6 3.3 1.4 11.3 2.8 2.0 0.70
13 1179 15 0  3.2 10.5 1.0 1.7 4.0 1.1 1.6 2.64
14 1256 21 0  5.1 19.5 1.0 1.8 5.8 1.1 1.4 2.05
15 1251 26 2  4.2 16.4 1.1 1.7 6.2 1.3 1.8 1.75
16 1536 38 31 5.7 17.8 3.1 1.7 11.4 2.8 1.9 0.06
17 1554 27 20 5.6 20.2 2.8 1.9 9.2 2.7 1.3 0.13
18 1305 30 6  3.8 15.7 1.4 1.2 7.2 2.1 1.9 1.00
19 1316 34 8  3.1 11.4 1.5 1.8 5.0 1.6 2.0 0.41
20 1427 39 19 4.6 15.2 2.4 1.6 9.1 2.4 1.9 0.72
21 1575 20 32 5.2 18.9 3.0 1.7 9.4 2.5 1.8 0.67
22 1397 26 16 4.2 14.8 2.2 1.6 7.7 2.2 1.8 0.12
23 1377 29 4  5.3 19.8 1.2 1.8 6.8 1.6 1.9 0.97
24 1574 24 23 5.2 17.8 2.4 1.8 7.8 2.2 2.0 0.07
25 1396 45 13 4.7 15.2 1.7 1.6 7.8 2.1 1.4 0.10
26 1393 27 5  4.7 18.3 1.2 1.7 7.5 1.7 2.0 0.68
27 1433 23 18 6.5 21.0 2.7 1.8 13.7 2.7 1.3 0.13
28 1349 24 1  2.7  5.8 1.0 1.7 3.6 1.3 1.8 0.20
29 1208 23 2  3.5 11.5 1.1 1.7 5.4 1.3 2.0 1.09
30 1198 28 15 3.9 11.3 2.0 1.6 7.4 2.8 2.0 0.18
31 1228 31 6  5.4 21.8 1.3 1.7 7.0 1.5 1.9 0.35
32 1229 21 11 5.8 16.7 1.7 1.8 10.0 2.3 2.0 0.21
33 1310 36 17 5.2 17.8 2.3 1.9 10.3 2.6 2.0 0.03
; 
proc print; run;


/* Data cooking */

proc freq data=procesionaria; run;

proc univariate data=procesionaria normal plot;
 var y;
 qqplot y / NORMAL (MU=EST SIGMA=EST COLOR=RED L=1);
 HISTOGRAM /NORMAL(COLOR=MAROON W=4) CFILL = BLUE CFRAME = LIGR;
 INSET MEAN STD /CFILL=BLANK FORMAT=5.2; 
run;


/*correlacion*/
proc corr data=procesionaria ;  var y x1-x10;  run;


/*colinealidad*/
proc reg data=procesionaria;  model y = x1-x10 / tol vif collin; run;


/*contraste de factores*/
proc pls data=procesionaria; class X1-X10; model y=X1-X10; run;


/*analisis press */
proc pls data=procesionaria method=pls  cv=random(ntest=1) 
cvtest(stat=press seed=12345);  model Y=X1-X10 / solution; 
run;


/* MACRO VALIDACIÓN CRUZADA PARA REGRESIÓN PLS */
%macro cruzadapls(archivo,vardepen,ngrupos);
data final; run;
%do semilla=1234 %to 1253;/*<<<<<******AQUI SE CAMBIAN LAS SEMILLAS */
data dos;set &archivo;u=ranuni(&semilla);
proc sort data=dos;by u;run;

data dos ;
retain grupo 1;
set dos nobs=nume;
if _n_>grupo*nume/&ngrupos then grupo=grupo+1;
run;

data fantasma; run;
%do exclu=1 %to &ngrupos;
data tres; set dos; if grupo ne &exclu then vardep=&vardepen;

proc pls data=tres noprint nfac=2;/*nfac=1; nfac=3; <<<<< *CAMBIAMOS EL NFAC */
model vardep=X1-X10; /*<<<<<****** REEMPLAZAR POR EL CONJUNTO DE VAR INDEPEND. */
output out=sal p=predi;run;

data sal; set sal; resi2=(&vardepen-predi)**2;if grupo=&exclu then output;run;
data fantasma; set fantasma sal; run;
%end;
proc means data=fantasma sum noprint; var resi2;
output out=sumaresi sum=suma; run;
data sumaresi;set sumaresi;semilla=&semilla;
data final (keep=suma semilla);set final sumaresi;if suma=. then delete;run;
%end;
proc print data=final; run;
%mend;


%cruzadapls(procesionaria,y,10); *con nfac=1;
data final1; set final; num_fac=1; run;

%cruzadapls(procesionaria,y,10); *con nfac=2;
data final2; set final; num_fac=2; run;

%cruzadapls(procesionaria,y,10); *con nfac=3;
data final3; set final; num_fac=3; run;


/*Union*/
data final1; set final; num_fac=1; run;
data final2; set final; num_fac=2; run;
data final3; set final; num_fac=3; run;

/*Estadisticos para el analisis*/
proc means data=final1; run;
proc means data=final2; run;
proc means data=final3; run;
data union; set final1 final2 final3; run;
proc print data=union; run;

/*Box plot de los 3 PLS*/
proc boxplot data=union;plot suma*num_fac; run;






/* MACRO VALIDACIÓN CRUZADA PARA REGRESIÓN NORMAL */
%macro cruzada(archivo,vardepen,ngrupos);
data final; run;
%do semilla=1234 %to 1253;/*<<<<<******AQUI SE PUEDEN CAMBIAR LAS SEMILLAS */
data dos; set &archivo; u=ranuni(&semilla);
proc sort data=dos; by u; run;
data dos ; retain grupo 1; set dos nobs=nume;
 if _n_>grupo*nume/&ngrupos then grupo=grupo+1; run;
data fantasma; run;
%do exclu=1 %to &ngrupos;
data tres; set dos; if grupo ne &exclu then vardep=&vardepen;
proc reg data=tres noprint;/*<<<<<******SE PUEDE QUITAR EL NOPRINT */
model vardep=x1-x9;/*<<<<<*** REEMPLAZAR POR EL CONJUNTO DE VAR INDEPENDIENTES */
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


/*vemos que el k óptimo es 0.2, valor a partir del cual se observa la tendencia*/
proc reg data=procesionaria  outest=b outvif ridge = 0 to 0.5 by 0.05;
 model y= x1-x9 / tol vif collin; plot / ridgeplot; run; 


/* MACRO DE VALIDACIÓN CRUZADA PARA REGRESIÓN RIDGE */
%macro cruzaridge(archivo,vardepen,ngrupos);
data final; run;
%do semilla=1234 %to 1253;/*<<<<<******AQUI SE PUEDEN CAMBIAR LAS SEMILLAS */
data dos; set &archivo; u=ranuni(&semilla);
proc sort data=dos; by u; run;

data dos ; retain grupo 1; set dos nobs=nume;
if _n_>grupo*nume/&ngrupos then grupo=grupo+1; run;

data fantasma; run;
%do exclu=1 %to &ngrupos;
data tres; set dos; if grupo ne &exclu then vardep=&vardepen;

proc reg data=tres
ridge=0.2 outest=b1 noprint; model vardep=x1-X9; run;/*PARÁMETRO RIDGE Y MODELO*/

data b2 (keep=b1-b10);
array beta{10} Intercept x1-X9;/* CAMBIAR VARIABLES Y Nº DE PARAMETROS */
array b{10}; set b1; if _type_='RIDGE'; do i=1 to 10; b{i}=beta{i}; end; run;

data sal;array b{10};
if _n_=1 then set b2;
set tres;
ypredi=b1+b2*x1+b3*X3+b4*X4+b5*X5+b6*X6+b7*X7+b8*X8+b9*X9+b10*X10;/*modificar*/
residuo=&vardepen-ypredi;
resi2=residuo**2;
if grupo=&exclu then output; run;

data fantasma;set fantasma sal;run;
%end;
proc means data=fantasma sum noprint; var resi2;output out=sumaresi sum=suma;run;
data sumaresi;set sumaresi;semilla=&semilla;
data final (keep=suma semilla);set final sumaresi;if suma=. then delete;run;
%end;
proc print data=final;run;
%mend;


/* MACRO VALIDACIÓN CRUZADA PARA REGRESIÓN PLS */
%macro cruzadapls(archivo,vardepen,ngrupos);
data final; run;
%do semilla=1234 %to 1253;/*<<<<<******AQUI SE PUEDEN CAMBIAR LAS SEMILLAS */
data dos;set &archivo;u=ranuni(&semilla);
proc sort data=dos;by u;run;
data dos; retain grupo 1; set dos nobs=nume;
 if _n_>grupo*nume/&ngrupos then grupo=grupo+1; run;
data fantasma; run;
%do exclu=1 %to &ngrupos;
data tres; set dos; if grupo ne &exclu then vardep=&vardepen;
proc pls data=tres noprint nfac=2;/*<<<<<****** EL NFAC */
model vardep=X1-X9; /*<<<<<****** CONJUNTO DE VAR INDEPENDIENTES */
output out=sal p=predi; run;
data sal; set sal; resi2=(&vardepen-predi)**2;if grupo=&exclu then output;run;
data fantasma; set fantasma sal; run;
%end;
proc means data=fantasma sum noprint; var resi2;
output out=sumaresi sum=suma; run;
data sumaresi; set sumaresi; semilla=&semilla;
data final (keep=suma semilla); set final sumaresi;if suma=. then delete;  run;
%end;
proc print data=final; run;
%mend;


/*Cruzamos los 3 tipos de modelos*/

%cruzada(procesionaria,y,9);
data final1; set final; modelo=1; run;

%cruzaridge(procesionaria,y,9);
data final2; set final; modelo=2; run;

%cruzadapls(procesionaria,y,9);
data final3; set final; modelo=3; run;



/*estadisticos*/
proc means data=final1; run;
proc means data=final2; run;
proc means data=final3; run;


/* box plot de los 3*/
data union; set final1 final2 final3; run;
proc print data=union; run;
proc boxplot data=union; plot suma*modelo; run;


/* box plot de los 2*/
data union2; set final1 final3; run;
proc boxplot data=union2; plot suma*modelo; run;


/*analisis y eficacia del modelo*/
proc pls data=procesionaria method=pls nfac=2 plot=all details; 
 model  y = X1-X10 / solution; 
run;

/*grafico carga de correlacion*/
proc pls data=procesionaria nfac=2; class X1-X10; model y=X1-X10; run;



proc pls data=procesionaria method=pls nfac=2 plot=all details; 
 model y = X1-X9 / solution; 
run;
