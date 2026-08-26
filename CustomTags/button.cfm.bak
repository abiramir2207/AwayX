
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Generic parameters that define the look and behavior of the button							 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFPARAM NAME="Attributes.button_name"	DEFAULT="#createUUID()#">
<CFPARAM NAME="Attributes.button_caption"	DEFAULT="click here">
<CFPARAM NAME="Attributes.button_action"	DEFAULT="">
<CFPARAM NAME="Attributes.button_width"		DEFAULT="75">
<CFPARAM NAME="Attributes.button_color"		DEFAULT="red">
<CFPARAM NAME="Attributes.button_tip"		DEFAULT=".">
<CFPARAM NAME="Attributes.button_type"		DEFAULT="button"> <!--- button or submit or link--->
<CFPARAM NAME="Attributes.font_color"		DEFAULT="Blue">
<CFPARAM NAME="Attributes.font_size"		DEFAULT="12">
<CFPARAM NAME="Attributes.font_weight"		DEFAULT="bold">
<CFPARAM NAME="Attributes.enabled"			DEFAULT="1">
<CFPARAM NAME="Attributes.TabInd"			DEFAULT="0">
<CFPARAM NAME="Attributes.Title"			DEFAULT="">

<!--- 
<CFPARAM NAME="Attributes.font_color"		DEFAULT="Blue">
 --->

<CFSET Attributes.font_color="White">

<CFOUTPUT>

<STYLE TYPE="text/css">

	.button {

		<!--- background-color: #Attributes.button_color#; --->
		border: 0px;
		width: #Attributes.button_width#;
		color: #Attributes.font_color#;
		font-weight: #Attributes.font_weight#;
		font-size: #Attributes.font_size#;
		cursor: pointer;
	}
	
</STYLE>


<CFSWITCH EXPRESSION="#Attributes.button_type#">

	<CFCASE VALUE="submit">
		<CFSET LeftButtonEdge = "<INPUT TYPE=""Image"" SRC=""/images/button_left00.gif"">">
		<CFSET MiddleButton = "<INPUT TYPE=""Image"" SRC=""/images/button_middle00.gif"" NAME=""#Attributes.button_name#"" TYPE=""#Attributes.button_type#"" VALUE=""#Attributes.button_caption#"">">
		<CFSET RightButtonEdge = "<INPUT TYPE=""Image"" SRC=""/images/button_right00.gif"">">		
	</CFCASE>

	<CFCASE VALUE="link">
		<CFSET onCLickAttrib = "window.location.href='#Attributes.button_action#'" />
	</CFCASE>

	<CFCASE VALUE="javascript_link">
		<CFSET onCLickAttrib = "#Attributes.button_action#" />
	</CFCASE>	

	<CFCASE VALUE="button">
		<CFSET LeftButtonEdge = "<IMG STYLE=""cursor: pointer;"" SRC=""/images/button_left00.gif"" TITLE=""#Attributes.button_tip#"" BORDER=""0"" ONCLICK=""#Attributes.button_action#"">">
		<CFSET MiddleButton = "<INPUT CLASS=""button"" NAME=""#Attributes.button_name#"" TYPE=""#Attributes.button_type#"" VALUE=""#Attributes.button_caption#"" ONCLICK=""#Attributes.button_action#"" STYLE=""background: #Attributes.button_color#;"">">
		<CFSET RightButtonEdge = "<IMG STYLE=""cursor: pointer;"" SRC=""/images/button_right00.gif"" TITLE=""#Attributes.button_tip#"" BORDER=""0"" ONCLICK=""#Attributes.button_action#"">">
	</CFCASE>
	
	 <CFDEFAULTCASE>
		<CFSET LeftButtonEdge = "<IMG SRC=""/images/button_left00.gif"" TITLE=""#Attributes.button_tip#"" BORDER='0' ONCLICK=""#Attributes.button_action#"">">
		<CFSET MiddleButton = "<SPAN class=""button"">#Attributes.button_caption#</SPAN>">
		<CFSET RightButtonEdge = "<IMG SRC=""/images/button_right00.gif"" TITLE=""#Attributes.button_tip#"" BORDER='0' ONCLICK=""#Attributes.button_action#"">">
	</CFDEFAULTCASE> 
	
</CFSWITCH>

<!---if the button type is link or javascript_link then show <A> tag--->
<cfif ListFindNoCase("link,javascript_link", Attributes.button_type)>

	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ID="#Attributes.button_name#_table"  >
		<TR>
			<!--- D17683 [begin] RBL 12/08/08 (to remove consistent trailing href underline) --->
			<td nowrap Style="border:none">
				<FONT COLOR="##FF0000"><B>[ </B></FONT>
					<cfif Attributes.enabled>
						<A HREF="##" onClick="#onCLickAttrib#; return false;" STYLE="COLOR:##0000FF;" tabindex="#Attributes.TabInd#" title="#Attributes.title#">
							<B>#Attributes.button_caption#</B>
						</A>
					<cfelse>
						<B><span style="color:gray">#Attributes.button_caption#</span></B>
					</cfif>
				<FONT COLOR="##FF0000"><B> ]</B></FONT>
			</td>
      <!--- D17683 [end] RBL 12/08/08 --->  
		</TR>
	</TABLE>

<cfelse>

	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ID="#Attributes.button_name#_table">
		<TR>
			<td nowrap style="color:blue;">
				<FONT COLOR="##FF0000"><B>[ </B></FONT>
					<B>#Attributes.button_caption#</B>					
				<FONT COLOR="##FF0000"><B> ]</B></FONT>
			</td>
		</TR>
	</TABLE>

</cfif>

</CFOUTPUT>