<cfcomponent>

	<cffunction name="getEpics">
		<cfscript>
			local = [];
		</cfscript>
		<cfquery name="local.getData" datasource="jira" cachedWithin="#createTimeSpan( 0, 0, 30, 0 )#" >
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
           -- AND ID = 10032
		 ORDER BY ID
		</cfquery>
		<cfreturn local.getData>
	</cffunction>

	<cffunction name="getChildren" cachedWithin="#createTimeSpan( 0, 0, 30, 0 )#">
		<cfargument name="parent">
		<cfscript>
			local = [];
		</cfscript>

		<cfquery name="local.getData" datasource="jira" >
			SELECT *
			  FROM (
			SELECT projectversion.id theProj, vname, IT.Pname IssueType, IL.Source theParent, IL.Destination theChild, CF.stringValue EpicName,
	        JI.ID, JI.Issuenum, JI.Assignee, JI.Summary, JI.Description, JI.Priority, JI.Resolution, JI.ResolutionDate,
	        ISt.PName IssueStatus, JI.Created, JI.DueDate, JI.TIMEORIGINALESTIMATE, JI.TIMEESTIMATE, JI.TIMESPENT,
	        JI.WORKFLOW_ID, JI.UPDATED
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
	       AND IL.LinkType IN(10003,10100, 10200)
		   ) DATA
		 WHERE theParent = <cfqueryparam  value="#arguments.parent#" cfsqltype="CF_SQL_NUMERIC">
		</cfquery>
		<cfreturn local.getData>
	</cffunction>

	<cffunction name="getNoEpics" cachedWithin="#createTimeSpan( 0, 0, 30, 0 )#">
		<cfargument name="parent">
		<cfscript>
			local = [];
		</cfscript>

		<cfquery name="local.getData" datasource="jira" >

			SELECT projectversion.id theProj, vname, IT.Pname IssueType, IL.Source theParent, IL.Destination theChild, CF.stringValue EpicName,
	        JI.ID, JI.Issuenum, JI.Assignee, JI.Summary, JI.Description, JI.Priority, JI.Resolution, JI.ResolutionDate,
	        ISt.PName IssueStatus, JI.Created, JI.DueDate, JI.TIMEORIGINALESTIMATE, JI.TIMEESTIMATE, JI.TIMESPENT,
	        JI.WORKFLOW_ID, JI.UPDATED
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
	       AND JI.IssueNum IN (98,151,295,296,310)
		</cfquery>
		<cfreturn local.getData>
	</cffunction>

	<cffunction name="getWeeklyHours" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
		<cfscript>
			local = [];
		</cfscript>

		<cfquery name="local.getData" datasource="jira" >
			SELECT to_char(updated, 'iw') theWeek, UpdateAuthor, sum(round(timeworked/60/60)) TimeWorked, count(*) dev, max(to_char(updated,'DD-MON')) ldow
			  FROM worklog
			 WHERE Updated >= '01-May-2014'
			 GROUP BY to_char(updated, 'iw'), UpdateAuthor
			 ORDER BY theWeek
		</cfquery>
		<cfreturn local.getData>
	</cffunction>


  <cffunction name="hrsByWeek">
	<cfscript>
		local = [];
	</cfscript>

	<cfquery name="local.getData" datasource="jira" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#" >
		SELECT to_char(updated, 'iw') theWeek  , sum(round(timeworked/60/60)) TimeWorked, count(*) dev, max(to_char(updated,'DD-MON')) fdow
		  FROM worklog
		 WHERE Updated >= '#dateFormat(dateAdd("ww",-8,now()),"dd-MMM-YYYY")#'
		 GROUP BY to_char(updated, 'iw')
		 ORDER BY theWeek
	</cfquery>
	<cfreturn local.getData>
  </cffunction>



</cfcomponent>