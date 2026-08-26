<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">
<title>Details</title>
</head>

<body>

<link rel="stylesheet" type="text/css" href="styles_global.css">

<!--- redirect the flow to the correct item: operator, distributor or product --->
<cfswitch expression="#url.item_type_code#">
    <cfcase value="1">
        <cfinclude template="index_operators.cfm">
    </cfcase>
    <cfcase value="2">
        <cfinclude template="index_distributors.cfm">
    </cfcase>
    <cfcase value="3">
        <cfinclude template="index_products.cfm">
    </cfcase>
    <cfdefaultcase>
        &nbsp;
    </cfdefaultcase>
</cfswitch>



</body>
</html>

