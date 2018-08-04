ods listing close; 

ods listing gpath="/courses/d28dc0adba27fe300/data_output";

/* Macroeconomia
Considerar el fichero Macroeconomia  de Francia, en el se proporciona informacion sobre la evolucion de las importaciones 
en funcion del stock financiero del Estado, el producto interior Bruto y el consumo. */

data macroeconomia;
  input YEAR IMPORTACION PROD_INTERIOR STOCK CONSUMO;
cards;
49 15.9 149.3 4.2 108.1
50 16.4 161.2 4.1 114.8
51 19   171.5 3.1 123.2
52 19.1 175.5 3.1 126.9
53 18.8 180.8 1.1 132.1
54 20.4 190.7 2.2 137.7
55 22.7 202.1 2.1 146
56 26.5 212.4 5.6 154.1
57 28.1 226.1 5   162.3
58 27.6 231.9 5.1 164.3
59 26.3 239   0.7 167.6
60 31.1 258   5.6 176.8
61 33.3 269.8 3.9 186.6
62 37 288.4   3.1 199.7
63 43.3 304.5 4.6 213.9
64 49 323.4   7   223.8
65 50.3 336.8 1.2 232
66 56.6 353.9 4.5 242.9
;
run;

/*Analisis frecuencias, missings*/
proc freq data= macroeconomia; run;


/*Analisis de normalidad, outliers*/
proc univariate data=macroeconomia normal plot;
 var IMPORTACION;
 qqplot IMPORTACION / NORMAL (MU=EST SIGMA=EST COLOR=RED L=1);
 HISTOGRAM /NORMAL(COLOR=MAROON W=4) CFILL = pink CFRAME = LIGR;
 INSET MEAN STD /CFILL=BLANK FORMAT=5.2;
run;


/*Analisis de Correlacion*/
proc corr data=macroeconomia;  var IMPORTACION YEAR PROD_INTERIOR STOCK CONSUMO;  run;




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
%cruzaneural(macroeconomia, IMPORTACION, 4, 6, 12345, 12364, tanh, YEAR PROD_INTERIOR STOCK CONSUMO);

data modelo1; set t_output; modelo='Modelo 1'; run;



/* Modelo 2  */  
%cruzaneural(macroeconomia, IMPORTACION, 4, 4, 12345, 12364, LIN, YEAR PROD_INTERIOR STOCK CONSUMO);

data modelo2; set t_output; modelo='Modelo 2'; run;



/*union de las tablas*/ 
data t_output; set modelo1 modelo2; run;

/* Analisis de sumas de los errores */
proc means data=t_output; class modelo; var suma; run;

/* Grafico box plot */
proc boxplot data=t_output; plot suma*modelo; run;



/* ejecucion del modelo, primero carga el catalogo*/
proc dmdb data=macroeconomia dmdbcat=archivocat;
target IMPORTACION;
var  IMPORTACION YEAR PROD_INTERIOR STOCK CONSUMO;
run;

proc neural data=macroeconomia dmdbcat=archivocat random=789;
input  YEAR PROD_INTERIOR STOCK CONSUMO;
target IMPORTACION;
hidden 4 / act=LIN;
prelim 30;
train maxiter=1000 outest=mlpest technique=dbldog;
score data=macroeconomia role=valid out=sal_prediccion ;
run;




