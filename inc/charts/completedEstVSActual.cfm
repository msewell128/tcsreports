$('#completedEstVSActual').highcharts({
        chart: {
            type: 'column',
            margin: 75,
            options3d: {
				enabled: true,
                alpha: 10,
                beta: 25,
                depth: 70
            }
        },
        title: {
            text: 'test',
			style: {
	            color: '#666666',
	            font: 'bold 14px "Trebuchet MS", Verdana, sans-serif'
	        }
        },
        subtitle: {
            text: 'Put some text here'
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
        series: [{
			name: 'Completed Task Share',
            data: [
				<cfoutput query="whoCompleted">
					['#who#', #dun#]<cfif currentRow NEQ whoCompleted.recordcount>,</cfif>
				</cfoutput>]

        }]
    });