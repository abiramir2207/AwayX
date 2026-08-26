
<style>
	.header
	{
		background-color:gray;
		color: white;
		font-size:12;
		font-weight:bold;
	}
	
	.claimHeader
	{
		color: black;
		font-size:11px;
		font-weight:bold;
		border-bottom:dashed #000000 1px; 
	}
	
	.claim
	{
		color: black;
		font-size:10px;
	}
	
	.claimTotal
	{
		color: blue;
		font-size:12px;
	}
	.title
	{
		color: navy;
		font-size:14;
		font-weight:bold;
	}
	
	.label
	{
		color: black;
		font-size:12;
		font-weight:bold;
	}
	.labelWithNoBold
	{
		color: black;
		font-size:12;
	}
</style> 

<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<!--- the program has been set from claimDetail --->
<body>

<cfif not isDefined("useExistingClaimHandle")>
	<CFSET claimHandle = CreateObject("component", "components.reports.claim").init(billback_id,program_id,this_end_user)>
</cfif>

<cfloop from="1" to="4" index="i">
	<cfset "MailToLine#i#" = "">
</cfloop>

<!--- split mail to information into lines --->
<cfif isTextFormat NEQ false >
	<cfset MailToLen = ListLen(claimHandle.getClaimMailTo(),"#chr(13)##chr(10)#") >
	<cfset mailToCount = 1 >
	<cfif isTextFormat NEQ false and MailToLen GE 1 >
		<cfloop list="#claimHandle.getClaimMailTo()#" index="thisItem" delimiters="#chr(13)##chr(10)#">
			<cfset "MailToLine#mailToCount#" = thisItem >
			<cfset mailToCount = mailToCount + 1 >
		</cfloop>
	</cfif>
</cfif>
	<!---<div align="center"> ---------------------------CREDIT MEMO-------------------- </div>--->
	<!---<cfset abc = "LABATT FOOD SERVICE#chr(13)##chr(10)#PO BOX 2140#chr(13)##chr(10)#San Antonio, TX 78297">--->
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td valign="top" class="label" width="20%" nowrap>
				<div style="margin-left:0cm">
					<cfif isTextFormat EQ false >
						<cfoutput>Mail To:</cfoutput>
					<cfelse>
						<cfoutput>#claimHandle.TextAlignLeft(10,"Mail To")#</cfoutput>
						<cfif isDefined("MailToLine1")>
							<cfoutput>#claimHandle.TextAlignLeft(40,"#MailToLine1#")#</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(41,' ')#</cfoutput>
						</cfif>
					</cfif>
				</div> 
				<textarea id="mailtoTextArea" name="mailtoTextArea" value="#claimHandle.getClaimMailTo()#" cols="40" rows="8"><cfif isTextFormat EQ false ><cfoutput>#trim(claimHandle.getClaimMailTo())#</cfoutput></cfif></textarea>
			</td>
			<td width="30%"><cfif isTextFormat EQ false >&nbsp;</cfif></td>
			<td width="50%">
				<table cellpadding="1" width="80%" border="1">
					<tr>
						<td align="right" class="label" width="65%"><cfif isTextFormat EQ false >Voucher#:<cfelse><cfoutput>#claimHandle.TextAlignRight(50,"Voucher No:|")#</cfoutput></cfif></td> 
						<td align="right" width="35%"><cfif isTextFormat EQ false><!---go to 800 log table to get Voucher Number---><cfelse><cfoutput><!---go to 800 log table to get Voucher Number---></cfoutput></cfif></td>
					</tr>
					<!--- second line for text ---->
					<cfif isTextFormat NEQ false >
						<cfoutput>#NewLine#</cfoutput>
						<cfoutput>#claimHandle.TextAlignLeft(11,' ')#</cfoutput>
						<cfif isDefined("MailToLine2")>
							<cfoutput>#claimHandle.TextAlignLeft(40,"#MailToLine2#")#</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(41,' ')#</cfoutput>
						</cfif>
					</cfif>
					<tr>
						<td align="right" class="label" width="65%"><cfif isTextFormat EQ false >Billback Number:<cfelse><cfoutput>#claimHandle.TextAlignRight(50,"Billback Number:|")#</cfoutput></cfif> </td> 
						<td align="right" width="35%"><cfif isTextFormat EQ false ><cfoutput>#claimHandle.getClaimReferenceNo()#</cfoutput><cfelse><cfoutput> #claimHandle.getClaimReferenceNo()#</cfoutput></cfif></td> 
					</tr>
					
					<!--- third line for text --->
					<cfif isTextFormat NEQ false >
						<cfoutput>#NewLine#</cfoutput>
						<cfoutput>#claimHandle.TextAlignLeft(11,' ')#</cfoutput>
						<cfif isDefined("MailToLine3")>
							<cfoutput>#claimHandle.TextAlignLeft(40,"#MailToLine3#")#</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(41,' ')#</cfoutput>
						</cfif>
					</cfif>
					
					<tr>
						<td align="right" class="label" width="65%"><cfif isTextFormat EQ false >Reference Number:<cfelse><cfoutput>#claimHandle.TextAlignRight(50,"Reference Number:|")#</cfoutput></cfif> </td> 
						<td align="right" width="35%"><cfif isTextFormat EQ false ><cfoutput>#claimHandle.getClaimReferenceNo2()#</cfoutput><cfelse><cfoutput> #claimHandle.getClaimReferenceNo2()#</cfoutput></cfif></td> 
					</tr>

					<!--- fourth line for text --->
					<cfif isTextFormat NEQ false >
						<cfoutput>#NewLine#</cfoutput>
						<cfoutput>#claimHandle.TextAlignLeft(11,' ')#</cfoutput>
						<cfif isDefined("MailToLine4")>
							<cfoutput>#claimHandle.TextAlignLeft(40,"#MailToLine4#")#</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(41,' ')#</cfoutput>
						</cfif>
					</cfif>

					<!--- for forge billback number --->
					<tr>
						<td align="right" class="label" width="65%" nowrap><cfif isTextFormat EQ false >Claim No:<cfelse><cfoutput>#claimHandle.TextAlignRight(50,"Claim No:|")#</cfoutput></cfif> </td> 
						<td align="right" width="35%" nowrap><cfif isTextFormat EQ false ><cfoutput>#claimHandle.getClaimNo()#</cfoutput><cfelse><cfoutput> #claimHandle.getClaimNo()#</cfoutput></cfif></td> 
					</tr>
					<cfif isTextFormat NEQ false >
						<cfoutput>#NewLine#</cfoutput>
					</cfif>
					<tr>
						<td align="right" class="label" width="65%">
							<cfif isTextFormat EQ false >
								<cfoutput>POD Period From: #DateFormat(claimHandle.getClaimPODStart(), "mm-dd-yyyy")# To:</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignRight(100,"POD Period From: #DateFormat(claimHandle.getClaimPODStart(), "mm-dd-yyyy")# To:|")#</cfoutput>
							</cfif>
						</td> 
						<td align="right" width="35%">
							<cfif isTextFormat EQ false >
								<cfoutput>#DateFormat(claimHandle.getClaimPODEnd(), "mm-dd-yyyy")#</cfoutput>
							<cfelse>
								<cfoutput> #DateFormat(claimHandle.getClaimPODEnd(), "mm-dd-yyyy")#</cfoutput>
							</cfif>
						</td> 
					</tr>
					<tr>
						<td align="right" class="label" width="65%">
							<cfif isTextFormat EQ false >
								<cfoutput>AR##:</cfoutput>
							</cfif>
						</td> 
						<td align="right" width="35%">
							<cfif isTextFormat EQ false >
								<cfoutput>#claimHandle.getClaimAR()#</cfoutput>
							</cfif>
						</td> 
					</tr>
					<!---- fourth line ---->
					<cfif isTextFormat NEQ false >
						<cfoutput>#NewLine#</cfoutput>
						<cfoutput>#claimHandle.TextAlignLeft(11,' ')#</cfoutput>
						<cfoutput>#claimHandle.TextAlignLeft(41,' ')#</cfoutput>
					</cfif>
					<tr>
						<td align="right" class="label" width="65%"><cfif isTextFormat EQ false >Postmark Date:<cfelse><cfoutput>#claimHandle.TextAlignRight(50,"Postmark Date:|")#</cfoutput></cfif></td> 
						<td align="right" width="35%"><cfif isTextFormat EQ false ><cfoutput>#DateFormat(claimHandle.getClaimPostMarkDate(), "mm-dd-yyyy")#</cfoutput><cfelse><cfoutput> #DateFormat(claimHandle.getClaimPostMarkDate(), "mm-dd-yyyy")#</cfoutput></cfif></td> 
					</tr>
					<!---- fifth line ---->
					<cfif isTextFormat NEQ false >
						<cfoutput>#NewLine#</cfoutput>
						<cfoutput>#claimHandle.TextAlignLeft(11,' ')#</cfoutput>
						<cfoutput>#claimHandle.TextAlignLeft(41,' ')#</cfoutput>
					</cfif>
					<tr>
						<td align="right" class="label" width="65%"><cfif isTextFormat EQ false >Receipt Date:<cfelse><cfoutput>#claimHandle.TextAlignRight(50,"Receipt Date:|")#</cfoutput></cfif></td> 
						<td align="right" width="35%"><cfif isTextFormat EQ false ><cfoutput>#DateFormat(claimHandle.getClaimReceiptDate(), "mm-dd-yyyy")#</cfoutput><cfelse><cfoutput> #DateFormat(claimHandle.getClaimReceiptDate(), "mm-dd-yyyy")#</cfoutput></cfif></td> 
					</tr>
					<!--- sixth and seven line --->
					<cfif isTextFormat NEQ false >
						<cfoutput>#NewLine##NewLine#</cfoutput>
						<cfoutput>#claimHandle.TextAlignLeft(11,' ')#</cfoutput>
						<cfoutput>#claimHandle.TextAlignLeft(41,' ')#</cfoutput>
					</cfif>
					<tr>
						<td align="right" class="label" width="65%"><cfif isTextFormat EQ false >Entry Date:<cfelse><cfoutput>#claimHandle.TextAlignRight(50,"Entry Date:|")#</cfoutput></cfif></td> 
						<td align="right" width="35%"><cfif isTextFormat EQ false ><cfoutput>#DateFormat(claimHandle.getClaimEntryDate(), "mm-dd-yyyy")#</cfoutput><cfelse><cfoutput> #DateFormat(claimHandle.getClaimEntryDate(), "mm-dd-yyyy")#</cfoutput></cfif></td> 
					</tr>
					<!--- eighth line for text--->
					<cfif isTextFormat NEQ false >
						<cfoutput>#NewLine#</cfoutput>
						<cfoutput>#claimHandle.TextAlignLeft(11,' ')#</cfoutput>
						<cfoutput>#claimHandle.TextAlignLeft(41,' ')#</cfoutput>
					</cfif>
					<tr>
						<td align="right" class="label" width="65%"><cfif isTextFormat EQ false >Trs Date:<cfelse><cfoutput>#claimHandle.TextAlignRight(50,"Trs Date:|")#</cfoutput></cfif></td> 
						<td align="right" width="35%"><cfif isTextFormat EQ false ><cfoutput>#DateFormat(claimHandle.getClaimTransDate(), "mm-dd-yyyy")#</cfoutput><cfelse><cfoutput> #DateFormat(claimHandle.getClaimTransDate(), "mm-dd-yyyy")#</cfoutput></cfif></td> 
					</tr>
				</table>
			</td>
		</tr>
		<tr><td>&nbsp;</td></tr>
		<!----ninth and tenth line for text---->
		<cfif isTextFormat NEQ false >
			<cfoutput>#NewLine##NewLine#</cfoutput>
		</cfif>
		<tr>
			<td nowrap colspan="2">
				<table cellpadding="1" cellspacing="1" width="100%">
					<tr>
						<td align="left" class="label" width="255" nowrap><cfif isTextFormat EQ false >Region:<cfelse><cfoutput>#claimHandle.TextAlignLeft(10,"Region:")#</cfoutput></cfif><cfif isTextFormat EQ false ><font color="gray">&nbsp;<cfoutput>#claimHandle.getClaimRegion()#</cfoutput></font><cfelse><cfoutput>#claimHandle.TextAlignLeft(40,"#trim(claimHandle.getClaimRegion())#")#</cfoutput></cfif></td>
						<td align="left" class="label" nowrap><cfif isTextFormat EQ false ><cfoutput>#application.returned_customer_setting.market_label_singular#:</cfoutput><cfelse><cfoutput>#claimHandle.TextAlignLeft(10,"#application.returned_customer_setting.market_label_singular#:")#</cfoutput></cfif><cfif isTextFormat EQ false ><font color="navy">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput>#trim(claimHandle.getClaimMarket())#</cfoutput></font><cfelse><cfoutput>#claimHandle.TextAlignLeft(10,"#trim(claimHandle.getClaimMarket())#")#</cfoutput></cfif></td>
					</tr>
				</table>
			</td>
			<td width="50%">
				<table cellpadding="1" width="80%" border="1">
					<tr>
						<td align="right" class="label" width="65%"><cfif isTextFormat EQ false >UserID:<cfelse><cfoutput>#claimHandle.TextAlignRight(30,"UserID:|")#</cfoutput></cfif></td>
						<td align="right" class="label" width="35%"><cfif isTextFormat EQ false ><cfoutput>#claimHandle.getClaimApprovedUserID()#</cfoutput><cfelse><cfoutput> #claimHandle.TextAlignLeft(20,claimHandle.getClaimApprovedUserID())#</cfoutput></cfif></td>
					</tr>
				</table>
			</td>
		</tr>
		<!--- line of eleventh for text --->
		<cfif isTextFormat NEQ false >
			<cfoutput>#NewLine#</cfoutput>
		</cfif>
		<tr>
			<td nowrap colspan="2" width="100%">
				<table cellpadding="1" cellspacing="1" width="100%">
				  <!--DWLayoutTable-->
					<tr>
						<td nowrap class="label" align="left"><cfif isTextFormat EQ false >Template Name:<cfelse><cfoutput>#claimHandle.TextAlignLeft(15,"Template Name:")#</cfoutput></cfif><cfif isTextFormat EQ false ><font color="gray">&nbsp;<cfoutput>#claimHandle.getClaimTemplateName()#</cfoutput></font><cfelse><cfoutput>#claimHandle.TextAlignLeft(40,"#trim(claimHandle.getClaimTemplateName())#")#</cfoutput></cfif></td>
					</tr>
					<cfif isTextFormat NEQ false >
						<cfoutput>#NewLine#</cfoutput>
					</cfif> 
				</table>
			</td>
			<td width="50%">&nbsp;</td>
		</tr>
		<tr><td>&nbsp;</td></tr>
		<!--- new line for text --->
		<cfif isTextFormat NEQ false >
			<cfoutput>#NewLine##NewLine#</cfoutput>
		</cfif>
		<tr>
			<td colspan="2" class="label"><cfif isTextFormat EQ false >Comments:<cfelse><cfoutput>#claimHandle.TextAlignLeft(10,"Comments:")#</cfoutput></cfif></td>
		</tr>
		<cfif isTextFormat NEQ false >
			<cfoutput>#NewLine#</cfoutput>
		</cfif>
		<cfset comments = #claimHandle.getClaimNote()#>
		<cfloop from="1" to="#ArrayLen(comments)#" step="1" index="i">
			<tr>
				<td nowrap><cfoutput>#i#-    #comments[i]#</cfoutput></td>
			</tr>
			<cfif isTextFormat NEQ false >
				<cfoutput>#NewLine#</cfoutput>
			</cfif>
		</cfloop>
	</table>
	<cfif isTextFormat NEQ false >
		<cfoutput>#NewLine#</cfoutput>
	</cfif>
	<!----- comments ---->
</body>
</html>
