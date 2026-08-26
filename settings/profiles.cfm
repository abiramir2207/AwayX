<!---
	Copyright (c)2012 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\settings\profiles.cfm
	Created:		11/30/2012
	Developer:		drachala
--->
<B>Search:</B><input name="profile" type="text" value="">
<div style="width:620px;margin-top:5px;">
<cfdiv bind="url:profiles_list.cfm?InputText={profile@keyup}" ID="theDiv" style="width:620px;"/>
</div>
