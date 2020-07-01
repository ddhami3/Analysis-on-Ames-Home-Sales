/*Dhruv Dhami*/
libname projlib "D:\Spring Sem\IDS462\Project";
/* #1 */

title "Anova: Heating_QC on SalePrice";
ods graphics on;
proc glm data=team4 plots(only)=(diagnostics);
class Heating_QC;
model SalePrice = Heating_QC;
means Heating_QC /hovtest=levene;
run;
ods graphics off;
/*Looking at the plots and the p-value which is less than 0.01 and the F-value greater than 1(8.45) means that the null hypothesis of equal variance is rejected 
and that there is a difference between the variances of Heating_QC and SalePrice.
*/

/* #2 */
title "Comparing mean Sale prices of different Heating Quality";
proc glm data=team4;
class Heating_QC;
model SalePrice = Heating_QC;
lsmeans Heating_QC;
run;
/*The mean SalePrice is maximum for
Ex at $158076.375 then
Gd at $135938.546 and TA at $129800.506 then
Fa at $103050.000 and
the least is for Po at $87000.000
*/

/* #3 */
title "SalePrice with Season_Sold";
proc sgplot data=team4;
vline Season_Sold /group =Season_Sold
					stat=mean
					response=SalePrice
					markers;
				
run;
/*The mean SalePrice was highest in season 1($140570) and the least on season 4($139400), 
season 2 and 3 had relatively higher but similar mean SalePrice at $140200.*/

title "SalePrice with Heating_QC";
proc sgplot data=team4;
vline Heating_QC /group =Heating_QC
					stat=mean
					response=SalePrice
					markers;
run;
/* Mean sale prices was highest when Heating_QC was Ex-Excellent then for GD-Good followed by TA-Typical/Average 
and then Fa-Fair. Po-Poor has the least mean SalePrice*/

title "Plot: SalePrice with Heating_QC and Season_Sold";
proc sgplot data=team4;
vline Season_Sold / group=Heating_QC
				stat= mean
				response= SalePrice
				markers;
run;
/* From the graph, we can observe that houses with Excellent heating quality and condition had the highest mean Sale Price followed by
Good quality houses which were behind Typical/Average only in the first season. After T/A quality houses we have the Fa-Fair and 
Po-Poor quality houses at the bottom.
*/
ods graphics on;
title "2-Way Anova: SalePrice with Heating_QC and Season_Sold";
proc glm data=team4 order=internal;
class Season_Sold Heating_QC;
model SalePrice = Heating_QC Season_Sold;
lsmeans Season_Sold ;
run;
ods graphics off;
/*R-square (0.162705) explains 16.2% variablility in SalePrice by the 2 variables.
p-value(0.9382) does suggests that there is not significant difference across season sold.
But there a significant difference across Heating_QC.*/
ods graphics on;
title "Model 2";
proc glm data=projlib.team4 order=internal plots(only)=intplot;
	class  Season_sold Heating_QC;
	store out=newdata;
	model SalePrice = Heating_QC Season_sold Heating_QC*Season_Sold;
	lsmeans Heating_QC*Season_Sold / slice= Heating_QC; 
run;
ods graphics off;
/* The p-value(0.3216) has decreased but it still isnt significant.
Let's use Proc plm to interact with different Heating_QC and Seasons.*/
ods graphics on;
proc plm restore=newdata plots=all;
slice Heating_QC*Season_Sold /sliceby=Heating_QC;
effectplot interaction(sliceby=Heating_QC)/clm;
run;
ods graphics off;

/* The plot suggests that houses with Excellent heating quality have significant difference between 2 seasons.Rest do not signify a significant difference*/
