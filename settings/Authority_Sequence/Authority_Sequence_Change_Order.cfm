<!------ Authority_Sequence_Change_Order.cfm ----->
<cfoutput>

<cfset qAuthoritySequence = authoritySequenceManager.getAll()>

<cfif form.command EQ "changeOrder2">

	<cftransaction action="BEGIN">
	
		<cftry>
		
			<cfloop query="qAuthoritySequence">
			
				<cfset New_Authority_Sequence_Order = Evaluate("FORM.Authority_Sequence_Order_#Authority_Sequence_ID#") />
				<cfif New_Authority_Sequence_Order NEQ Authority_Sequence_Order>
					<cfset sMsg = authoritySequenceManager.editSequenceOrder(Authority_Sequence_ID, New_Authority_Sequence_Order, Request.AccessStructure)>
				</cfif>
			
			</cfloop>
			
			<cfset removeHQPositions = authoritySequenceManager.removeHQPositions()>
			
			<cftransaction action="COMMIT">
			
			<cfcatch>
			
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			
			</cfcatch>
			
		</cftry>
		
	</cftransaction>

</cfif>


<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<script language="JavaScript">
var maxCount = #qAuthoritySequence.recordCount#;
var asIdList = "#ValueList(qAuthoritySequence.Authority_Sequence_ID)#";

function changeOrderValidate(oForm)
{
	
	var thisRowError, errCount, i, oOrder, oName, sOrder, sName, oOrderErr, oNameErr;
	var nameProper, orderProper;
	
	//queueMessage("Order should be a valid numeric value", oOrderErr);
	//clearQueue(oOrderErr);
	
	var i, arVals = new Array();	
	for(i=1;i<=maxCount;i++)
	{
		arVals[i] = "";
	}
	
	var arAsIdList = asIdList.split(",");
	var arAsIdListLen = arAsIdList.length;
	
	var thisRowError, sOrder, oOrder, oOrderError;
	
	for(i=0;i<arAsIdListLen;i++)
	{
		thisRowError = 0;
		
		oOrder = eval("oForm.Authority_Sequence_Order_" + arAsIdList[i]);
		oOrderErr = eval("document.all.sp_err_order_" + arAsIdList[i]);
		
		sOrder = parseFloat(oOrder.value);
		orderProper = !isNaN(sOrder);
		if(!orderProper)
		{
			thisRowError++;
			queueMessage("Order should be a valid numeric value", oOrderErr);
		}
		else
		{						
			clearQueue(oOrderErr);
		}
		
		if(orderProper)
		{
		 	if(sOrder <= maxCount && sOrder >= 1)
			{
				if(arVals[sOrder] != "")
				{
					thisRowError++;
					queueMessage("Order should be in sequence, Order cannot be repeated, Order should start at 1", oOrderErr);
				}
				else
				{
					arVals[sOrder] = arAsIdList[i];
				}
			}
			else
			{
				thisRowError++;
				queueMessage("Order should start at 1 and end at " + maxCount, oOrderErr);
			}
		}
		errCount+=thisRowError;
	}
	
	if(!errCount)
	{
		var iBreak = 0;
		for(i=1;i<=maxCount;i++)
		{
			if(iBreak)
			{
				if(arVals[i] != "")
				{
					oOrderErr = eval("document.all.sp_err_order_" + arVals[i]);
					queueMessage("Order should be in sequence, Order cannot be repeated, Order should start at 1", oOrderErr);
					errCount++;
					break;
				}
			}					
			else if(arVals[i] == "")
			{
				iBreak = 1;
				oOrderErr = document.all.sp_err_order_Common;
				queueMessage("Order should be in sequence, Order cannot be repeated, Order should start at 1", oOrderErr);
				errCount++;
				break;

			}					
		}
	}
	
	return errCount;
	
	
}
</script>


<table cellpadding="2" cellspacing="1" width="50%" align="center" bgcolor="##cccccc">
	<tr bgcolor="white">		
		<td><B>Order</B></td>
		<td><B>Authority Name</B></td>		
	</tr>
	<cfset qAuthoritySequence = authoritySequenceManager.getAll()>
	<cfloop query="qAuthoritySequence">
	<tr bgcolor="white">
		<td>
		#Authority_Sequence_Order#
		<font face="Courier New">&nbsp;&nbsp; -> &nbsp;&nbsp;</font>
		<input type="Text" name="Authority_Sequence_Order_#Authority_Sequence_ID#" value="#Authority_Sequence_Order#" size="3">
		<span id="sp_err_order_#Authority_Sequence_ID#">&nbsp;</span>
		</td>		
		<td>#Authority_Sequence_Name#&nbsp;</span>
		</td>
	</tr>
	</cfloop>	
</table>

<div align="center">
<span id="sp_err_order_Common">&nbsp;</span>&nbsp;&nbsp;&nbsp;
<CF_smallLink 
	title = "save" 
	url = "##"
	parameters = "onClick=""javascript: return submitForm('#formName#', 'changeOrder2');"""
>
&nbsp;&nbsp;&nbsp;
<CF_smallLink 
	title = "cancel" 
	url = "index.cfm?command=list"
>
</div>

</cfoutput>