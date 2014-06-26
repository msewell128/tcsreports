<cfparam name="url.showdump" default="0">
<cfparam name="url.dspRpt" default="0">
<cfparam name="url.useMonth" default="4">

<cfscript>
	theDate = createODBCDateTime('2014/#url.useMonth#/01');
	nextDate = createODBCDateTime('2014/#url.useMonth+1#/01');
	theMonth = dateformat(theDate,"mmm");
	nextMonth = dateformat(nextDate,"mmm");
	chartColors = "##036A9B,##7DA915,##B41318,##FB840A,##72A0C1,##AF002A,##18B918,##2A0DC1,##D25128,##8FB442";
	theColors = "
			##4572A7,
			##B41318,
			##FB840A,
			##036A9B,
			##DB843D,
			##058DC7,
			##7DA915,
			##72A0C1,
			##AF002A,
			##2A0DC1,
			##D25128,
			##89A54E,
			##80699B,
			##3D96AE,
			##036A9B,
			##50B432,
			##FB840A,
			##92A8CD,
			##A47D7C";
</cfscript>
<cfinclude template="inc/query.cfm">

<cfif url.dspRpt><cfdocument format="pdf"></cfif>
<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>TCs Development</title>
	<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
	<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/jquery-ui.min.js"></script>
	<script src="assets/scripts/highcharts.js"></script>
	<script src="assets/scripts/highcharts-3d.js"></script>

	<link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/themes/smoothness/jquery-ui.css" />
	<link rel="stylesheet" href="assets/css/style.css">
	<link rel="stylesheet" href="assets/css/table.css">
	<link rel="stylesheet" href="assets/css/print.css" type="text/css" media="print" />

	<cfinclude template="inc/charts.cfm">

</head>
<body>
<div id="container">
	<div id="header">
		<img src="assets/images/TransConnect_400_48.png" width="400" height="48">
	</div>
	<div id="navigation">
		<cfoutput>
		<ul>
			<li><a href="/tcsreports/">Home</a></li>
			<li><a href="/tcsreports/progress.cfm">Progress</a></li>
			<cfloop from="3" to="#month(now())#" index="i">
			<li><a href="?useMonth=#i#&showdump=#url.showdump#">#DateFormat("#year(now())#/#i#/01","mmmm")#</a></li>
			</cfloop>
			<li><a href="?useMonth=#month(now())#&showdump=#url.showdump#">Current Month</a></li>
			<li><cfif url.showdump><a href="?useMonth=#dateformat(dateAdd("m",-1,now()),"m")#&showdump=0">No Debug<cfelse>
			<a href="?useMonth=#dateformat(dateAdd("m",-1,now()),"m")#&showdump=1">Debug</cfif></a></li>
		</ul>
		</cfoutput>
	</div>

	<div id="content">
		<div class="row">
			<div id="completedByDate" style="height: 300px; min-width: 840px; max-width: 840px; margin: 0 auto"></div>
				<table class="tsc_table_s3" summary="Issues Completed" style="width:100%;">
					<thead>
					<tr>
						<th scope="col">Developer</th>
						<th scope="col">Tasks Completed</th>
						<th scope="col">Developer</th>
						<th scope="col">Tasks Completed</th>
						<th scope="col">Developer</th>
						<th scope="col">Tasks Completed</th>
					</tr>
					</thead>
		    		<tbody>
					<cfoutput query="completedByDate">
						<cfif currentRow MOD 3 EQ 1>
							<tr>
								<td>#ResolvedDate#</td>
								<td>#cnt#</td>
						<cfelseif currentRow MOD 3 EQ 0>
								<td>#ResolvedDate#</td>
								<td>#cnt#</td>
							</tr>
						<cfelseif currentRow MOD 3 EQ 2>
								<td>#ResolvedDate#</td>
								<td>#cnt#</td>
						</cfif>
					</cfoutput>
		    		</tbody>
				</table>
			<div class="clear"></div>
		</div>

		<div class="row">
			<div id="getTheHours" style="height: 300px; min-width: 840px; max-width: 840px; margin: 0 auto"></div>
				<table class="tsc_table_s3" summary="Issues Completed" style="width:100%;">
					<thead>
					<tr>
						<th scope="col">Developer</th>
						<th scope="col">Hours Completed</th>
						<th scope="col">Developer</th>
						<th scope="col">Hours Completed</th>
						<th scope="col">Developer</th>
						<th scope="col">Hours Completed</th>
					</tr>
					</thead>
		    		<tbody>
					<cfoutput query="getTheHours">
						<cfif currentRow MOD 3 EQ 1>
							<tr>
								<td>#ResolvedDate#</td>
								<td>#hrsActual#</td>
						<cfelseif currentRow MOD 3 EQ 0>
								<td>#ResolvedDate#</td>
								<td>#hrsActual#</td>
							</tr>
						<cfelseif currentRow MOD 3 EQ 2>
								<td>#ResolvedDate#</td>
								<td>#hrsActual#</td>
						</cfif>
					</cfoutput>
		    		</tbody>
				</table>
			<div class="clear"></div>
		</div>

		<div class="row">
			<div class="left">
				<div id="getTheHoursByUser" style=" height: 200px; min-width: 420px; max-width: 430px; margin: 0 auto"></div>
				<table class="tsc_table_s3" summary="Issues Completed" style="width:100%;">
					<thead>
					<tr>
						<th scope="col">Developer</th>
						<th scope="col">Task Hours Completed</th>
					</tr>
					</thead>
		    		<tbody>
			    		<cfset theTotal = 0>
					<cfoutput query="getTheHoursByUser">
						<cfif round(HrsActual)><tr>
							<td>#who#</td>
							<td>#round(HrsActual)#</td>
						</tr>
						<cfset theTotal += round(HrsActual)>
						</cfif>
					</cfoutput>
					<tfoot>
						<tr><td></td><td><cfoutput>#theTotal#</cfoutput></td></tr>
					</tfoot>
		    		</tbody>
				</table>
			</div>
			<div class="right">
				<div id="whoCompleted" style="min-width: 420px; height: 200px; max-width: 430px; margin: 0 auto"></div>
				<table class="tsc_table_s3" summary="Issues Completed" style="width:100%;">
					<thead>
					<tr>
						<th scope="col">Developer</th>
						<th scope="col">Actual Hours</th>
					</tr>
					</thead>
		    		<tbody>
			    	<cfset theTotal = 0>
					<cfoutput query="whoCompleted">
						<cfif dun><tr>
							<td>#who#</td>
							<td>#dun#</td>
						</tr>
						<cfset theTotal += dun>
						</cfif>
					</cfoutput>
					<tfoot>
						<tr><td></td><td><cfoutput>#theTotal#</cfoutput></td></tr>
					</tfoot>
		    		</tbody>
				</table>
			</div>
			<div class="clear"></div>
		</div>

		<div class="row">
			<div class="left">
				<div id="issueTypes" style="min-width: 420px; height: 200px; max-width: 430px; margin: 0 auto"></div>
				<table class="tsc_table_s3" summary="Issues Completed" style="width:100%;">
					<thead>
					<tr>
						<th scope="col">Developer</th>
						<th scope="col">Actual Hours</th>
					</tr>
					</thead>
		    		<tbody>
					<cfoutput query="issueTypes">
						<tr>
							<td>#issue#</td>
							<td>#dun#</td>
						</tr>
					</cfoutput>
		    		</tbody>
				</table>
			</div>

			<div class="right">
		 		<cfchart format="png" show3d="true" seriesplacement="stacked" chartwidth="420" chartheight="200" pieslicestyle="sliced" title="Completed Tasks (Est vs Actual)">
				  <cfchartseries type="bar" query="hrsByDev" valueColumn="estimated" itemColumn="who" seriescolor="##7DA915"  />
				  <cfchartseries type="bar" query="hrsByDev" valueColumn="actual" itemColumn="who" seriescolor="##036A9B"  />
				</cfchart>
				<table class="tsc_table_s3" summary="Issues Completed" style="width:100%;">
					<thead>
					<tr>
						<th scope="col">Developer</th>
						<th scope="col">Estimated Hours</th>
						<th scope="col">Actual Hours</th>
					</tr>
					</thead>
		    		<tbody>
					<cfoutput query="hrsByDev">
						<tr>
							<td>#who#</td>
							<td>#estimated#</td>
							<td>#numberFormat(actual,"999.99")#</td>
						</tr>
					</cfoutput>
		    		</tbody>
				</table>
			</div>
			<div class="clear"></div>
		</div>

		<div class="row">
			<div class="left">
				<div id="newIssuesStatus" style="min-width: 420px; height: 200px; max-width: 430px; margin: 0 auto"></div>

			</div>
			<div class="right">
				<div id="allResolved" style="min-width: 420px; height: 200px; max-width: 430px; margin: 0 auto"></div>
<!--- 			<cfchart format="png" show3d="false" chartwidth="205" chartheight="200" pieslicestyle="sliced" title="ALL Resolved Issues">
			  <cfchartseries type="pie" query="isResolved" valueColumn="cnt" itemColumn="isResolved" colorlist="##036A9B,##7DA915,##B41318,##FB840A" />
			</cfchart>

			<cfchart format="png" show3d="false" chartwidth="205" chartheight="200" pieslicestyle="sliced" title="NEW Issues Status">
			  <cfchartseries type="pie" query="getNew" valueColumn="dun" itemColumn="isResolved" colorlist="##036A9B,##7DA915,##B41318,##FB840A" />
			</cfchart> --->

			</div>
			<div class="clear"></div>
		</div>

	 	<div>
			<table class="tsc_table_s3" summary="Sample Table" style="width:100%;">
				<thead>
				<tr><th colspan="5" scope="col"> Completed Issues</th></tr>
				<tr>
					<th scope="col">Issue</th>
					<th scope="col">Est</th>
					<th scope="col">Actual</th>
					<th scope="col">Completed</th>
					<th scope="col">Developer</th>
				</tr>
				</thead>
	    		<tbody>
				<cfoutput query="qoq1">
					<tr>
						<td>#shortdescr#</td>
						<td>#hrsEst#</td>
						<td>#left(hrsActual,4)#</td>
						<td>#dateFormat(Resolved,"short")#</td>
						<td>#Who#</td>
					</tr>
				</cfoutput>
	    		</tbody>
			</table>
		</div>
	<!---
	<div id="tabs">
	  <ul>
	    <li><a href="#tabs-1">Nunc tincidunt</a></li>
	    <li><a href="#tabs-2">Proin dolor</a></li>
	    <li><a href="#tabs-3">Aenean lacinia</a></li>
	  </ul>
	  <div id="tabs-1">
	    <p>Proin elit arcu, rutrum commodo, vehicula tempus, commodo a, risus. Curabitur nec arcu. Donec sollicitudin mi sit amet mauris. Nam elementum quam ullamcorper ante. Etiam aliquet massa et lorem. Mauris dapibus lacus auctor risus. Aenean tempor ullamcorper leo. Vivamus sed magna quis ligula eleifend adipiscing. Duis orci. Aliquam sodales tortor vitae ipsum. Aliquam nulla. Duis aliquam molestie erat. Ut et mauris vel pede varius sollicitudin. Sed ut dolor nec orci tincidunt interdum. Phasellus ipsum. Nunc tristique tempus lectus.</p>
	  </div>
	  <div id="tabs-2">
	    <p>Morbi tincidunt, dui sit amet facilisis feugiat, odio metus gravida ante, ut pharetra massa metus id nunc. Duis scelerisque molestie turpis. Sed fringilla, massa eget luctus malesuada, metus eros molestie lectus, ut tempus eros massa ut dolor. Aenean aliquet fringilla sem. Suspendisse sed ligula in ligula suscipit aliquam. Praesent in eros vestibulum mi adipiscing adipiscing. Morbi facilisis. Curabitur ornare consequat nunc. Aenean vel metus. Ut posuere viverra nulla. Aliquam erat volutpat. Pellentesque convallis. Maecenas feugiat, tellus pellentesque pretium posuere, felis lorem euismod felis, eu ornare leo nisi vel felis. Mauris consectetur tortor et purus.</p>
	  </div>
	  <div id="tabs-3">
	    <p>Mauris eleifend est et turpis. Duis id erat. Suspendisse potenti. Aliquam vulputate, pede vel vehicula accumsan, mi neque rutrum erat, eu congue orci lorem eget lorem. Vestibulum non ante. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Fusce sodales. Quisque eu urna vel enim commodo pellentesque. Praesent eu risus hendrerit ligula tempus pretium. Curabitur lorem enim, pretium nec, feugiat nec, luctus a, lacus.</p>
	    <p>Duis cursus. Maecenas ligula eros, blandit nec, pharetra at, semper at, magna. Nullam ac lacus. Nulla facilisi. Praesent viverra justo vitae neque. Praesent blandit adipiscing velit. Suspendisse potenti. Donec mattis, pede vel pharetra blandit, magna ligula faucibus eros, id euismod lacus dolor eget odio. Nam scelerisque. Donec non libero sed nulla mattis commodo. Ut sagittis. Donec nisi lectus, feugiat porttitor, tempor ac, tempor vitae, pede. Aenean vehicula velit eu tellus interdum rutrum. Maecenas commodo. Pellentesque nec elit. Fusce in lacus. Vivamus a libero vitae lectus hendrerit hendrerit.</p>
	  </div>
	</div>
	--->

	</div>
</div>
<!--- 	<cfdump var="#completed#"> --->
<cfif url.showdump>
 	<cfdump var="#temp2#" label="All of It">
 	<cfdump var="#getTheHours#" label="getTheHours">
 	<cfdump var="#isResolved#" label="isResolved by Developer">
 	<cfdump var="#issueByType#" label="Issue By Type">
 	<cfdump var="#completedByDev#" label="Completed by Developer">
 	<cfdump var="#hoursByDev#" label="Hours by Developer">
 	<cfdump var="#hrsByDev#" label="Completed by Developer">
 	<cfdump var="#qoq1#" label="Hours by Developer">
 	<cfdump var="#getNew#" label="Get New">
</cfif>
</body>
</html>
<!--- <cfif url.dspRpt>
	</cfdocument>
</cfif> --->