<FIELDSET STYLE="padding:5px; width: 1%; border: 1px solid Silver;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Selected options</LEGEND>


<TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" WIDTH="510">
<CFOUTPUT>
<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP>Rule Name:</TD>
	<TD BGCOLOR="Orange" ROWSPAN="10"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD>
	<TD WIDTH="100%">#form.rulename#</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP>Products:</TD>
	<TD>
		<!--- Create query to retrieve the product names --->
		<CFQUERY NAME="Get_Products" datasource="#application.datasource#">
		Select	Description from BSA_Foodservice_Items_Master where item  in (#listqualifY(form.Products, "'")#)
		</CFQUERY>
		<CFLOOP QUERY="Get_Products">
			#Description#<BR>
		</CFLOOP>
	</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP>Exchange:</TD>
	<TD>
		<!--- Create query to retrieve the name of the exchange --->
		<cfset useLakebaseForGet_Exchange = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("commodities_exchange_detail")>
<cfif useLakebaseForGet_Exchange>
	<cftry>
		<cfset Get_Exchange = application.oLakebase.toQuery(
			application.oLakebase.selectRows("commodities_exchange_detail", {
				"exchange_detail_id" = "eq.#Form.Exchange#",
				"select" = "exchange_detail_name"
			}), "exchange_detail_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Exchange = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Exchange>
<CFQUERY NAME="Get_Exchange" datasource="#application.datasource#">
		Select	Exchange_Detail_Name from Commodities_Exchange_Detail where Exchange_Detail_ID	=	'#Form.Exchange#'
		</CFQUERY>
</cfif>
		#Get_Exchange.Exchange_Detail_Name#
	</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP>Commodity:</TD>
	<TD>
		<!--- Create query to retrieve the name of the commodity --->
		<cfset useLakebaseForGet_Commodity = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("commodities_symbol")>
<cfif useLakebaseForGet_Commodity>
	<cftry>
		<cfset Get_Commodity = application.oLakebase.toQuery(
			application.oLakebase.selectRows("commodities_symbol", {
				"symbol" = "eq.#Form.Commodity#",
				"select" = "symbol_description"
			}), "symbol_description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Commodity = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Commodity>
<CFQUERY NAME="Get_Commodity" datasource="#application.datasource#">
		Select Symbol_Description from Commodities_Symbol where Symbol	=	'#Form.Commodity#'
		</CFQUERY>
</cfif>
		#Get_Commodity.Symbol_Description#
	</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP>Sample size:</TD>
	<TD>#form.sample_size# #form.Time_UOM_sample_size#</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP>Sample Time Lag:</TD>
	<TD>#point_in_time# #form.Time_UOM_point_in_time#</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP>Calculation Method:</TD>
	<TD>#form.Calc_Process# of sampled data</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP></TD>
	<TD></TD>
</TR>
</TABLE>
</CFOUTPUT>


<TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" WIDTH="510">
<TR>
	<TD WIDTH="100%">Base Value: $<SPAN id="seedText">Not Loaded</SPAN></TD>
	<TD NOWRAP>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<FONT COLOR="Red" SIZE="3"><B>[</B></FONT>
			<A HREF="javascript:history.back();">
				<FONT SIZE="3">
					<B>
					click here to revise these values
					</B>
				</FONT>
			</A>
		<FONT COLOR="Red" SIZE="3"><B>]</B></FONT>
	</TD>
</TR>
</TABLE>


</FIELDSET>

