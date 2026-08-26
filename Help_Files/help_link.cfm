<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the help link in most pages															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">
  <TR>
    <TD>
		<CFPARAM NAME="helpfilenumber" DEFAULT="0">
		<B>
		<FONT SIZE="2" COLOR="Red">[</FONT>
			<FONT SIZE="2" COLOR="Blue">
				<CFOUTPUT>
					<A HREF="/help_files/index.cfm?ID=#helpfilenumber#" onclick="NewWindow(this.href,'name','625','450','Yes', 'No');return false;" TITLE="Instructions...">
						read me first
					</A>
				</CFOUTPUT>
			</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
		</B>
		
		<cfif application.returned_customer_setting.customer_keyword IS "conagra"><B>
		<FONT SIZE="2" COLOR="Red">[</FONT>
			<FONT SIZE="2" COLOR="Blue">
				<CFOUTPUT>
					<A HREF="/help_files/shockwave_tutorial.cfm" onclick="NewWindow(this.href,'name','1080','820','Yes', 'Yes');return false;" TITLE="Instructions...">
						tutorials
					</A>
				</CFOUTPUT>
			</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
		</B></cfif>
	</TD>
  </TR>
</TABLE>





	
	
<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Typical help link from any page - review link number from table below							 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=xx>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

 --->	


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Key used with the numbering scheme for the help files											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- 
1		/Manufacturers/home.cfm
2		/scorecard/scorecard_detail.cfm
3		/common_files/contracts/contract_create_1_form.cfm basic info section
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100

 --->