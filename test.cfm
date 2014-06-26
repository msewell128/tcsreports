<cfparam name="url.showdump" default="0">
<cfparam name="url.dspRpt" default="0">
<cfparam name="url.useMonth" default="4">

<cfscript>
	function is_Null(x){
		if(!len(x))
			return 0;
		else
			return x;
	}

	function weekStartDate(weekNum,weekYear) {
	    var weekDate = dateAdd("WW",weekNum-1,"1/1/" & weekYear);
	    var toDay1 = dayofweek(weekDate)-1;
	    var weekStartDate = dateAdd("d",-toDay1,weekDate);
	    if(arrayLen(arguments) gte 3 and arguments[3]) weekStartDate = dateAdd("d",1,weekStartDate);
	    return weekStartDate;
	}

	function RoundUpDown(input){
	  var roundval = 5;
	  var direction = "Up";
	  var result = 0;

	  if(ArrayLen(arguments) GTE 2)
	    roundval = arguments[2];
	  if(ArrayLen(arguments) GTE 3)
	    direction = arguments[3];
	  if(roundval EQ 0)
	    roundval = 1;

	  if((input MOD roundval) NEQ 0){
	     if((direction IS 1) OR (direction IS "Up")){
	      result = input + (roundval - (input MOD roundval));
	     }else{
	      result = input - (input MOD roundval);
	     }
	  }else{
	    result = input;
	  }
	  return result;
	}
	epicSummary = "";
	gtotOEst = 0;
	gtotTimeEst = 0;
	gtotTimeSpent = 0;
	gtotHrsRemaining = 0;
	theSparklines = "";
	eAllDetail = "";

	theCnt = 0;
	eSummaryAll = "";

	mayHours = 394;
	juneHours = 179;

	totDaysSumm = 0;
	totWeeksSumm = 0;
	totHrsSumm = 0;
	totUsedSumm = 0;
	totRemSumm = 0;
	totHrsRemainSumm = 0;
	allDetailNoEpic = "";

	summaryArray = ArrayNew(1);
	epicList = "";

	myObj = createObject("component", "inc.jReport");

	// getHrsByWk = myObj.hrsByWeek();

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


</head>
<body>
	<div id="container">
		<div id="header">
			<a name="top"></a>
			<img src="assets/images/TransConnect_400_48.png" width="400" height="48"><i class="fa fa-star-o"></i>
		</div>
		<div id="navigation">
			<cfoutput>
			<ul>
				<li><a href="/tcsreports/report.cfm">Home</a></li>
				<li><cfif url.showdump><a href="?useMonth=#dateformat(dateAdd("m",-1,now()),"m")#&showdump=0">No Debug<cfelse>
				<a href="?useMonth=#dateformat(dateAdd("m",-1,now()),"m")#&showdump=1">Debug</cfif></a></li>
			<!--- 	<li>#dateFormat(now(),"DD-MMM YYYY")# #timeFormat(now(),"medium")#</li> --->
			</ul>
			</cfoutput>
		</div>

		<div id="content">

			<cfset theEpics = myObj.getEpics()>
			<cfoutput query="theEpics">
				<cfsavecontent variable="eDetail">
				<thead>
					<tr style=" background:##4F76A3;">
						<th scope="col" style="font-weight: 900;color: black;background:##FDC835;">[<a href="##top">Top</a>]</th>
						<th scope="col" colspan="2" style="font-weight: 900;color: black;background:##FDC835;">Epic<a name="#replaceNoCase(EpicName," ","_","all")#"></th>
						<th scope="col" colspan="5" style="font-weight: 900;color: black;background:##FDC835;">#EpicName# [<a href="http://issues.tcs/browse/DEV-#issueNum#" target="_blank">DEV-#issueNum#</a>]</th>
					</tr>

					<tr>
						<th scope="col" colspan="3">Summary</th>
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
						totalOrigWeeks = 0;
						totalEstimatedWeeks = 0;
						totalTimeSpent = 0;
						totHrsRemaining = 0;
					</cfscript>

			<!--- // Children of Epic // --->
					<cfset aChildren = myObj.getChildren(id)>
					<cfif aChildren.recordcount>
						<cfloop query="aChildren">
						<cfscript>
							// Account for Resolved with no time logged
							useTimeSpent = val(is_Null(aChildren.timespent));
							if(len(aChildren.RESOLUTIONDATE) AND val(aChildren.timespent) EQ 0)
								useTimeSpent = is_Null(aChildren.TIMEORIGINALESTIMATE);


							totOEsts += is_Null(aChildren.TIMEORIGINALESTIMATE);
							totTimeEsts += is_Null(aChildren.TIMEESTIMATE);
							totTimeSpents += is_Null(useTimeSpent);
							hasSubTasks = 1;

							//
							if (is_Null(aChildren.TIMEORIGINALESTIMATE))
								totOEst += is_Null(aChildren.TIMEORIGINALESTIMATE);
							else
								totOEst += is_Null(useTimeSpent);

							if (is_Null(aChildren.TIMEESTIMATE))
								totTimeEst += is_Null(aChildren.TIMEESTIMATE);
							else
								totTimeEst += is_Null(aChildren.TIMEESTIMATE);

							//
							if(len(aChildren.RESOLUTIONDATE) AND !(is_Null(aChildren.timespent)))
								totTimeSpent += is_Null(useTimeSpent);

							if (!len(RESOLUTIONDATE) AND (is_Null(aChildren.timespent) LT is_Null(aChildren.TIMEORIGINALESTIMATE)))
								totHrsRemaining += is_Null(aChildren.TIMEORIGINALESTIMATE)-is_Null(useTimeSpent);
						</cfscript>
						<tr<cfif len(aChildren.RESOLUTIONDATE)> style="background-color: ##00DD00;"</cfif>>
							<!--- <td>&nbsp;</td> --->
							<td colspan="3" style="font-weight: bold;">[<a href="http://issues.tcs/browse/DEV-#aChildren.issueNum#" target="_blank">DEV-#aChildren.issueNum#</a>] #aChildren.Summary#</td>
							<td nowrap="1" style="font-weight: bold;">#DateTimeFormat(aChildren.created,"mm/dd/yy")#</td>
							<td nowrap="1" style="font-weight: bold;">#DateTimeFormat(aChildren.updated,"mm/dd/yy hh:mm aaa")#</td>
							<td style="font-weight: bold;">#val(is_Null(aChildren.TIMEORIGINALESTIMATE)/60/60)#</td>
							<td style="font-weight: bold;">#useTimeSpent/60/60#</td>
							<td><cfif len(aChildren.RESOLUTIONDATE)>X</cfif></td>
						</tr>

						<!--- // Get Children of Children // --->
						<cfset bChildren = myObj.getChildren(aChildren.id)>
						<cfif bChildren.recordcount>
							<cfloop query="bChildren">
								<cfscript>
									myA = val(is_Null(totOEst)/60/60); // Debug

									useTimeSpentB = val(is_Null(bChildren.timespent));
									if(len(bChildren.RESOLUTIONDATE) AND val(bChildren.timespent) EQ 0)
										useTimeSpentB = is_Null(bChildren.TIMEORIGINALESTIMATE);

									totOEsts += is_Null(bChildren.TIMEORIGINALESTIMATE);

									myB = val(is_Null(totOEst)/60/60); // Debug

									totTimeEsts += is_Null(bChildren.TIMEESTIMATE);
									totTimeSpents += is_Null(useTimeSpentB);
									hasSubTasks = 1;

									if (is_Null(bChildren.TIMEORIGINALESTIMATE))
										totOEst += is_Null(bChildren.TIMEORIGINALESTIMATE);
									else
										totOEst += useTimeSpentB;

									myC = val(is_Null(totOEst)/60/60); // Debug

									if (is_Null(aChildren.TIMEESTIMATE))
										totTimeEst += is_Null(aChildren.TIMEESTIMATE);
									else
										totTimeEst += is_Null(bChildren.TIMEESTIMATE);

									if (is_Null(aChildren.timespent))
										totTimeSpent += is_Null(useTimeSpentB);
									else
										totTimeSpent += is_Null(bChildren.timespent);
									if (!len(RESOLUTIONDATE) AND (is_Null(bChildren.timespent) LT is_Null(bChildren.TIMEORIGINALESTIMATE)))
										totHrsRemaining += is_Null(bChildren.TIMEORIGINALESTIMATE)-is_Null(useTimeSpentB);
									myD = val(is_Null(totOEst)/60/60); // Debug

									// gtotHrsRemaining += totHrsRemaining;
								</cfscript>
								<tr<cfif len(RESOLUTIONDATE)> style="background-color: ##00DD00;"</cfif>>
									<td><img src="assets/images/pixel.gif" width="10" height="3"></td>
									<td colspan="2" style="font-weight: normal;">[<a href="http://issues.tcs/browse/DEV-#bChildren.issueNum#" target="_blank">DEV-#bChildren.issueNum#</a>] #bChildren.Summary#</td>
									<td nowrap="1" style="font-weight: normal;">#DateTimeFormat(bChildren.created,"mm/dd/yy")#</td>
									<td nowrap="1" style="font-weight: normal;">#DateTimeFormat(bChildren.updated,"mm/dd/yy hh:mm aaa")#</td>
									<td style="font-weight: normal;">#val(is_Null(bChildren.TIMEORIGINALESTIMATE)/60/60)#</td>
									<td style="font-weight: normal;">#val(useTimeSpentB/60/60)#</td>
									<td><cfif len(bChildren.RESOLUTIONDATE)>X</cfif></td>
								</tr>
							</cfloop>
						</cfif>
						</cfloop>
					</cfif>
					<tr class="total">
						<td align="right" colspan="3"> Totals</td>
						<td>Days : #val(is_Null(totOEst)/60/60/8)#</td>
						<td>Weeks : #round(val(is_Null(totOEst)/60/60/8/5))#</td>
						<td>#val(is_Null(totOEst)/60/60)#</td>
						<td>#val(is_Null(totTimeSpents)/60/60)#</td>
						<td>&nbsp;</td>
					</tr>
					<tr style="border : 0px solid ##000;">
						<td colspan="8"><img src="assets/images/pixel.gif" width="400" height="12"></td>
					</tr>
				</tbody>
				</cfsavecontent>
				<cfset eAllDetail &= eDetail>



				<cfsavecontent variable="eSummary">
				<thead>
					<tr>
						<td scope="col" style="font-weight: 900;">#currentrow#</td>
						<td scope="col" style="font-weight: 900;">#EpicName# [<a href='###replaceNoCase(EpicName," ","_","all")#'>Detail</a>] [<a href="http://issues.tcs/browse/DEV-#issueNum#" target="_blank">DEV-#issueNum#</a>]</td>
						<td>#numberFormat(val(is_Null(totOEst)/60/60/8),"999.99")#</td>
					<!--- 	<td>#val(is_Null(totOEst)/60/60/8/5)#</td> --->
						<td>#val(is_Null(totOEst)/60/60)#</td>
						<td>#val(is_Null(totTimeSpents)/60/60)#</td>
						<td<cfif totOEst-totTimeSpent LT 0> style="background:##F6ECF0;font-weight: bold; color: ##990000;"</cfif>>#val(is_Null(totOEst)/60/60)-val(is_Null(totTimeSpents)/60/60)#</td>
						<td>#val(is_Null(totHrsRemaining)/60/60)#</td>
						<cfset theSparklines &= "$('.#replaceNoCase(EpicName," ","","all")#').sparkline('html', {type: 'pie',width: '20px',height: '20px',sliceColors: ['##009900','##FDC835']});">
						<td><span class='#replaceNoCase(EpicName," ","","all")#'>#val(is_Null(totOEst)/60/60)-val(is_Null(totHrsRemaining)/60/60)#,#val(is_Null(totHrsRemaining)/60/60)#</span></td>
					</tr>
				</thead>
				</cfsavecontent>

				<cfscript>
					eSummaryAll &= eSummary;
					ArrayAppend(summaryArray, "#val(is_Null(totTimeSpents)/60/60)#,#val(is_Null(totHrsRemaining)/60/60)#");
					epicList = listappend(epicList,"'"&currentRow&" - "&EpicName&"'");
					totDaysSumm += val(is_Null(totOEst)/60/60/8);
					totWeeksSumm += round(val(is_Null(totOEst)/60/60/8/5));
					totHrsSumm += val(is_Null(totOEst)/60/60);
					totUsedSumm += val(is_Null(totTimeSpents)/60/60);
					totRemSumm += val(is_Null(totOEst)/60/60)-val(is_Null(totTimeSpents)/60/60);
					totHrsRemainSumm += val(is_Null(totHrsRemaining)/60/60);
					completed = "";
					notCompleted = "";
				</cfscript>
			</cfoutput>

			<cfloop from="1" to="#arrayLen(summaryArray)#" index="i">
				<cfset completed = listappend(completed,listGetAt(summaryArray[i],1))>
				<cfset notCompleted = listappend(notCompleted,listGetAt(summaryArray[i],2))>
			</cfloop>


			<cfscript>

				devs3 = 40 * 0.7 * 3;
				devs4 = 40 * 0.7 * 4;
				devs5 = 40 * 0.7 * 5;
				loopCnt = 0;
				totHours = round(val(is_Null(gtotOEst)/60/60)*1.2);
				theStartDate = "06/16/2014";
			</cfscript>




	<!--- // No Epics // --->
			<cfset noEpics = myObj.getNoEpics()>
			<cfsavecontent variable="eDetailNoEpicHdr">
			<thead>
				<tr style=" background:#4F76A3;">
					<th scope="col" colspan="3" style="font-weight: 900;color: black;background:#FDC835;">No Epic</th>
					<th scope="col" colspan="5" style="font-weight: 900;color: black;background:#FDC835;"></th>
				</tr>

				<tr>
					<th scope="col" colspan="3">Summary</th>
					<th scope="col">Created</th>
					<th scope="col">Updated</th>
					<th scope="col">Est (Hrs)</th>
					<th scope="col">Spent (Hrs)</th>
					<th scope="col">Completed</th>
				</tr>
			</thead>
			</cfsavecontent>


			<cfscript>
				totOEst = 0;
				totTimeEst = 0;
				totTimeSpent = 0;
				totOEsts = 0;
				totTimeEsts = 0;
				totTimeSpents = 0;
				totalOrigWeeks = 0;
				totalEstimatedWeeks = 0;
				totalTimeSpent = 0;
				totHrsRemaining = 0;
			</cfscript>

			<cfoutput query="noEpics">
				<cfsavecontent variable="eDetailNoEpic">


			 	<tbody>
					<cfscript>
						totTimeEst = 0;
						totTimeSpent = 0;
						totOEsts = 0;
						totTimeEsts = 0;
						totalOrigWeeks = 0;
						totalEstimatedWeeks = 0;
						totalTimeSpent = 0;
						totHrsRemaining = 0;

							useTimeSpent = val(is_Null(timespent));

							if(len(RESOLUTIONDATE) AND val(timespent) EQ 0)
								useTimeSpent = is_Null(TIMEORIGINALESTIMATE);

							totOEsts += is_Null(TIMEORIGINALESTIMATE);
							totTimeEsts += is_Null(TIMEESTIMATE);
							totTimeSpents += is_Null(useTimeSpent);

							if (is_Null(TIMEORIGINALESTIMATE))
								totOEst += is_Null(TIMEORIGINALESTIMATE);
							else
								totOEst += is_Null(TIMEORIGINALESTIMATE);

							if (is_Null(TIMEESTIMATE))
								totTimeEst += is_Null(TIMEESTIMATE);
							else
								totTimeEst += is_Null(TIMEESTIMATE);


							if(len(RESOLUTIONDATE) AND !(is_Null(timespent)))
								totTimeSpent += is_Null(useTimeSpent);

							if (!len(RESOLUTIONDATE) AND (is_Null(timespent) LT is_Null(TIMEORIGINALESTIMATE)))
								totHrsRemaining += is_Null(TIMEORIGINALESTIMATE)-is_Null(useTimeSpent);




						</cfscript>
						<tr<cfif len(RESOLUTIONDATE)> style="background-color: ##00DD00;"</cfif>>
							<!--- <td>&nbsp;</td> --->
							<td colspan="3" style="font-weight: bold;">[<a href="http://issues.tcs/browse/DEV-#issueNum#" target="_blank">DEV-#issueNum#</a>] #Summary#</td>
							<td nowrap="1" style="font-weight: bold;">#DateTimeFormat(created,"mm/dd/yy")#</td>
							<td nowrap="1" style="font-weight: bold;">#DateTimeFormat(updated,"mm/dd/yy hh:mm aaa")#</td>
							<td style="font-weight: bold;">#val(is_Null(TIMEORIGINALESTIMATE)/60/60)#</td>
							<td style="font-weight: bold;">#useTimeSpent/60/60#</td>
							<td><cfif len(RESOLUTIONDATE)>X</cfif></td>
						</tr>
					</cfsavecontent>
					<cfset allDetailNoEpic &= eDetailNoEpic>
				</cfoutput>
				<cfscript>
					completed = listappend(completed,val(is_Null(totTimeSpents)/60/60));
					notCompleted = listappend(notCompleted,val(is_Null(totHrsRemaining)/60/60));
				</cfscript>
				<cfsavecontent variable="neTotal">
				<cfoutput>
					<tr class="total">
						<td align="right" colspan="3"> Totals</td>
					<!--- 	<td>Weeks : #round(val(is_Null(totOEst)/60/60/8/5))#</td> --->
						<td>Days : #val(is_Null(totOEst)/60/60/8)#</td>
						<td>#val(is_Null(totOEst)/60/60)#</td>
						<td>#val(is_Null(totTimeSpents)/60/60)#</td>
						<td>&nbsp;</td>
					</tr>
				</cfoutput>
				</cfsavecontent>
				<cfset eAllDetail &= eDetailNoEpicHdr & allDetailNoEpic & neTotal>

				<cfsavecontent variable="neSummary">
				<cfoutput>
				<thead>
					<tr>
						<td scope="col" style="font-weight: 900;">#theEpics.recordcount+1#</td>
						<td scope="col" style="font-weight: 900;">No Epic</td>
						<!--- 	<td>#val(is_Null(totOEst)/60/60/8/5)#</td> --->
						<td>#numberFormat(val(is_Null(totOEst)/60/60/8),"9999.99")# d</td>
						<td>#val(is_Null(totOEst)/60/60)#</td>
						<td>#val(is_Null(totTimeSpents)/60/60)#</td>
						<td<cfif totOEst-totTimeSpent LT 0> style="background:##F6ECF0;font-weight: bold; color: ##990000;"</cfif>>#val(is_Null(totOEst)/60/60)-val(is_Null(totTimeSpents)/60/60)#</td>
						<td>#val(is_Null(totHrsRemaining)/60/60)#</td>
						<cfset theSparklines &= "$('.noEpicSummary').sparkline('html', {type: 'pie',width: '20px',height: '20px',sliceColors: ['##009900','##FDC835']});">
						<td><span class='noEpicSummary'>#val(is_Null(totOEst)/60/60)-val(is_Null(totHrsRemaining)/60/60)#,#val(is_Null(totHrsRemaining)/60/60)#</span></td>
					</tr>
				</thead>
				</cfoutput>
				</cfsavecontent>

				<cfscript>
					totDaysSumm += val(is_Null(totOEst)/60/60/8);
					totWeeksSumm += numberFormat(val(is_Null(totOEst)/60/60/8/5),"999.99");
					totHrsSumm += val(is_Null(totOEst)/60/60);
					totUsedSumm += val(is_Null(totTimeSpents)/60/60);
					totRemSumm += val(is_Null(totOEst)/60/60)-val(is_Null(totTimeSpents)/60/60);
					totHrsRemainSumm += val(is_Null(totHrsRemaining)/60/60);
				</cfscript>


			<table class="tsc_table_s3" summary="Summary" style="width:100%;">
				<thead>
					<tr>
						<cfoutput><th scope="col" colspan="2"> Created: #dateFormat(now(),"DD-MMM YYYY")# #timeFormat(now(),"medium")# </th></cfoutput>
						<th scope="col" colspan="5">Estimated</th>
						<th scope="col" colspan="5">=== Hours ===</th>
					</tr>
					<tr>
						<th scope="col">#</th>
						<th scope="col">Name</th>
					<!--- 	<th scope="col">Weeks</th> --->
						<th scope="col">Days</th>
						<th scope="col">Est</th>
						<th scope="col">Used</th>
						<th scope="col">Est Remain</th>
						<th scope="col">Actual Remain</th>
						<th></th>
					</tr>
				</thead>
				<cfoutput>#eSummaryAll# #neSummary#
				<tr class="total">
					<td colspan="2">Totals</td>
				<!--- 	<td>#val(totWeeksSumm)#</td> --->
					<td>#val(totDaysSumm)# d</td>
					<td>#val(totHrsSumm)#</td>
					<td>#val(totUsedSumm)#</td>
					<td>#val(totHrsSumm-totUsedSumm)#</td>
					<td>#val(totHrsRemainSumm)#</td>
				 	<cfset theSparklines &= "$('.epicTotals').sparkline('html', {type: 'pie',width: '20px',height: '20px',sliceColors: ['##009900','##FDC835']});">
					<td style="background: ##CCCCCC;"><span class='epicTotals'>#val(totHrsSumm)-val(totHrsRemainSumm)#,#val(totHrsRemainSumm)#</span></td>
				</tr>
				</cfoutput>
			</table>

			<div style="width: 100%;">
			 <div style="float: left;  min-width: 825px; height: 400px; margin: 0 auto" id="barChart"></div>
			 <div style="float: left; min-width: 425px; height: 350px; margin: 5px auto" id="hrsByWeek"></div>
			</div>
			<cfscript>
				totalDevWeeks = RoundUpDown((totHrsRemainSumm*1.2) / 28);
				devManWeek = 28;
				DevWeeks3 = totalDevWeeks / 3;
				theStartDate = dateformat(now(),"short");
			</cfscript>

<cfoutput>
<cfsavecontent variable="hoursDev3"><cfloop index="a" from="#RoundUpDown(totHrsRemainSumm*1.2)#" to="0" step="-#devManWeek*3#">#a#<cfif a-DevWeeks3 GTE 0>, </cfif> <cfset loopCnt += 1></cfloop>, 0</cfsavecontent>
<cfsavecontent variable="hoursDev4"><cfloop index="b" from="#RoundUpDown(totHrsRemainSumm*1.2)#" to="0" step="-#devManWeek*4#">#b#<cfif b-(totalDevWeeks/4) GTE 0>, </cfif> </cfloop>0</cfsavecontent>
<cfsavecontent variable="hoursDev5"><cfloop index="b" from="#RoundUpDown(totHrsRemainSumm*1.2)#" to="0" step="-#devManWeek*5#">#b#<cfif b-(totalDevWeeks/5) GTE 0>, </cfif> </cfloop>0</cfsavecontent>

<cfsavecontent variable="theWeeks"><cfloop index="wk" from="0" to="#DevWeeks3#" step="1">'#dateFormat(theStartDate+(7*wk),"dd MMM")#'<cfif wk LT DevWeeks3>, </cfif></cfloop></cfsavecontent>
</cfoutput>

			 <br style="clear: left;" />
			</div>
			<img src="assets/images/pixel.gif" width="800" height="20">

			<div id="jContainer" style="min-width: 250px; height: 300px; margin: 0 auto"></div>

			<img src="assets/images/pixel.gif" width="800" height="20">

			<table class="tsc_table_s3" summary="Detail" style="width:100%;">
				<cfoutput>#eAllDetail#</cfoutput>
			</table>
		</div>
	</div>
	<cfinclude template="inc/charts/jiraCharts.cfm">
</body>
</html>
