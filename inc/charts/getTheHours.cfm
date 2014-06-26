    $('#getTheHours').highcharts({
        chart: {
            type: 'column',
            margin: 105,
            options3d: {
				enabled: true,
                alpha: 10,
                beta: 25,
                depth: 90
            }
        },
        title: {
            text: 'Hours Completed by Day in <cfoutput>#theMonth#</cfoutput>',
			style: {
	            color: '#666666',
	            font: 'bold 14px "Trebuchet MS", Verdana, sans-serif'
	        }
        },
      /*  subtitle: {
            text: 'Notice the difference between a 0 value and a null point'
        }, */
		legend: {
		  enabled: true,
		  labelFormatter: function() {
		    var count = 0;
		    for (var i = 0 ; i < this.yData.length; i++) {
		      count += this.yData[i];
		    }
		  return this.name + ' [' + count + ']';
		  }
		},
        tooltip: {
            pointFormat: 'Issues Resolved: <b>{point.y:.1f} </b>',
        },
		colors: [
			'#4572A7',
			'#7DA915',
			'#B41318',
			'#72A0C1',
			'#2A0DC1',
			'#FB840A',
			'#036A9B',
			'#DB843D',
			'#058DC7',
			'#AF002A',
			'#D25128',
			'#89A54E',
			'#80699B',
			'#3D96AE',
			'#036A9B',
			'#50B432',
			'#FB840A',
			'#92A8CD',
			'#A47D7C'
		],
        plotOptions: {
            column: {
                depth: 25,
				colorByPoint: true
            }
        },
            xAxis: {
                type: 'category',
                labels: {
                    rotation: -45,
                    align: 'right',
                    style: {
                        fontSize: '9px',
                        fontFamily: 'Verdana, sans-serif'
                    }
                }
            },
            yAxis: {
                min: 0,
                title: {
                    text: 'Issues Resolved'
                }
            },
            series: [{
                name: 'Completed',
                data: [
				<cfoutput query="getTheHours">
					['#ResolvedDate#', #hrsActual#]<cfif currentRow NEQ getTheHours.recordcount>,</cfif>
				</cfoutput>
                ]

            }]
    });
<!---
       $('#completedByDate').highcharts({
            chart: {
                type: 'column'
            },
            title: {
                text: 'Completed Tasks in <cfoutput>#theMonth#</cfoutput>'
            },
        /*    subtitle: {
                text: 'Source: <a href="http://en.wikipedia.org/wiki/List_of_cities_proper_by_population">Wikipedia</a>'
            },*/
            xAxis: {
                type: 'category',
                labels: {
                    rotation: -45,
                    align: 'right',
                    style: {
                        fontSize: '13px',
                        fontFamily: 'Verdana, sans-serif'
                    }
                }
            },
            yAxis: {
                min: 0,
                title: {
                    text: 'Issues Resolved'
                }
            },
            legend: {
                enabled: false
            },
            tooltip: {
                pointFormat: 'Issues Resolved: <b>{point.y:.1f} </b>',
            },
            series: [{
                name: 'Population',
                data: [
				<cfoutput query="completed">
					['#resolved#', #cnt#]<cfif currentRow NEQ completed.recordcount>,</cfif>
				</cfoutput>
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
 --->




