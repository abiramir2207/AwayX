

<!--- 
calculateFormulaPrices.cfm
Mark S :: 12/5/2016
Calculate Formula Prices
* Find all programs with a Fixed Formual Components.
* Verify the Schedule Options
* Revices appropriate programs and run the Formula Calculation logic
 --->
<cfscript>
 d = DateFormat(DateAdd('d', -1, now()),'mm/dd/yyyy');
</cfscript>

<cfparam name="form.calcFormula" 			default="0" />

<cfoutput>
	<cfscript>
 	//	WriteOutput(isDate(form.Start_Date)& ' :x: ' & form.process & ' :xx: ' &  datediff("d", form.Start_Date,DateFormat(now(),"mm/dd/yyyy"))  & '   <br>  ');
 	Formula	= createObject("component","mvc.Models.Program.Component.Formula");
	
</cfscript>
 
<FORM ACTION="getUSDACommodityPrices.cfm" METHOD="post" NAME="frm_Calc_Formula" ID="frm_Calc_Formula">
 	<table width="600" border="0" cellspacing="5" cellpadding="0">
    <tr>
        <td width="65">
        </td>
        <td width="100">
        </td>
        <td>
        </td>
    </tr>
    <tr>
        <td>
        </td>
        <td>
        </td>
        <td>
        </td>
    </tr>
    <tr>
        <td>
        </td>
        <td>
        </td>
        <td><button type="submit" name="calcFormula" value="1" >calculate program formula prices</button>
        </td>
    </tr>
</table>
	<br>
	<br> 
 </Form>
 
 
</cfoutput>

 	<cfscript>
	 //	WriteOutput(isDate(form.Start_Date)& ' :x: ' & form.process & ' :xx: ' &  datediff("d", form.Start_Date,DateFormat(now(),"mm/dd/yyyy"))  & '   <br>  ');
	 	CommodityPrices	= createObject("component","mvc.Models.Admin.Commodity.CommodityPrices");
	 	// DO SOME CLEANUP
	 	CommodityPrices.cleanDeletedData();
	 	//Process Commodity Data
	 	if(form.calcFormula == 1){
			
			writeoutput('Calc Formula!');
		}// If Form
	</cfscript>