
<cfquery name="allofit" datasource="jira">
   	SELECT IT.Pname Issue, ISt.PNAME , P.PNAME Project, JI.Created,
		JI.RESOLUTIONDATE Resolved, TO_CHAR(JI.RESOLUTIONDATE,'MON') resMonth,
		TO_CHAR(JI.RESOLUTIONDATE,'MON dd') ResolvedDate,
    	EXTRACT(month FROM JI.RESOLUTIONDATE) theMonth,
		CASE nvl(JI.Assignee,'None')
			WHEN 'mike.sewell' then 'Mike'
			WHEN 'josh.mabry' then 'Josh'
			WHEN 'larry.wilson' then 'Larry'
			WHEN 'daniel.henderson' then 'Daniel'
			WHEN 'jerry.wallace' then 'Jerry'
			WHEN 'lance.marshall' then 'Lance'
			WHEN 'jeremy.wilcox' then 'Jeremy'
			WHEN 'None' then 'None'
      ELSE 'NA' END who,
		CASE WHEN nvl(JI.TIMESPENT/60/60,0) = 0
			THEN nvl(JI.TIMEORIGINALESTIMATE/60/60,0)
			ELSE nvl(JI.TIMESPENT/60/60,0) END HrsActual,
		(CASE
    WHEN JI.RESOLUTIONDATE IS NULL THEN 0
    ELSE 1 END)  isResolved,
		JI.TIMEORIGINALESTIMATE/60/60 HrsEst, JI.Summary ShortDescr
	  FROM JIRAISSUE JI
	  LEFT JOIN ISSUETYPE IT
	    ON IT.ID = JI.ISSUETYPE
	  LEFT Join PROJECT P
	    ON P.ID = JI.PROJECT
	  LEFT JOIN ISSUESTATUS ISt
	    ON ISt.ID = JI.ISSUESTATUS
	 WHERE UPDATED >= '01-<cfoutput>#theMonth#</cfoutput>-2014'
</cfquery>

<cfquery name="completedByDate" dbtype="query">
SELECT ResolvedDate , count(*) cnt
  FROM allofit
  WHERE Project = 'Development'
    AND Resolved > <cfoutput>#theDate#</cfoutput>
    AND Resolved < <cfoutput>#nextDate#</cfoutput>
	AND theMonth > 3
  GROUP BY ResolvedDate
  ORDER BY ResolvedDate
</cfquery>

<cfquery dbtype="query" name="getTheHoursByUser_base">
	SELECT ShortDescr,ResolvedDate, Project, Who, HrsEst, HrsActual
	  FROM allofit
    WHERE Project <> 'People'
	  AND Who <> 'None'
    AND Resolved > <cfoutput>#theDate#</cfoutput>
    AND Resolved < <cfoutput>#nextDate#</cfoutput>
</cfquery>

<cfquery dbtype="query" name="getTheHours_base">
SELECT ResolvedDate, SUM(HrsActual) HrsActual
  FROM getTheHoursByUser_base
  GROUP BY ResolvedDate
  ORDER BY ResolvedDate
</cfquery>

<cfquery dbtype="query" name="getTheHours">
SELECT *
  FROM getTheHours_base
 WHERE HrsActual > 0
  ORDER BY ResolvedDate
</cfquery>

<cfquery dbtype="query" name="getTheHoursByUser">
SELECT Who, SUM(HrsActual) HrsActual
  FROM getTheHoursByUser_base
  GROUP BY Who
  ORDER BY HrsActual
</cfquery>

<cfquery name="whoCompleted" dbtype="query">
SELECT Who, Count(*) Dun
  FROM allofit
  WHERE Project = 'Development'
    AND Resolved > <cfoutput>#theDate#</cfoutput>
    AND Resolved < <cfoutput>#nextDate#</cfoutput>
	AND theMonth > 3
  GROUP BY Who
  ORDER BY Who
</cfquery>

<cfquery name="isResolved" dbtype="query">
SELECT isResolved, count(*) cnt
  FROM allofit
  WHERE Project = 'Development'
  GROUP BY isResolved
</cfquery>

<cfquery name="issueTypes" dbtype="query">
SELECT Issue, Count(*) Dun
  FROM allofit
  WHERE Project = 'Development'
  GROUP BY Issue
</cfquery>

<cfquery name="hoursByDev" dbtype="query">
SELECT Who, sum(hrsActual) dun
  FROM allofit
  WHERE Project = 'Development'
    AND Resolved > <cfoutput>#theDate#</cfoutput>
    AND Resolved < <cfoutput>#nextDate#</cfoutput>
	AND theMonth > 3
  GROUP BY Who
  ORDER BY Who
</cfquery>

<cfquery name="hrsByDev" dbtype="query">
SELECT who, SUM(HrsEst) Estimated, SUM(HrsActual) Actual
  FROM allofit
  WHERE Project = 'Development'
    AND Who IS NOT NULL
    AND Resolved > <cfoutput>#theDate#</cfoutput>
    AND Resolved < <cfoutput>#nextDate#</cfoutput>
	AND theMonth > 3
  GROUP BY Who
  ORDER BY Who
</cfquery>

<cfquery dbtype="query" name="qoq1">
select *
from allofit
 where Project = 'Development'
    AND Resolved > <cfoutput>#theDate#</cfoutput>
    AND Resolved < <cfoutput>#nextDate#</cfoutput>
	AND theMonth > 3
ORDER BY Resolved
</cfquery>

<cfquery dbtype="query" name="getNew">
select isResolved, count(*) dun
from allofit
 where Project = 'Development'
   AND Created > <cfoutput>#theDate#</cfoutput>
GROUP BY isResolved
</cfquery>



