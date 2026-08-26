<cfsetting enableCFoutputOnly = "Yes">
<!------Graph_Full.cfm----->
<CFPARAM NAME="Attributes.THIS_BILLBACK" 	DEFAULT=0>
<CFPARAM NAME="Attributes.This_Billback_Intervals" 	DEFAULT="">
<CFPARAM NAME="Attributes.A_IMG" 	DEFAULT="">
<CFPARAM NAME="Attributes.B_IMG" 	DEFAULT="">
<CFPARAM NAME="Attributes.A_CLASS" 	DEFAULT="">
<CFPARAM NAME="Attributes.B_CLASS" 	DEFAULT="">
<CFPARAM NAME="Attributes.sDesc" 	DEFAULT="">
<CFPARAM NAME="Attributes.Empty_Image_len" 	DEFAULT=0>
<CFPARAM NAME="Attributes.Max_Length" 	DEFAULT=0>
<CFPARAM NAME="Attributes.Total_date_Span" 	DEFAULT=1>
<CFPARAM NAME="Attributes.thisItem" 	DEFAULT="">
<CFPARAM NAME="Attributes.START_DATE" 	DEFAULT="#Now()#">
<CFPARAM NAME="Attributes.END_DATE" 	DEFAULT="#Now()#">
<CFPARAM NAME="Attributes.GRAPH_SPAN_CLASS" 	DEFAULT="">

<CFSET Empty_Image_len = Attributes.Empty_Image_len>
<CFSET Max_Length = Attributes.Max_Length>
<CFSET Total_date_Span=Attributes.Total_date_Span>
<CFSET thisItem=Attributes.thisItem>
<CFSET START_DATE=Attributes.START_DATE>
<CFSET END_DATE=Attributes.END_DATE>
<CFSET ADDSCRIPT=Caller.ADDSCRIPT>
<CFSET GRAPH_SPAN_CLASS=Attributes.GRAPH_SPAN_CLASS>
<CFSET DATE_GRAPH_HEIGHT=Caller.DATE_GRAPH_HEIGHT>

<CFIF ADDSCRIPT EQ "Yes">
	<CFSET DIV_DISPLAY = "NONE">
	<CFSET DIV_POSITION = "ABSOLUTE">
<CFELSE>
	<CFSET DIV_DISPLAY = "INLINE">
	<CFSET DIV_POSITION = "RELATIVE">
</CFIF>
<cfset This_Item_Date_Span = 0 />
<cfif (Start_Date NEQ "" and End_Date NEQ "")>
	<CFSET This_Item_Date_Span=DateDiff("d", Start_Date, End_Date) + 1>
</cfif>
<CFSET Bar_Image_len=(This_Item_Date_Span * Max_Length)/Total_date_Span>

<CFOUTPUT><TR><TD NOWRAP ALIGN="LEFT"></CFOUTPUT>
<CFOUTPUT><TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" STYLE="border-collapse: collapse"><TR></CFOUTPUT>
		<CFIF Empty_Image_len GT 0>						
			<CFIF Caller.USEIMGGRAPH>
				<CFOUTPUT><TD><IMG SRC="/Images/fill.gif" HEIGHT="#DATE_GRAPH_HEIGHT#" WIDTH="#Empty_Image_len#" BORDER="0"></TD></CFOUTPUT>
			<CFELSE>
				<!------<CFOUTPUT><SPAN CLASS="GRAPHSPAN_FILL" STYLE="WIDTH:#Empty_Image_len#px"></SPAN></CFOUTPUT>----->
				<!------<CFOUTPUT><TD CLASS="GRAPHSPAN_FILL" STYLE="WIDTH:#Attributes.WIDTH#px"></TD></CFOUTPUT>----->
				<CFOUTPUT><TD CLASS="GRAPHSPAN_FILL" STYLE="WIDTH:#Empty_Image_len#px"></TD></CFOUTPUT>
			</CFIF>
		</CFIF>
					
<CFIF Attributes.THIS_BILLBACK EQ 1>
	<CFSET Counter_2=1>						
	<CFLOOP LIST="#Attributes.This_Billback_Intervals#" DELIMITERS="," INDEX="Show_This_Date">
		<CFIF ListLast(Show_This_Date, "~") EQ "A">
			<CFSET Image_Name=Attributes.A_IMG>
			<CFSET GRAPH_SPAN_CLASS=Attributes.A_CLASS>
		<CFELSE>
			<CFSET Image_Name=Attributes.B_IMG>
			<CFSET GRAPH_SPAN_CLASS=Attributes.B_CLASS>
		</CFIF>
		<CFSET This_Item_Date_Span=DateDiff("d", ListFirst(Show_This_Date, "~"), ListGetAt(Show_This_Date, 2, "~")) + 1>
		<CFSET Bar_Image_len=(This_Item_Date_Span * Max_Length)/Total_date_Span>
		<CFOUTPUT><TD CLASS="#GRAPH_SPAN_CLASS#" WIDTH="#Bar_Image_len#" ID="Bar_Images_#thisItem#_#Counter_2#"></TD></CFOUTPUT>
		<CFSET Counter_2=Counter_2+1>
	</CFLOOP>
	<CFIF ListLen(Attributes.This_Billback_Intervals, ",") GT 0>
		<CFSAVECONTENT VARIABLE="Graph_Legend1">
		<CFOUTPUT><DIV STYLE="POSITION:#DIV_POSITION#;DISPLAY:#DIV_DISPLAY#" ID="DIV_#thisItem#_Start">#DateFormat(Start_Date, "mm/dd/yy")#</DIV></CFOUTPUT>
		</CFSAVECONTENT>
		<CFSAVECONTENT VARIABLE="Graph_Legend2">
		<CFSET This_Item_Date_Span=DateDiff("d", Start_Date, End_Date) + 1>							
		<CFOUTPUT><DIV STYLE="POSITION:#DIV_POSITION#;DISPLAY:#DIV_DISPLAY#" ID="DIV_#thisItem#_Desc"><font color="aaaaaa">&nbsp;#Attributes.sDesc#&nbsp;</font></DIV></CFOUTPUT>
		</CFSAVECONTENT>
		<CFSAVECONTENT VARIABLE="Graph_Legend3">
		<CFOUTPUT><DIV STYLE="POSITION:#DIV_POSITION#;DISPLAY:#DIV_DISPLAY#" ID="DIV_#thisItem#_End">#DateFormat(End_Date, "mm/dd/yy")# (#This_Item_Date_Span# days)</DIV></CFOUTPUT>
		</CFSAVECONTENT>
		<CFSAVECONTENT VARIABLE="Graph_Legend_Script">
		<CFOUTPUT><CFSET BB=Caller.addThisDateToDisplay("Bar_Images_#thisItem#_1", "Bar_Images_#thisItem#_#ListLen(Attributes.This_Billback_Intervals, ",")#" , "DIV_#thisItem#_Start", "DIV_#thisItem#_End", "DIV_#thisItem#_Desc")></CFOUTPUT>
		</CFSAVECONTENT>
	</CFIF>	
<CFELSE>
	<CFOUTPUT><TD CLASS="#GRAPH_SPAN_CLASS#" WIDTH="#Bar_Image_len#" ID="Bar_Images_#thisItem#"></TD></CFOUTPUT>
	<CFSAVECONTENT VARIABLE="Graph_Legend1">
	<CFOUTPUT><DIV STYLE="POSITION:#DIV_POSITION#;Z-INDEX:5000;DISPLAY:#DIV_DISPLAY#;" ID="DIV_#thisItem#_Start">#DateFormat(Start_Date, "mm/dd/yy")#</DIV></CFOUTPUT>						
	</CFSAVECONTENT>
	<CFSAVECONTENT VARIABLE="Graph_Legend2">
	<CFOUTPUT><DIV STYLE="POSITION:#DIV_POSITION#;Z-INDEX:5000;DISPLAY:#DIV_DISPLAY#;" ID="DIV_#thisItem#_Desc"><font color="aaaaaa">&nbsp;#Attributes.sDesc#&nbsp;</font></DIV></CFOUTPUT>
	</CFSAVECONTENT>
	<CFSAVECONTENT VARIABLE="Graph_Legend3">
	<CFOUTPUT><DIV STYLE="POSITION:#DIV_POSITION#;Z-INDEX:5000;DISPLAY:#DIV_DISPLAY#;" ID="DIV_#thisItem#_End">#DateFormat(End_Date, "mm/dd/yy")# (#This_Item_Date_Span# days)</DIV></CFOUTPUT>
	</CFSAVECONTENT>
	<CFSAVECONTENT VARIABLE="Graph_Legend_Script">
	<CFOUTPUT><CFSET BB=Caller.addThisDateToDisplay("Bar_Images_#thisItem#", "Bar_Images_#thisItem#", "DIV_#thisItem#_Start", "DIV_#thisItem#_End", "DIV_#thisItem#_Desc")></CFOUTPUT>
	</CFSAVECONTENT>
</CFIF>

<CFOUTPUT></TR>
</TABLE></CFOUTPUT>
<CFOUTPUT><CFIF ADDSCRIPT EQ "Yes">#Graph_Legend1##Graph_Legend2##Graph_Legend3#
#Graph_Legend_Script#</CFIF></TD></TR></CFOUTPUT>
<CFIF ADDSCRIPT NEQ "Yes">
<CFOUTPUT><TR><TD NOWRAP ALIGN="LEFT"></CFOUTPUT>
<!--- For the above table, we have a nested table. We need a nested table here too so that the dates/billback can be shown below the bar for dates - IE 10 issue. --->
<CFOUTPUT><TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" STYLE="border-collapse: collapse"><TR>
<TD WIDTH="#Empty_Image_len#"></TD>
<TD></CFOUTPUT>		
		<!---<CFIF Empty_Image_len GT 0>						
			<CFIF Caller.USEIMGGRAPH>
				<CFOUTPUT><IMG SRC="/Images/fill.gif" HEIGHT="#DATE_GRAPH_HEIGHT#" WIDTH="#Empty_Image_len#" BORDER="0"></CFOUTPUT>
			<CFELSE>
				<CFOUTPUT><SPAN CLASS="GRAPHSPAN_FILL" STYLE="WIDTH:#Empty_Image_len#px"></SPAN></CFOUTPUT>
			</CFIF>
		</CFIF>--->
<CFOUTPUT>#Graph_Legend1#&nbsp;-&nbsp;#Graph_Legend3#</CFOUTPUT>
<CFOUTPUT><BR></CFOUTPUT>
		<!---<CFIF Empty_Image_len GT 0>						
			<CFIF Caller.USEIMGGRAPH>
				<CFOUTPUT><IMG SRC="/Images/fill.gif" HEIGHT="#DATE_GRAPH_HEIGHT#" WIDTH="#Empty_Image_len#" BORDER="0"></CFOUTPUT>
			<CFELSE>
				<CFOUTPUT><SPAN CLASS="GRAPHSPAN_FILL" STYLE="WIDTH:#Empty_Image_len#px"></SPAN></CFOUTPUT>
			</CFIF>
		</CFIF>--->
<CFOUTPUT>#Graph_Legend2#</CFOUTPUT>	
<CFOUTPUT></TD></CFOUTPUT>	
<CFOUTPUT></TR></TABLE></CFOUTPUT>
<CFOUTPUT></TD></TR></CFOUTPUT>
</CFIF>
<cfsetting enableCFoutputOnly = "No">