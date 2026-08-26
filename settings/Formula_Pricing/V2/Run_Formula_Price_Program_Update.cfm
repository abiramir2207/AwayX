 
<!--- 
Run_Formula_Price_Update.cfm

INCLUDED FROM  getUSDACommodityPrices.cfm 

--->
<cfscript>
  today = NOW();
</cfscript>
<cfparam name="URL.runFPPU" 			default="0" />
<cfparam name="form.runFPPU" 			default="#URL.runFPPU#" />
<cfparam name="form.Process_Date" 		default="#today#" />
<cfparam name="form.Process_End_Date" 		default="#today#" />

 
 <!--- ------------------ Manually RUN Formula_Price_Program_Update SP (Scheduled Job) --->
<FIELDSET STYLE="padding:5px; width: 750px; border: 1px solid Silver;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Manually Process Formula Programs</LEGEND>
  <FORM ACTION="getUSDACommodityPrices.cfm" METHOD="post" NAME="frmFPPU" ID="frmFPPU">
 	<table width="600" border="0" cellspacing="5" cellpadding="0">
    <tr>
        <td width="75">Process Start Date: 
        </td>
        <td width="20" align="left"><CF_EASYDATE 
					FORMNAME="frmFPPU" 
					FIELDNAME="Process_Date" 
					FORMAT="mm/dd/yyyy" 
					DEFAULT="#form.Process_Date#">
        </td>
        <td>
        </td>
    </tr>
	 <tr>
        <td width="75">Process End Date: 
        </td>
        <td width="20" align="left"><CF_EASYDATE 
					FORMNAME="frmFPPU" 
					FIELDNAME="Process_End_Date" 
					FORMAT="mm/dd/yyyy" 
					DEFAULT="#form.Process_End_Date#">
        </td>
        <td>
        </td>
    </tr>
    <tr>
        <td>
 			
        </td>
		 <td>
		 	<button type="submit" name="runFPPU" value="1" >run formula price program update process</button>
        </td>
		 <td>
        </td>
    </tr>
</table>
 </Form>
 </Fieldset>
 	<br>
	<br> 
 <!--- ------------------ END RUN Formula_Price_Program_Update SP (Scheduled Job) --->

<cfif Form.runFPPU EQ 1 AND isDate(form.Process_Date) AND datediff("d", form.Process_Date,DateFormat(now(),"mm/dd/yyyy")) gte 0 >
	<cfscript>
		if(form.Process_Date != form.Process_End_Date && datediff("d", form.Process_Date,form.Process_End_Date) > 0){
			sd = form.Process_Date;
			ed = form.Process_End_Date;
			arr = arrayNew(1);
			while (datediff("d", sd,ed) >= 0) {
				arrayAppend(arr,DateFormat(sd,"mm/dd/yyyy"));
				sd = dateAdd("d",1,sd);
			}
		}else{
			sd = form.Process_Date;
			arr = [sd];
		}
		FOR (idate=1;idate LTE ArrayLen(arr);idate=idate+1) {
		//	writeoutput('#form.Process_Date# <br>');
			Process_Datetime = arr[idate];
			 spService = new storedproc(); 
		    //set attributes using implicit setters 
		    spService.setDatasource("#application.datasource#"); 

		    if(appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 1 AND appSettings.get_Setting('Custom_RFP_Process',0) EQ 0){
		    	spService.setProcedure("Formula_Price_Item_Program_Update"); 
		    }
		    else if(appSettings.get_Setting('Custom_RFP_Process',0) EQ 0){
		   	 	spService.setProcedure("Formula_Price_Program_Update"); 
			}
			else{
				spService.setProcedure("Formula_Price_RFP_Program_Update");
			}
		    //add procparams using addParam 
		  	spService.addParam(cfsqltype="CF_SQL_DATE", type="in",value= Process_Datetime, dbVarName = "@Process_Date" );
		    //execute the stored procedure 
		    result = spService.execute();
		    writeoutput('#Process_Datetime#<br>');
		}
			
	</cfscript>
<!---	<cfstoredproc procedure="Formula_Price_Program_Update" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_DATE" dbVarName = "@Process_Date" value = "#form.Process_Date#" null="no">
	</cfstoredproc>--->
	<cfoutput>
		Formula_Price_Program_Update RUN for: #form.Process_Date# <br>
		Run on : #now()#
	</cfoutput>
</cfif>

 