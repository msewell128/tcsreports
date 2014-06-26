<cfsavecontent variable="jContainerData">
<cfoutput query="#myObj.hrsByWeek()#">
['#dateFormat(weekStartDate(theWeek,year(now())),"DD-MMM")#', #timeWorked#]<cfif currentRow LT recordCount>,</cfif>
</cfoutput></cfsavecontent>

<script type="text/javascript">
    $(function() {
        <cfoutput>#theSparklines#</cfoutput>

    Highcharts.setOptions({
        colors: ['#FDC835', '#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4']
    });

  $('#jContainer').highcharts({
            title: {
                text: 'TCs Burndown',
                x: -20 //center
            },
<!---             subtitle: {
                text: 'Source: WorldClimate.com',
                x: -20
            }, --->
            xAxis: {
                categories: [<cfoutput>#theWeeks#</cfoutput>]
            },
            yAxis: {
                title: {
                    text: 'Hours Remaining'
                },
                plotLines: [{
                    value: 0,
                    width: 1,
                    color: '#808080'
                }],
                min: 0
            },
            tooltip: {
                valueSuffix: ' Hours Remaining'
            },
<!---             legend: {
                layout: 'vertical',
                align: 'right',
                verticalAlign: 'middle',
                borderWidth: 0
            }, --->
            series: [

            {
                name: '3 Developers',
                data: [<cfoutput>#hoursDev3#</cfoutput>]
            }
            ,{
                name: '4 Developers',
                data: [<cfoutput>#hoursDev4#</cfoutput>]
            }
            , {
                name: '5 Developers',
                data: [<cfoutput>#hoursDev5#</cfoutput>]
            }
            ]
        });

        $('#hrsByWeek').highcharts({
            chart: {
                type: 'column'
            },
            title: {
                text: 'Dev Hours By Week'
            },
            xAxis: {
                type: 'category',
                labels: {
                    rotation: -45,
                    style: {
                        fontSize: '13px',
                        fontFamily: 'Verdana, sans-serif'
                    }
                }
            },
            yAxis: {
                min: 0,
                title: {
                    text: 'Hours'
                }
            },
            legend: {
                enabled: false
            },
            tooltip: {
                pointFormat: '<b>{point.y:.1f} Hours</b>',
            },
            series: [{
                name: 'Population',
                data: [

                    <cfoutput>#jContainerData#</cfoutput>
                ],
                dataLabels: {
                    enabled: true,
                    rotation: -90,
                    color: '#FFFFFF',
                    align: 'right',
                    x: 4,
                    y: 10,
                    style: {
                        fontSize: '13px',
                        fontFamily: 'Verdana, sans-serif',
                        textShadow: '0 0 3px black'
                    }
                }
            }]
        });

        $('#barChart').highcharts({
            chart: {
                type: 'bar'
            },
            title: {
                text: 'Epic Completion'
            },
            xAxis: {
                categories: [<cfoutput>#epicList#</cfoutput>,'14 - No Epic']
            },
            yAxis: {
                min: 0,
                title: {
                    text: 'Total Development Hours'
                }
            },
            legend: {
                reversed: true
            },
            plotOptions: {
                series: {
                    stacking: 'normal'
                }
            },
                series: [{
                name: 'Remaining',
                data: [<cfoutput>#notCompleted#</cfoutput>]
            }, {
                name: 'Completed',
                data: [<cfoutput>#completed#</cfoutput>]
            }]
        });

    });

</script>