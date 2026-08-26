<!------
Deviation_Display_Style.cfm
----->

	<STYLE>
		.table1 TD
		{
			font-size:14px;
			font-weight:bold;
			font-face:Ariel;
		}
		.wrongAmount TD
		{
			color:red;
		}
	</STYLE>
	
	<!------------------------ Define Style ---------------------------------->

<CFSET PAYEE_TD_COLOR		="FFFFFF">
<CFSET PAYEE__IN_TD_COLOR	="FFFFFF">
<!------
<CFSET PROGRAM_TD_COLOR		="ffe4b5">
<CFSET PROGRAM_TD_COLOR		="ccffcc">
----->
<!----
<CFSET PROGRAM_TD_COLOR			="FFCC00">
---->
<CFSET PROGRAM_TD_COLOR			="F0E68C">
<CFSET PROGRAM_TD_BORDER_COLOR	="808080">
<CFSET PROGRAM_TR_IN_COLOR		="FFFFFF">
<CFSET PROGRAM_TD_Width			="2">
<CFSET PRODUCT_TD_COLOR			="ccffcc">
<CFSET PRODUCT_IN_TR_COLOR		="FFFFFF">
<CFSET LUMPSUM_TD_COLOR			="FFFACD">
<CFSET LUMPSUM_IN_TR_COLOR		="FFFACD">
<CFSET GROWTH_TD_COLOR			="E6E6FA">
<CFSET GROWTH_IN_TR_COLOR		="E6E6FA">

<CFOUTPUT>
<STYLE>
	.Table_Header
	{
		font-size : 12px;
		font-weight:bold;
	}
	.payeeTD	
	{
		background-color:#PAYEE_TD_COLOR#;
	}
	.payeeInsideTD	
	{
		background-color:#PAYEE__IN_TD_COLOR#;
	}
	.NoValidDesc
	{
		color:red;
		font-weight:bold;
	}
	.NoValidDesc:LINK,.NoValidDesc:VISITED,.NoValidDesc:HOVER 
	{
		color:red;
	}
	.YesValidDesc
	{
		color: black;
	}
	.YesValidDesc:LINK,.YesValidDesc:VISITED,.YesValidDesc:HOVER
	{
		color: blue;
	}	
	.NotprocessedValidDesc
	{
		color: 999999;
	}
	.programTD TD
	{
		background-color:#PROGRAM_TD_COLOR#;
		border-top: 2px solid ###PROGRAM_TD_BORDER_COLOR#;
		border-bottom: 2px solid ###PROGRAM_TD_BORDER_COLOR#;
		font-size:12px;
		font-weight:bold;
	}
	.programInTR
	{
		background-color:#PROGRAM_TR_IN_COLOR#;
	}
	.programInTR TD
	{
		border-top: 1px solid ###PROGRAM_TD_BORDER_COLOR#;
	}	
	.programLeft
	{
		/*border-left:solid #PROGRAM_TD_COLOR# #PROGRAM_TD_Width#px;*/
		background-color:#PROGRAM_TR_IN_COLOR#;
	}
	.programBottom
	{
		border-left:solid #PROGRAM_TD_COLOR# #PROGRAM_TD_Width#px;
		border-bottom:solid #PROGRAM_TD_COLOR# #PROGRAM_TD_Width#px;
		border-right:solid #PROGRAM_TD_COLOR# #PROGRAM_TD_Width#px;
		background-color: FFFFFF;
	}
	.programRight
	{
		border-right:solid #PROGRAM_TD_COLOR# #PROGRAM_TD_Width#px;
		background-color: FFFFFF;
	}
	.lumpsumTD	
	{
		background-color:#LUMPSUM_TD_COLOR#;
	}
	.lumpsumInTR
	{
		background-color:#LUMPSUM_IN_TR_COLOR#;
	}
	.growthTD	
	{
		background-color:#GROWTH_TD_COLOR#;
	}
	.growthInTR
	{
		background-color:#GROWTH_IN_TR_COLOR#;
	}
	.productTR
	{
		background-color:#PRODUCT_TD_COLOR#;
	}
	.productTD	
	{
		background-color:#PRODUCT_TD_COLOR#;
	}
	.productInTR
	{
		background-color:#PRODUCT_IN_TR_COLOR#;
	}
	.discountTD	
	{
		
	}
</STYLE>
</CFOUTPUT>
