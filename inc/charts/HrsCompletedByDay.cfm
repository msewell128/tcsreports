// Who Completed

    $('#whoCompleted').highcharts({
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false
        },
        title: {
            text: 'Who Completed Tasks in <cfoutput>#theMonth#</cfoutput>',
			style: {
	            color: '#666666',
	            font: 'bold 14px "Trebuchet MS", Verdana, sans-serif'
	        }
        },
        tooltip: {
    	    pointFormat: '{series.name}: <b>{point.y:.1f} Tasks</b>'
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
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    format: '<b>{point.name}</b>: {point.percentage:.1f} %',
                    style: {
                        color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
                    }
                },
                depth: 25,
				colorByPoint: true
            }
        },
        series: [{
            type: 'pie',
            name: 'Completed Task Share',
            data: [
				<cfoutput query="getTheHours">
					['#resolvedDate#', #round(hrsActual)#]<cfif currentRow NEQ getTheHours.recordcount>,</cfif>
				</cfoutput>
            ]
        }]
    });