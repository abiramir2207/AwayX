<CFOUTPUT>

<!---set formname--->
<CFSET formName = "frmOperatorPriority">

<script language="JavaScript"><!--

	function submitForm(doAction, id) 
	{
		if(!id)
		{
			id = 0;
		}
		document.#formName#.id.value = id;
		document.#formName#.doAction.value = doAction;
    	document.#formName#.submit();
		return false;
	}
//--></script>

<!---set default params--->
<cfparam name="url.doAction" default="assignPriority" />
<cfparam name="form.doAction" default="#url.doAction#" />
<cfparam name="form.id" default="0" />

<!---///////////////////////// controller section ////////////////////////////////////////--->

<!---initialize Priority object--->
<cfset priority = CreateObject("component", "components.customer.operator.Priority") />

<cfswitch expression="#form.doAction#">
	
	<cfcase value="viewPriority">
		<cfset actionDisplay = "View" />
		<cfset qGetPriority = priority.getPriority() />
		<cfset include = "operator_priority_view.cfm" />
		<cfset form.id = 0 />
	</cfcase>
	
	<cfcase value="createPriority">
		<cfset actionDisplay = "Create" />
		<cfset include = "operator_priority_create_edit.cfm" />
		<cfset form.id = 0 />
	</cfcase>
	
	<cfcase value="editPriority">
		<cfset qGetPriority = priority.getPriority(form.id) />
		<cfset actionDisplay = "Edit" />
		<cfset include = "operator_priority_create_edit.cfm" />
	</cfcase>
	
	<cfcase value="deletePriority">
		<cfset priority.deletePriority(form.id) />
		<cflocation addtoken="No" url="#ThisPage#?doAction=viewPriority&mode=4">
	</cfcase>
	
	<cfcase value="savePriority">
		<cfset priority.save(form.id, form.priorityName) />
		<cflocation addtoken="No" url="#ThisPage#?doAction=viewPriority&mode=4">
	</cfcase>
	
	<cfcase value="assignPriority,assignPriorityAction,assignPrioritySuccess">
		<cfset actionDisplay = "Assign" />
	</cfcase>
	
</cfswitch>

<!---///////////////////////// end controller section ////////////////////////////////////--->

<form action="#ThisPage#" method="post" name="#formName#">
<input type="Hidden" name="mode" value="#FORM.mode#">
<input type="Hidden" name="doAction" value="#FORM.doAction#">
<input type="Hidden" name="id" value="#FORM.id#">
<B>
	<FONT COLOR="FF0000">[</FONT>
		<a HREF="javascript: void(0);" onclick="javaScript: return submitForm('viewPriority');">View Priority</a>
	<FONT COLOR="FF0000">]</FONT>
</B>
&nbsp;
<B>
	<FONT COLOR="FF0000">[</FONT>
		<a HREF="javascript: void(0);" onclick="javaScript: return submitForm('createPriority');">Create Priority</a>
	<FONT COLOR="FF0000">]</FONT>
</B>
 &nbsp;
<B>
	<FONT COLOR="FF0000">[</FONT>
		<a HREF="javascript: void(0);" onclick="javaScript: return submitForm('assignPriority');">Assign operators</a>
	<FONT COLOR="FF0000">]</FONT>
</B>
<br><br>
<SPAN CLASS="Title2">Priority - #actionDisplay#</SPAN>&nbsp;&nbsp;&nbsp;

<HR COLOR="Orange">

<!---/////////////////////////////////////// Display ///////////////////////////////////////////////////--->

<cfswitch expression="#form.doAction#">
	
	<cfcase value="viewPriority">
		<cfinclude template="#include#" />
	</cfcase>
	
	<cfcase value="editPriority">
		<cfset form.priorityName = qGetPriority.Priority_Label />
		<cfinclude template="#include#" />
	</cfcase>
	
	<cfcase value="createPriority">
		<cfset form.PriorityName = "" />
		<cfinclude template="#include#" />
	</cfcase>
	
	<cfcase value="assignPriority,assignPriorityAction,assignPrioritySuccess">
		<cfinclude template="operator_priority_assign.cfm" />
	</cfcase>
	
</cfswitch>

<!---/////////////////////////////////////// End Display ////////////////////////////////////////////////--->


</form>
</CFOUTPUT>