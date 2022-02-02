*******************************************
* Homework1
* last updated: June 7, 2021
*******************************************;

dm 'clear log'; dm 'clear output';  /* clear log and output */

libname HW1 "E:\Users\rjc200002\Documents\My SAS Files\Homework1";
title;

	** Load body temperature data;;
proc contents data = HW1.normtemp;
	run;

** Create histograms of continuous variables;;
proc univariate data=HW1.normtemp normal noprint;
	var BodyTemp HeartRate;
	histogram BodyTemp HeartRate / normal kernel;
	inset mean std n / position = ne;
	label BodyTemp = 'Body Temperature (F)';
	label HeartRate = 'Heart Rate Distribution (bpm)';
run;

**99% CI**;;
proc means data=hw1.normtemp maxdec=2 alpha = 0.01
 n mean std stderr clm;
 var BodyTemp;
 title '99% Confidence Interval for SAT';
run;

** One-sample t-test for mean body temp of 98.6;;
proc ttest data=HW1.normtemp sides=2 h0=98.6 alpha = 0.01
	plots (shownull) = intervalplot;
	var BodyTemp;
	title "One-sample t-test under h0 = 98.6F";
run;

