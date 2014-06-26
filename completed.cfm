<cfinclude template="inc/query.cfm">

<table>
	<tbody>
		<cfoutput query="qoq1">
			<tr>
				<td>#shortdescr#</td>
				<td>#hrsEst#</td>
				<td>#left(hrsActual,4)#</td>
				<td>#Resolved#</td>
				<td>#Who#</td>
			</tr>
		</cfoutput>
	</tbody>
</table>