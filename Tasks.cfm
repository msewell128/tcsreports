
<cfquery name="allofit" datasource="jira">
select JI.ID IssueID, IT.PNAME Issue_Type, JI.Summary IssueSummary, JI.ISSUENUM IssueNum, '==' theIssue,
  ILDest.ID IssueDestID, JI.DESCRIPTION IssueDescription, ILSource.ID SourceID, ILSource.DESTINATION, ILSource.SEQUENCE,
  SubTask.id TaskID, SubTask.IssueNum SubID, SubTask.Summary TaskSummary, SubTask.Description TaskDecription, ST_Status.pname

  FROM jiraissue JI
  LEFT Join ISSUETYPE IT
    ON IT.id = JI.ISSUETYPE
  LEFT JOIN RESOLUTION R
    ON R.ID = JI.RESOLUTION
  LEFT JOIN ISSUESTATUS IST
    ON IST.ID = JI.ISSUESTATUS
  LEFT JOIN ISSUELINK ILDest
    ON ILDest.DESTINATION = JI.ID
  LEFT JOIN ISSUELINK ILSource
    ON ILSource.SOURCE = JI.ID
  LEFT JOIn JIRAISSUE SubTask
    ON ILSource.DESTINATION = SubTask.ID
  LEFT JOIN ISSUESTATUS ST_Status
    ON ST_Status.ID = SubTask.ISSUESTATUS
 WHERE JI.Project = 10103
   AND ILSource.ID IS NOT NULL
ORDER BY JI.ID, Sequence
</cfquery>

<cfdocument format="pdf">
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>TCs Development</title>
  <link rel="stylesheet" href="//code.jquery.com/ui/1.10.4/themes/ui-lightness/jquery-ui.css">
  <script src="//code.jquery.com/jquery-1.10.2.js"></script>
  <script src="//code.jquery.com/ui/1.10.4/jquery-ui.js"></script>
  <link rel="stylesheet" href="/resources/demos/style.css">
  <link rel="stylesheet" href="style.css">

  <script>
  $(function() {
    $( "#tabs" ).tabs();
  });
  </script>
</head>
<body>
	<div id="wrapper">
		<div id="header">
			<img src="images/TransConnect.png" width="190" height="35">
		</div>


		<div id="content">
		<table border="1">
		<cfoutput query="allofit" group="issueID">
			<tr>
				<th>#Issue_Type#</th>
				<th colspan="2">#IssueNum#</th>
				<th colspan="2">#IssueSummary#</th>
			</tr>
			<cfoutput>
				<tr>
					<td>#TaskID#</td>
					<td>#IssueNum#</td>
					<td>#subid#</td>
					<td>#PName#</td>
					<td>#TaskSummary#</td>
				</tr>
				<tr>
					<td colspan="4">&nbsp;</td>
					<td>#TaskDecription#</td>
				</tr>
			</cfoutput>

		</cfoutput>
		</table>
		</div>
	<!--- 	<cfdump var="#completed#"> --->
	 	<!--- <cfdump var="#allofit#"> --->
	</div>
</body>
</html>
</cfdocument>