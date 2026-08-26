<CFOUTPUT>

<!---set formname--->
<CFSET formName = "frmOperatorCategory">

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
<cfparam name="url.doAction" default="assignCategory" />
<cfparam name="form.doAction" default="#url.doAction#" />
<cfparam name="form.id" default="0" />

<!---///////////////////////// controller section ////////////////////////////////////////--->

<!---initialize category object--->
<cfset category = CreateObject("component", "components.customer.operator.Category") />

<cfswitch expression="#form.doAction#">
	
	<cfcase value="viewCategory">
		<cfset actionDisplay = "View" />
		<cfset qGetCategory = category.getCategory() />
		<cfset include = "operator_category_view.cfm" />
		<cfset form.id = 0 />
	</cfcase>
	
	<cfcase value="createCategory">
		<cfset actionDisplay = "Create" />
		<cfset include = "operator_category_create_edit.cfm" />
		<cfset form.id = 0 />
	</cfcase>
	
	<cfcase value="editCategory">
		<cfset qGetCategory = category.getCategory(form.id) />
		<cfset actionDisplay = "Edit" />
		<cfset include = "operator_category_create_edit.cfm" />
	</cfcase>
	
	<cfcase value="deleteCategory">
		<cfset category.deleteCategory(form.id) />
		<cflocation addtoken="No" url="#ThisPage#?doAction=viewCategory&mode=3">
	</cfcase>
	
	<cfcase value="saveCategory">
		<cfset category.save(form.id, form.categoryName) />
		<cflocation addtoken="No" url="#ThisPage#?doAction=viewCategory&mode=3">
	</cfcase>
	
	<cfcase value="assignCategory,assignCategoryAction,assignCategorySuccess">
		<cfset actionDisplay = "Assign" />
		<cfset include = "operator_category_assign.cfm" />
	</cfcase>
	
</cfswitch>

<!---///////////////////////// end controller section ////////////////////////////////////--->

<form action="#ThisPage#" method="post" name="#formName#">
<input type="Hidden" name="id" value="#FORM.id#">
<input type="Hidden" name="mode" value="#FORM.mode#">
<input type="Hidden" name="doAction" value="#FORM.doAction#">
<B>
	<FONT COLOR="FF0000">[</FONT>
		<a HREF="javascript: void(0);" onclick="javaScript: return submitForm('viewCategory');">View Category</a>
	<FONT COLOR="FF0000">]</FONT>
</B>
&nbsp;
<B>
	<FONT COLOR="FF0000">[</FONT>
		<a HREF="javascript: void(0);" onclick="javaScript: return submitForm('createCategory');">Create Category</a>
	<FONT COLOR="FF0000">]</FONT>
</B>
 &nbsp;
<B>
	<FONT COLOR="FF0000">[</FONT>
		<a HREF="javascript: void(0);" onclick="javaScript: return submitForm('assignCategory');">Assign Categories</a>
	<FONT COLOR="FF0000">]</FONT>
</B> 
<br><br>
<SPAN CLASS="Title2">Category - #actionDisplay#</SPAN>&nbsp;&nbsp;&nbsp;

<HR COLOR="Orange">

<!---/////////////////////////////////////// Display ///////////////////////////////////////////////////--->

<cfswitch expression="#form.doAction#">
	
	<cfcase value="viewCategory">
		<cfinclude template="#include#" />
	</cfcase>
	
	<cfcase value="editCategory">
		<cfset form.categoryName = qGetCategory.Category_Label />
		<cfinclude template="#include#" />
	</cfcase>
	
	<cfcase value="createCategory">
		<cfset form.categoryName = "" />
		<cfinclude template="#include#" />
	</cfcase>
	
	<cfcase value="assignCategory,assignCategoryAction,assignCategorySuccess">
		<cfinclude template="#include#" />
	</cfcase>
	
</cfswitch>

<!---/////////////////////////////////////// End Display ////////////////////////////////////////////////--->


</form>
</CFOUTPUT>