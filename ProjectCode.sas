/* Team4 */
/*projlib is the library name where the dataset is available*/
libname projlib "D:\Spring Sem\IDS462\Project";

/* Creates a temporary sas dataset with the same name as permanent dataset(team4)*/
data team4;
set projlib.team4;
run;

/* Contents of the data can be viewed*/
proc contents data=team4;
run;
 

/*Problem 1: Creating 2 maro variables Interval(for continuous variables) and Categorical(for categorical variables)*/;
%let interval= Lot_Area Gr_Liv_Area Garage_Area Basement_Area Deck_Porch_Area SalePrice Log_Price;
%let categorical=House_Style Overall_Qual Overall_Cond Year_Built Heating_QC Central_Air Bedroom_AbvGr Fireplaces
			Mo_Sold Yr_Sold Half_Bathroom Full_Bathroom Total_Bathroom Age_Sold Season_Sold Garage_Type_2 Foundation_2 
			Masonry_Veneer Lot_Shape_2 House_Style2 Overall_Qual2 Overall_Cond2 Bonus;


/*Problem 2: The code generates plots and tables for descriptive statistics for Continuous Variables;*/
ods graphics on;
proc univariate data=team4 plot;
title "Univariate analysis for Continuous variables";
var &interval;
histogram;
run;
title;
ods graphics off;

/* The code generates plots and tables for dicriptive statistics for Categorical Variables;*/
ods graphics on;
proc freq data=team4 ;
title "Univariate analysis for Categorical variables";
tables &categorical / plots=FREQPLOTS;
run;
title;
ods graphics off;

/*Problem 3: The code performs t-test to check if the mean SalePrice is $135,000 or not*/;

*H0: The mean of SalePrice is $135,000 at 95% CL
H1: The mean of SalePrice is significantly different from $135,000 at 95% CL;

ods graphics on;
title "T-test for Null Hypothesis: H0: The mean of SalePrice is $135,000 at 95% CL";
proc ttest data=team4  plots=all alpha=0.05 ;
var SalePrice;
run;
ods graphics off;

*The p-value<0.05, hence we can reject the Null hypothesis.
The graphs also conclude that the mean is 140107.
We conclude that the Sale Price is statistically significantly different from $135,000 at 95%CL.

/*Problem 4: The code performs t-test to show id there is a significance between SalePrice and houses with Masonry Veneer*/;

*H0: There is no statistical difference between mean SalePrice for homes with masonry veneer and those without masonry vaneer.
H1: There is a statistical difference between mean Sale Price for homes with masonry vaneer and those without masonry vaneer.;

ods graphics on;
proc ttest data = team4 alpha = 0.05 plots=all;
class Masonry_Veneer;
 	var SalePrice;
   run;
   ods graphics off;

*p_value< 0.001, hence we reject the Null hypothesis.
There is a statistical difference between mean Sale Price for homes with masonry vaneer and those without masonry vaneer.;
*Mean SalePrices of houses with Masonry Veneer($156524) are higher the those without Masonry Veneer($132901).;

 /*Problem 5*/
*This code creates scatter plots to show relationships between continuous predictors 
 and SalePrice and the second code creates comparative box plots to show 
 relationships between categorical predictors and SalePrice. ;

ods graphics / reset=all imagemap;
ods select scatterplot;
proc corr data=work.team4 rank 
		plots(only) =scatter(nvar=6 ellipse=none); /*excluded SalePrice from VAR list*/
	var &interval;
	with SalePrice; 
	title "Correlations and Scatter Plots(SalePrice vs Continuous Variables)";
run;
ods graphics off;



%macro comparativebox(predictor1);
proc sgplot data=team4; 
vbox SalePrice / category=&predictor1 connect=mean;
title "Sale Price Differences across &predictor1";
run;
%mend comparativebox;

%comparativebox(House_style)
%comparativebox(Overall_Qual)
%comparativebox(Overall_Cond)





/*Problem 6: This code generates corelationship between the SalePrice and the continuous variables.*/

proc corr data=team4 ;
title "Relationship between SalePrice and Continuous variables";
var SalePrice ;
with &interval;
run;

*High co-relationship with Gr_Liv_Area, Garage_Area and Basement_Area.
*SalePrice has low correlationship with Lot_Area  and Deck_Porch_Area.
*All variables are positively correlated which means that an increse in 
any of the variables will increase the Sale Price;

/*Problem 7: This code generates a simple regreassion model with GR_Liv_Ar*/
ods graphics on;
proc reg data=team4 plots=all;
title "Regression Model: SalePrice vs Gr_Liv_Ar";
model SalePrice=Gr_Liv_Area;
run;
ods graphics off;

*We have chosen GR_Liv_Area as a significant predictor as the p-value is less than 0.01 and
it is highly correlated with SalePrice.;
*y=28608+97.30488Gr_Liv_Area;

/*Problem 8: This code provides a regression model for SalePrice as responce variable snd 
Lot_Area and BAsement_Area as predictors*/

ods graphics on;
proc glm data=team4
 plots(only)=(contourfit);
 model SalePrice=Basement_Area Lot_Area;
 store out=multiple;
 title "Model with Basement Area and Gross Living Area";
run;
ods graphics off;

/*y=72008 + 0.89201Lot_Area + 66.19311Basement_Area
Both the variables are statitically significant in predicting the Sale Price */

/*Problem 9: This code creates a macro programs named stepwise,forward and backward which creates a model using glm and respective selection.
The macro program is called with each of the selection options using SL,AIC, BIC, AICC and SBC respectively*/
%let interval1= Lot_Area Gr_Liv_Area Garage_Area Basement_Area Deck_Porch_Area ;

%macro stepwise(options);
proc glmselect data=team4;
model SalePrice=&interval1 / selection=stepwise(select=&options sle=0.05 sls=0.05) details=steps;
run;
%mend stepwise;

%macro backward(options);
proc glmselect data=team4;
model SalePrice=&interval1 / selection=backward(select=&options sls=0.05)details=steps ;
run;
%mend backward;

%macro forward(options);
proc glmselect data=team4;
model SalePrice=&interval1 / selection=forward(select=&options sle=0.05) details=steps;
run;
%mend forward;

options mprint;
title "Selection Method:Stepwise and Option: SL";
%stepwise(SL)
title "Selection Method:Stepwise and Option: AIC";
%stepwise(AIC)
title "Selection Method:Stepwise and Option: BIC";
%stepwise(BIC)
title "Selection Method:Stepwise and Option: AICC";
%stepwise(AICC)
title "Selection Method:Stepwise and Option: SBC";
%stepwise(SBC)

title "Selection Method:Backward and Option: SL";
%backward(SL)

title "Selection Method:Forward and Option: SL";
%backward(SL)

/*The significance level of entry into and significance level stay have no impact when  you use other options than SL */
/*Gr_Liv_Area Garage_Area Basement_Area and Deck_Porch_Area remain for each of the 5 options*/
/*In this case, Backward selection is the best method because it gives us the answer in step 1 as it selects all variables except one but
ideally stepwise would be a recommended method. 
In this case BIC gives us the least value at 16030 hence would be the recommended selection criterion*/
 
/*Problem 10: This code provides a regression model using all continuous variables on SalePrice 
using rquare, adjrsquare and Mallow's C(p).

*/
%macro quest10(seloptions);
ods graphics on;
proc reg data=team4 ;
model SalePrice=&interval1 /selection= &seloptions;
run;
ods graphics off;
%mend quest10;

title "Option: rquare";
%quest10(rsquare)
title "Option: adjrsq";
%quest10(adjrsq)
title "Options: cp";
%quest10(cp)
/*The best model would be using the Adjusted R-square values when compared to R-squared and Mallow's C(p).
This is because evry independent variable i.e. each continuous variable exaplins the variance in the
dependent variable i.e. SalePrice.*/

/*Problem 11: The code creates One-way frequency  fro variables Bonus Fireplaces and Lot_Shape_2.
The second code creates a Two-way frequency for Bonus by Fireplaces and Bonus by Lot_Shape_2 */

%let var1=Bonus Fireplaces Lot_Shape_2;
title "One-Way frequency: Bonus Fireplaces and Lot_Shape_2";
proc freq data=team4;
tables &var1;
run;
/* One missing frequency in Lot_Shape_2*/

%let var2= Fireplaces Lot_Shape_2;
title "Two-way Frequency";
proc sort data=team4 out=team4Sort;
by Bonus;
run;
proc freq data=team4Sort; 
tables &var2 * Bonus ;
by Bonus;
run;

ods graphics on;
title "Univariate Analysis: Basement_Area on Bonus";
proc univariate data=team4Sort plots;
var Basement_Area;
class Bonus;
histogram;
run;
ods graphics off;

/*a)There seems to be one missing value in Lot_Shape_2.
b)Bonus vs Fireplaces:Whenever Bonus has been received(1),it has been received maximum times(79) to houses with 1 fireplace followed by houses with 0 fireplaces(37) and the least for 2 fireplaces(8). 
Bonus vs Lot_Shape_2:Whenever Bonus has been receievd(1), it has been more for irregular shaped house(72) compared to regular shaped houses(52).
Bonus vs Basement_Area: Houses without a Bonus have a normal distribution.
whereas houses that have received a Bonus(1) is left skewed (negatively skewed).
i.e. houses with more Basement_Area have received more Bonus.*/ 

/*Problem13:This code displays association and various attrubutes through which association can be determined between Bonus and Fireplaces */
title "Ordinal Association between Bonus and Fireplaces";
PROC FREQ DATA = team4;
TABLES bonus * fireplaces
/CHISQ cmh measures ;
run;
/*a)Yes, Bonus and Fireplaces have a significant ordinal association.*/
/*b)No, Spearman's correlation statistics(0.2899) does suggest a significant relationship at sl=0.05*/

/*Problem14: This code runs a logistic regression for the variables Lot_Area
a)*/
title "Logistic Regression : Lot_Area on Bonus";
proc logistic data=team4;
model Bonus(event='1')=Lot_Area /alpha=0.1;
run;

/*b)The "Testing Global Null Hypothesis: BETA=0" table displays results of the likelihood ratio test, the score test, 
and the Wald test for testing the hypothesis that all parameters are zero. 

c)The Likelihood ratio Chi-sq(4.6421) suggests that atleast one of the regression coeffients i.e. Lot_Area is
significantly different from 0.*/

/*d)
Equation: y=-2.1426 + 0.000049Lot_Area

e)
Yes, p-value is significant at sl 0.10.

f)
The odds ratio is 1 which mean that the 2 variables Bonus and Lot_Area are independent of each other. 
The odds of a Bonus is same in the presence and absence of Lot_Area and vice-versa.
*/ 

