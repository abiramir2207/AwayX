<!------News_Feed_List.cfm----->

<CFSET delimiterchar="|">
<CFSET listdelimiter=",">

<CFSET sourcelist="">





<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the link to headline news --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET sourcelist=listappend(sourcelist,"http://p.moreover.com/cgi-local/page?c=Food%20industry%20news&o=rss#delimiterchar#food_industry.xml",listdelimiter)>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFSET sourcelist=listappend(sourcelist,"http://p.moreover.com/cgi-local/page?c=Drinks%20and%20beverages%20industry%20news&o=rss#delimiterchar#drink_beverage.xml",listdelimiter)>
<CFSET sourcelist=listappend(sourcelist,"http://p.moreover.com/cgi-local/page?index_commodities+rss#delimiterchar#commodities.xml",listdelimiter)>
<CFSET sourcelist=listappend(sourcelist,"http://p.moreover.com/cgi-local/page?c=Offbeat%20news&o=rss#delimiterchar#offbeat.xml",listdelimiter)>
<CFSET sourcelist=listappend(sourcelist,"http://www.moreover.com/cgi-local/page?o=rss&c=Boston%20news#delimiterchar#boston_news.xml",listdelimiter)>
<CFSET sourcelist=listappend(sourcelist,"http://www.prweb.com/xml/restaurants.xml#delimiterchar#PR_restaurants.xml",listdelimiter)>
<CFSET sourcelist=listappend(sourcelist,"http://www.prweb.com/xml/leisurehospitality.xml#delimiterchar#PR_leisurehospitality.xml",listdelimiter)>
<!--- Wired Magazine --->						<CFSET sourcelist=listappend(sourcelist,"http://www.wired.com/news_drop/netcenter/netcenter.rdf#delimiterchar#wired_tech.xml",listdelimiter)>
<!--- CNET News.com (20 most recent) --->		<CFSET sourcelist=listappend(sourcelist,"http://news.com.com/2547-1_3-0-20.xml#delimiterchar#cnet_news_main.xml",listdelimiter)>
<!--- Enterprise Software (10 most recent) --->	<CFSET sourcelist=listappend(sourcelist,"http://news.com.com/2547-7343-0-10.xml#delimiterchar#cnet_enterprise_software.xml",listdelimiter)>
<!--- Enterprise Hardware (10 most recent) --->	<CFSET sourcelist=listappend(sourcelist,"http://news.com.com/2547-1001-0-10.xml#delimiterchar#cnet_enterprise_hardware.xml",listdelimiter)>
<!--- Security (10 most recent) --->			<CFSET sourcelist=listappend(sourcelist,"http://news.com.com/2547-1009-0-10.xml#delimiterchar#cnet_security.xml",listdelimiter)>
<!--- Networking (10 most recent) --->			<CFSET sourcelist=listappend(sourcelist,"http://news.com.com/2547-1035-0-10.xml#delimiterchar#cnet_networking.xml",listdelimiter)>
<!--- The Net (10 most recent) --->				<CFSET sourcelist=listappend(sourcelist,"http://news.com.com/2547-1023-0-10.xml#delimiterchar#cnet_the_net.xml",listdelimiter)>
<!--- Personal Technology (10 most recent) --->	<CFSET sourcelist=listappend(sourcelist,"http://news.com.com/2547-1040-0-10.xml#delimiterchar#cnet_personal_technology.xml",listdelimiter)>
<!--- Newsmakers (interviews & profiles) --->	<CFSET sourcelist=listappend(sourcelist,"http://news.com.com/2547-1082-0.xml#delimiterchar#cnet_newsmakers.xml",listdelimiter)>
<!--- Perspectives & Letters --->				<CFSET sourcelist=listappend(sourcelist,"http://news.com.com/2547-1071-0.xml#delimiterchar#cnet_perspectives_and_letters.xml",listdelimiter)>
<CFSET sourcelist=listappend(sourcelist,"http://www.prweb.com/xml/foodbeverage.xml#delimiterchar#Food_beverage.xml",listdelimiter)>


