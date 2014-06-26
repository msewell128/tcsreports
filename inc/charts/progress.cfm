<cfscript>
	test = 0;
</cfscript>


<cffunction name="getEpics">

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

<script type="text/javascript">
    $(function() {
        <cfoutput>#theSparklines#</cfoutput>

        $('#jContainer').highcharts({
            chart: {
                zoomType: 'xy'
            },
            title: {
                text: 'TCs Burndown'
            },
            subtitle: {
                text: 'Source: Issues.tcs'
            },
            xAxis: [{
                categories: [<cfoutput>#theWeeks#</cfoutput>]
            }],
            yAxis: [{ // Primary yAxis
                labels: {
                    format: '{value} hours',
                    style: {
                        color: Highcharts.getOptions().colors[1]
                    }
                },
                title: {
                    text: 'Developer Hours',
                    style: {
                        color: Highcharts.getOptions().colors[1]
                    }
                }
            }, { // Secondary yAxis
                title: {
                    text: 'Developer Hours',
                    style: {
                        color: Highcharts.getOptions().colors[6]
                    }
                },
                labels: {
                    format: '{value} hours',
                    style: {
                        color: Highcharts.getOptions().colors[2]
                    }
                },
                opposite: true
            }, { // tri yAxis
                title: {
                    text: 'Developer Hours',
                    style: {
                        color: Highcharts.getOptions().colors[3]
                    }
                },
                labels: {
                    format: '{value} hours',
                    style: {
                        color: Highcharts.getOptions().colors[3]
                    }
                },
                opposite: true
            }, { // quad yAxis
                title: {
                    text: 'Developer Hours',
                    style: {
                        color: Highcharts.getOptions().colors[9]
                    }
                },
                labels: {
                    format: '{value} hrs',
                    style: {
                        color: Highcharts.getOptions().colors[5]
                    }
                },
                opposite: true
            }],
            tooltip: {
                shared: true
            },
            legend: {
                layout: 'vertical',
                align: 'left',
                x: 520,
                verticalAlign: 'top',
                y: 100,
                floating: true,
                backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'
            },
            series: [{
                name: '3 Developers',
                type: 'spline',
                yAxis: 1,
                data: [<cfoutput>#hoursDev3#</cfoutput>],
                tooltip: {
                    valueSuffix: ' hrs'
                }

            }, {
                name: '4 Developers',
                type: 'spline',
                data: [<cfoutput>#hoursDev4#</cfoutput>,0,0,0],
                tooltip: {
                    valueSuffix: 'hrs'
                }

            }, {
                name: '5 Developers',
                type: 'spline',
                data: [<cfoutput>#hoursDev5#</cfoutput>,0,0,0,0,0],
                tooltip: {
                    valueSuffix: 'hrs'
                }

            }, {
                name: 'Hrs',
                type: 'area',
                data: [300,200,220,0,0,0,0],
                tooltip: {
                    valueSuffix: 'hrs'
                }
            }]
        });
    });

</script>