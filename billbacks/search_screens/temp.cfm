<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<FORM NAME="Test_Form" ID="Test_Form" ACTION="temp.cfm">
<B>Programs associated with this project:
&nbsp;&nbsp;&nbsp;&nbsp;
<FONT COLOR="Red">[</FONT> 
	<CFOUTPUT>
	<A HREF="search_programs.cfm"  onclick="NewWindow(this.href + '?Formname=Test_Form&FieldName=Result_List','MyWindowName','800','600','Yes', 'Yes');return false;">pick from list</A> 
	</CFOUTPUT>
<FONT COLOR="Red">]</FONT> 
</B><BR>
<CFOUTPUT>

<INPUT TYPE="TEXT" ID="Result_List" NAME="Result_List" VALUE="<cfif isDefined("Form.Result_List")>#Form.Result_List#</cfif>">


</CFOUTPUT>
</FORM>

</body>
</html>
