dm 'clear log'; dm 'clear output';  /* clear log and output */

libname project "E:\Users\sxg200111\Documents\My SAS Files\9.4\Project";
title;

/*import spy data*/
proc import datafile = 'E:\Users\sxg200111\Documents\My SAS Files\9.4\Project\StocksUsed\spy.us.txt'
out = spy
dbms = dlm
replace
;
delimiter = ",";
run;


/*import xle data*/
proc import datafile = 'E:\Users\sxg200111\Documents\My SAS Files\9.4\Project\StocksUsed\xle.us.txt'
out = xle
dbms = dlm
replace
;
delimiter = ",";
run;

/*import aapl data*/
proc import datafile = 'E:\Users\sxg200111\Documents\My SAS Files\9.4\Project\StocksUsed\aapl.us.txt'
out = aapl
dbms = dlm
replace
;
delimiter = ",";
run;

proc sort data = aapl;
	by date;
	where date GE MDY(02, 25, 2005);
run;


/*import f data*/
proc import datafile = 'E:\Users\sxg200111\Documents\My SAS Files\9.4\Project\StocksUsed\f.us.txt'
out = f
dbms = dlm
replace
;
delimiter = ",";
run;
proc sort data = f;
	by date;
	where date GE MDY(02, 25, 2005);
run;
/*keep close price*/


/*import jnj data*/
proc import datafile = 'E:\Users\sxg200111\Documents\My SAS Files\9.4\Project\StocksUsed\jnj.us.txt'
out = jnj
dbms = dlm
replace
;
delimiter = ",";
run;
proc sort data = jnj;
	by date;
	where date GE MDY(02, 25, 2005);
run;


/*import mrk data*/
proc import datafile = 'E:\Users\sxg200111\Documents\My SAS Files\9.4\Project\StocksUsed\mrk.us.txt'
out = mrk
dbms = dlm
replace
;
delimiter = ",";
run;
proc sort data = mrk;
	by date;
	where date GE MDY(02, 25, 2005);
run;

/*import msft data*/
proc import datafile = 'E:\Users\sxg200111\Documents\My SAS Files\9.4\Project\StocksUsed\msft.us.txt'
out = msft
dbms = dlm
replace
;
delimiter = ",";
run;
proc sort data = msft;
	by date;
	where date GE MDY(02, 25, 2005);
run;

/*import pg data*/
proc import datafile = 'E:\Users\sxg200111\Documents\My SAS Files\9.4\Project\StocksUsed\pg.us.txt'
out = pg
dbms = dlm
replace
;
delimiter = ",";
run;
proc sort data = pg;
	by date;
	where date GE MDY(02, 25, 2005);
run;
/*keep close price*/

/*import vz data*/
proc import datafile = 'E:\Users\sxg200111\Documents\My SAS Files\9.4\Project\StocksUsed\vz.us.txt'
out = vz
dbms = dlm
replace
;
delimiter = ",";
run;
proc sort data = vz;
	by date;
	where date GE MDY(02, 25, 2005);
run;

/*import xom data*/
proc import datafile = 'E:\Users\sxg200111\Documents\My SAS Files\9.4\Project\StocksUsed\xom.us.txt'
out = xom
dbms = dlm
replace
;
delimiter = ",";
proc sort data = xom;
	by date;
	where date GE MDY(02, 25, 2005);
run;

/*/*merge price at close data*/
proc sql;
	CREATE TABLE merged_data AS
	 SELECT Aapl.Date, 
			Aapl.Close as Apple, 
			F.Close as Ford, 
			Jnj.Close as JNJ,
			Mrk.Close as MRK,
			Msft.Close as Microsoft,
			Pg.Close as PG,
			Vz.Close as Verizon
	 FROM Aapl inner join F
	 ON Aapl.Date= F.Date
	 inner join Jnj
	 On Aapl.Date = Jnj.Date
	 inner join Mrk
	 On Mrk.Date = Aapl.Date
	 inner join Msft
	 On Aapl.Date = Msft.Date
	 inner join Pg
	 On Aapl.Date = Pg.Date
	 inner join Vz
	 On Aapl.date = Vz.Date
	 
	;
quit;


/*time series plot*/

proc sgplot data = Merged_data;
	yaxis label = 'Closing Price';
	series x=date y=Apple / lineattrs=(color=blue);
	series x=date y=Ford;
	series x=date y=Jnj;
	series x=date y=Microsoft;
	Title 'Stock analysis of major companies';
run;

/* Duplicate the Daily returns*/

data _null_;
  oldname = 'Work.Merged_data.txt';
  newname = 'Daily_Returns.txt';
  rc= system(quote(catx(' ','copy',quote(trim(oldname)),quote(trim(newname)))));
  put rc=;
run;

/*Daily returns*/
*Find dail returns based on each security based on previous day price;

proc sql;
	create table apple_close as
		select Date, Close as Apple from Aapl;
	create table ford_close as
		select Date,Close as Ford from F;
	create table jnj_close as 
		select date,Close as Jnj from Jnj;
	create table Mrk_close as
		select Date,Close as Mrk from Mrk;
	create table Msft_close as
		select Date,Close as Microsoft from Msft;
quit;

*To get daily returns;
data Returns(keep=Date Apple Ford Jnj Mrk Microsoft);
	merge work.apple_Close (in=inApple) work.ford_close(in=inFord) work.jnj_close(in=injnj)
			work.mrk_close (in=inMrk) work.Msft_close (in = inMicrosoft);
	by date;
	Apple = Apple/lag(Apple)-1;
	Ford = Ford/lag(Ford)-1;
	Jnj = Jnj/lag(Jnj)-1;
	Mrk = Mrk/lag(Mrk)-1;
	Microsoft = Microsoft/lag(Microsoft)-1;
run;

proc print data =work.returns;
	title 'Daily Asset Returns';
run;

/* basic statistics*/
PROC MEANS data = work.Returns N MEAN SUM STD MIN MAX;
	VAR Apple Ford Jnj Mrk Microsoft;
	output out = returns_means;
run;


/*proc correlation*/
ods graphics on;
proc corr data = work.returns nomiss plots(maxpoints = none) = matrix(nvar = 5);
	title('Correlation procedure for assets');
	VAR Apple Ford Jnj Mrk Microsoft;
run;

proc corr data = work.returns nomiss plots = Matrix(Histogram);
	title('Correlation procedure for assets');
	VAR Apple Ford Jnj Mrk Microsoft;
run;


















