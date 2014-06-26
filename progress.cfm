<cfparam name="url.showdump" default="0">
<cfparam name="url.dspRpt" default="0">
<cfparam name="url.useMonth" default="4">


<cffunction name="getEpicsOld">

	<cfquery name="getAllEpics" datasource="jira">
		SELECT projectversion.id theProj, vname, CF.stringValue EpicName, jiraissue.*
		  FROM projectversion, nodeassociation, jiraissue
		  LEFT JOIN customfieldvalue CF
		    ON CF.ISSUE = jiraissue.ID
		   AND CF.customfield = 10004
		 WHERE ASSOCIATION_TYPE = 'IssueFixVersion'
		   AND SINK_NODE_ID = projectversion.id
		   AND SOURCE_NODE_ID = jiraissue.id
		   AND ISSUETYPE = 10000
	</cfquery>
	<cfreturn getAllEpics>
</cffunction>

<cffunction name="getEpics">
	<cfscript>
		local = [];
	</cfscript>
	<cfquery name="local.getData" datasource="jira" >
		SELECT *
		  FROM (
		SELECT projectversion.id theProj, vname, IT.Pname IssueType, IL.Source theParent, IL.Destination theChild, CF.stringValue EpicName,
        JI.ID, JI.Issuenum, JI.Assignee, JI.Summary, JI.Description, JI.Priority, JI.Resolution, JI.ResolutionDate,
        ISt.PName IssueStatus, JI.Created, JI.DueDate, JI.TIMEORIGINALESTIMATE, JI.TIMEESTIMATE, JI.TIMESPENT,
        JI.WORKFLOW_ID
		  FROM projectversion, nodeassociation, jiraissue JI
		  LEFT JOIN customfieldvalue CF
		    ON CF.ISSUE = JI.ID
		   AND CF.customfield = 10004 -- Defines it as V1
      LEFT JOIN issuelink IL
        ON IL.Destination = JI.ID
      LEFT JOIN ISSUETYPE IT
        ON IT.ID = JI.ISSUETYPE
      LEFT JOIN ISSUESTATUS ISt
        ON ISt.ID = JI.ISSUESTATUS
      LEFT JOIN issuelinktype ILT
        ON ILT.ID = IL.LINKTYPE
		 WHERE ASSOCIATION_TYPE = 'IssueFixVersion'
		   AND SINK_NODE_ID = projectversion.id
		   AND SOURCE_NODE_ID = JI.id
	   ) DATA
	 WHERE IssueType = 'Epic'
	 ORDER BY ID
	</cfquery>
	<cfreturn local.getData>
</cffunction>

<cffunction name="getAllStories">
    <cfargument name="theEpic">

	<cfquery name="getStories" datasource="jira">
  SELECT projectversion.id theProj, vname, CF.stringValue EpicName, jiraissue.*
  FROM projectversion, nodeassociation, jiraissue
  LEFT JOIN customfieldvalue CF
    ON CF.ISSUE = jiraissue.ID
   AND CF.customfield = 10004
  LEFT JOIN issuelink IL
    ON IL.Destination = jiraissue.ID
 WHERE ASSOCIATION_TYPE = 'IssueFixVersion'
   AND IL.Source = <cfqueryparam  value="#arguments.theEpic#">
   AND SINK_NODE_ID = projectversion.id
   AND SOURCE_NODE_ID = jiraissue.id
   AND ISSUETYPE = 10001


	<!---
		select Story.*
		  FROM jiraissue Story
		  LEFT JOIN issuelink IL
		    ON IL.Destination = Story.ID
		 WHERE IL.Source = <cfqueryparam  value="#arguments.theEpic#">
		 ORDER BY IssueNum --->
	</cfquery>
	<cfreturn getStories>
</cffunction>

<cffunction name="getSubTasks">
    <cfargument name="theParent">

	<cfquery name="getTheSubTasks" datasource="jira">
 SELECT *
   FROM (
 SELECT projectversion.id theProj, vname, CF.stringValue EpicName, jiraissue.*
  FROM projectversion, nodeassociation, jiraissue
  LEFT JOIN customfieldvalue CF
    ON CF.ISSUE = jiraissue.ID
   AND CF.customfield = 10004
 WHERE ASSOCIATION_TYPE = 'IssueFixVersion'
   AND SINK_NODE_ID = projectversion.id
   AND SOURCE_NODE_ID = jiraissue.id
   AND ISSUETYPE <> 10000 ) D
 WHERE ID IN (
SELECT Destination
  FROM issuelink
 WHERE LinkType = 10100
   AND source = <cfqueryparam  value="#arguments.theParent#">
 )
		 ORDER BY IssueNum


	</cfquery>
	<cfreturn getTheSubTasks>
</cffunction>



<cfscript>
	function is_Null(x){
		if(!len(x))
			return 0;
		else
			return x;
	}
	epicSummary = "";
	gtotOEst = 0;
	gtotTimeEst = 0;
	gtotTimeSpent = 0;
	gtotHrsRemaining = 0;
	theSparklines = "";

	mayHours = 394;
	juneHours = 179;

</cfscript>


	<!doctype html>
	<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>TCs Development</title>
		<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
		<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/jquery-ui.min.js"></script>
		<script src="assets/scripts/highcharts.js"></script>
		<script src="assets/scripts/highcharts-3d.js"></script>
		<script src="assets/scripts/sparklines.js"></script>

		<link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/themes/smoothness/jquery-ui.css" />
		<link rel="stylesheet" href="assets/css/style.css">
		<link rel="stylesheet" href="assets/css/table.css">
		<link rel="stylesheet" href="assets/css/print.css" type="text/css" media="print" />

		<link rel="stylesheet" type="text/css" href="assets/css/font-awesome.min.css"/>

	</head>
	<body>
	<div id="container">
		<div id="header">
			<img src="assets/images/TransConnect_400_48.png" width="400" height="48"><i class="fa fa-star-o"></i>
		</div>
		<div id="navigation">
			<cfoutput>
			<ul>
				<li><a href="/tcsreports/report.cfm">Home</a></li>
				<li><cfif url.showdump><a href="?useMonth=#dateformat(dateAdd("m",-1,now()),"m")#&showdump=0">No Debug<cfelse>
				<a href="?useMonth=#dateformat(dateAdd("m",-1,now()),"m")#&showdump=1">Debug</cfif></a></li>
			</ul>
			</cfoutput>
		</div>

		<div id="content">

		<cfset theEpics = getEpics()>

<cfsavecontent variable="theDetails">
<table class="tsc_table_s3" summary="Issues Completed" style="width:100%;">
<cfoutput query="theEpics">
	<thead>
		<tr style=" background:##4F76A3;">
			<th scope="col" style="font-weight: 900;color: black;background:##FDC835;">Epic</th>
			<th scope="col" colspan="5" style="font-weight: 900;color: black;background:##FDC835;">#EpicName# [<a href="http://issues.tcs/browse/DEV-#issueNum#" target="_blank">DEV-#issueNum#</a>]</th>
		</tr>

		<tr>
			<th scope="col">Summary</th>
			<!--- <th scope="col">Description</th> --->
			<th scope="col">Created</th>
			<th scope="col">Updated</th>
			<th scope="col">Est (Hrs)</th>
			<th scope="col">Spent (Hrs)</th>
			<th scope="col">Completed</th>
		</tr>
	</thead>

 	<tbody>
		<cfscript>
			totOEst = 0;
			totTimeEst = 0;
			totTimeSpent = 0;
			totOEsts = 0;
			totTimeEsts = 0;
			totTimeSpents = 0;
			theStories = getAllStories(id);
			totalOrigWeeks = 0;
			totalEstimatedWeeks = 0;
			totalTimeSpent = 0;
			totHrsRemaining = 0;
		</cfscript>

<!--- // Stories // --->
		<cfloop query="theStories">
			<cfsavecontent variable="storyP1">
			<tr>
				<td style="font-weight: bold;">[<a href="http://issues.tcs/browse/DEV-#theStories.issueNum#" target="_blank">DEV-#theStories.issueNum#</a>] #theStories.Summary#</td>
				<td nowrap="1" style="font-weight: bold;">#DateTimeFormat(theStories.created,"mm/dd/yy")#</td>
				<td nowrap="1" style="font-weight: bold;">#DateTimeFormat(theStories.updated,"mm/dd/yy hh:mm aaa")#</td>
			</cfsavecontent>
			<cfsavecontent variable="storyP2">
				<td style="font-weight: bold;">#val(is_Null(theStories.TIMEORIGINALESTIMATE)/60/60)#</td>
				<td style="font-weight: bold;">#val(is_Null(theStories.timespent)/60/60)#</td>
				<td><cfif len(RESOLUTIONDATE)>X</cfif></td>
			</tr>
			</cfsavecontent>
			<cfscript>
				totOEst += is_Null(theStories.TIMEORIGINALESTIMATE);
				totTimeEst += is_Null(theStories.TIMEESTIMATE);
				totTimeSpent += is_Null(theStories.timespent);
				theSubTasks = getSubTasks(theStories.id);
				hasSubTasks = 0;

				if (is_Null(theStories.timespent) LT is_Null(theStories.TIMEORIGINALESTIMATE))
					totHrsRemaining += is_Null(theStories.TIMEORIGINALESTIMATE)-is_Null(theStories.timespent);

			</cfscript>

<!--- // Sub Tasks // --->
			<cfif theSubTasks.recordcount>
				<cfscript>
					totOEsts = 0;
					totTimeEsts = 0;
					totTimeSpents = 0;
				</cfscript>
				<cfsavecontent variable="tasks">
					<cfloop query="theSubTasks">
						<tr<cfif len(RESOLUTIONDATE)> style="background-color: ##00CC00;"</cfif>>
							<td class="st" align="right">#theSubTasks.Summary# [<a href="http://issues.tcs/browse/DEV-#theSubTasks.issueNum#" target="_blank">DEV-#theSubTasks.issueNum#</a>]</td>
							<td nowrap="1">#DateTimeFormat(theSubTasks.created,"mm/dd/yy")#</td>
							<td nowrap="1">#DateTimeFormat(theSubTasks.updated,"mm/dd/yy hh:mm aaa")#</td>
							<td>#val(is_Null(theSubTasks.TIMEORIGINALESTIMATE)/60/60)#</td>
							<td>#val(is_Null(theSubTasks.timespent)/60/60)#</td>
							<td><cfif len(RESOLUTIONDATE)>X</cfif></td>
						</tr>
						<cfscript>
							totOEsts += is_Null(theSubTasks.TIMEORIGINALESTIMATE);
							totTimeEsts += is_Null(theSubTasks.TIMEESTIMATE);
							totTimeSpents += is_Null(theSubTasks.timespent);
							hasSubTasks = 1;

							if (is_Null(theStories.TIMEORIGINALESTIMATE))
								totOEst += is_Null(theStories.TIMEORIGINALESTIMATE);
							else
								totOEst += is_Null(theSubTasks.TIMEORIGINALESTIMATE);

							if (is_Null(theStories.TIMEESTIMATE))
								totTimeEst += is_Null(theStories.TIMEESTIMATE);
							else
								totTimeEst += is_Null(theSubTasks.TIMEESTIMATE);

							if (is_Null(theStories.timespent))
								totTimeSpent += is_Null(theStories.timespent);
							else
								totTimeSpent += is_Null(theSubTasks.timespent);
							if (!len(RESOLUTIONDATE) AND (is_Null(theSubTasks.timespent) LT is_Null(theSubTasks.TIMEORIGINALESTIMATE)))
								totHrsRemaining += is_Null(theSubTasks.TIMEORIGINALESTIMATE)-is_Null(theSubTasks.timespent);

							// gtotHrsRemaining += totHrsRemaining;
						</cfscript>
					</cfloop>
				</cfsavecontent>

				<cfif hasSubTasks>
				<cfsavecontent variable="storyP2">
						<td style="font-weight: bold;">#val(is_Null(theStories.TIMEESTIMATE)/60/60)#/#val(is_Null(totOEsts)/60/60)#</td>
						<td style="font-weight: bold;">#val(is_Null(theStories.timespent)/60/60)#/#val(is_Null(totTimeSpents)/60/60)#</td>
						<td>&nbsp;</td>
					</tr>
				</cfsavecontent>
				</cfif>
			</cfif>

			#storyP1#
			#storyP2#
			#tasks#
			<cfscript>
				storyP1 = "";
				storyP2 = "";
				tasks = "";
				hasSubTasks = 0;
			</cfscript>
		</cfloop>

<!--- // Totals // --->
		<tr class="total">
			<td align="right"> Totals</td>
			<td>Days : #val(is_Null(totOEst)/60/60/8)#</td>
			<td>Weeks : #val(is_Null(totOEst)/60/60/8/5)#</td>
			<td>#val(is_Null(totOEst)/60/60)#</td>
			<td>#val(is_Null(totTimeSpent)/60/60)#</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td colspan="6"><img src="assets/images/pixel.gif" width="400" height="12"></td>
		</tr>
		<cfsavecontent variable="thisEpicSummary">
		<tr>
			<td style=" background:##FDC835;font-weight: bold;">#EpicName# </td>
			<td>#val(is_Null(totOEst)/60/60/8/5)#</td>
			<td>#val(is_Null(totOEst)/60/60/8)#</td>
			<td>#val(is_Null(totOEst)/60/60)#</td>
			<td>#val(is_Null(totTimeSpent)/60/60)#</td>
			<td<cfif totOEst-totTimeSpent LT 0> style="background:##F6ECF0;font-weight: bold; color: ##990000;"</cfif>>#val(is_Null(totOEst-totTimeSpent)/60/60)#</td>
			<td>#val(is_Null(totHrsRemaining)/60/60)#</td>
			<cfset theSparklines &= "$('.#replaceNoCase(EpicName," ","","all")#').sparkline('html', {type: 'pie',width: '20px',height: '20px',sliceColors: ['##009900','##FDC835']});">
			<td><span class='#replaceNoCase(EpicName," ","","all")#'>#val(is_Null(totOEst)/60/60)-val(is_Null(totHrsRemaining)/60/60)#,#val(is_Null(totHrsRemaining)/60/60)#</span></td>
		</tr>
		<cfscript>
			gtotOEst += totOEst;
			gtotTimeEst += totTimeEst;
			gtotTimeSpent += totTimeSpent;
			gtotHrsRemaining += totHrsRemaining;
		</cfscript>
		</cfsavecontent>
		<cfset epicSummary &= thisEpicSummary>
	</cfoutput>
	</tbody>
</cfsavecontent>
<cfoutput>
	<h2> Summary </h2>
<table class="tsc_table_s3" summary="Issues Completed" style="width:100%;">
	<thead>
		<tr>
			<th scope="col">Summary</th>
			<th scope="col">Weeks</th>
			<th scope="col">Days</th>
			<th scope="col">Est (Hrs)</th>
			<th scope="col">Spent (Hrs)</th>
			<th scope="col">Remaining (Hrs)</th>
			<th scope="col">Calc Remaining (Hrs)</th>
		</tr>
	</thead>
	<tbody>#epicSummary#
		<tr class="total">
			<td>Totals </td>
			<td>#val(is_Null(gtotOEst)/60/60/8/5)#</td>
			<td>#val(is_Null(gtotOEst)/60/60/8)#</td>
			<td>#val(is_Null(gtotOEst)/60/60)#</td>
			<td>#val(is_Null(gtotTimeSpent)/60/60)#</td>
			<td>#val(is_Null(gtotOEst-gtotTimeSpent)/60/60)#</td>
			<td>#val(is_Null(gtotHrsRemaining)/60/60)#</td>
			<cfset theSparklines &= "$('.epicTotals').sparkline('html', {type: 'pie',width: '20px',height: '20px',sliceColors: ['##009900','##FDC835']});">
			<td style="background: ##CCCCCC;"><span class='epicTotals'>#val(is_Null(totOEst)/60/60)-val(is_Null(gtotHrsRemaining)/60/60)#,#val(is_Null(gtotHrsRemaining)/60/60)#</span></td>
		</tr>
	</tbody>
</table>
<cfscript>
	devs3 = 40 * 0.7 * 3;
	devs4 = 40 * 0.7 * 4;
	devs5 = 40 * 0.7 * 5;
	loopCnt = 0;
	totHours = round(val(is_Null(gtotOEst)/60/60)*1.2);
	theStartDate = "06/16/2014";
</cfscript>
totHours = #totHours#, devs3 = #devs3#|#devs4#\#devs5#
<cfsavecontent variable="hoursDev3"><cfloop index="a" from="#totHours#" to="0" step="-#devs3#">#a#<cfif a-devs3 GTE 0>, </cfif> <cfset loopCnt += 1></cfloop></cfsavecontent>
<cfsavecontent variable="hoursDev4"><cfloop index="b" from="#totHours#" to="0" step="-#devs4#">#b#<cfif b-devs4 GTE 0>, </cfif> </cfloop></cfsavecontent>
<cfsavecontent variable="hoursDev5"><cfloop index="c" from="#totHours#" to="0" step="-#devs5#">#c#<cfif c-devs5 GTE 0>, </cfif> </cfloop></cfsavecontent>
<cfsavecontent variable="theWeeks"><cfloop index="wk" from="0" to="#loopCnt#" step="1">'#dateFormat(theStartDate+(7*wk),"dd MMM")#'<cfif wk LT loopCnt>, </cfif></cfloop></cfsavecontent>

<div id="jContainer" style="min-width: 310px; height: 400px; margin: 0 auto"></div>
		<br><br>
		<h2> Details </h2>
		#theDetails#
		</cfoutput>

		<cfinclude template="inc/noepic.cfm">
		</div>
	</div>
	<cfinclude template="inc/charts/progress.cfm">
</body>
</html>

<cfif url.showdump>
	<cfdump var="#getEpics()#">
	<cfdump var="#getAllStories(10003)#">
</cfif>