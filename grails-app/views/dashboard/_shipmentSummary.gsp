<!--  Show recent shipments/receipts -->
<%@ page import="org.pih.warehouse.shipping.ShipmentStatusCode"%>


<div class="widget-small">
	<div class="widget-header">
		<h2><warehouse:message code="shipping.label"/></h2>
	</div>
	<div class="widget-content" style="padding:0; margin:0">
		<div id="shippingsummary">
			<g:if test="${!outgoingShipmentsByStatus}">
				<div style="text-align: left; padding: 10px;" class="fade">
					(<warehouse:message code="shipping.noRecent.label"/>)
				</div>
			</g:if>	    		
			<g:else>	
			
  				<g:set var="pending" value="${ShipmentStatusCode.PENDING}"/>
  				<g:set var="shipped" value="${ShipmentStatusCode.SHIPPED}"/>
  				<g:set var="received" value="${ShipmentStatusCode.RECEIVED}"/>
				<g:set var="shipmentsPending" value="${outgoingShipmentsByStatus[pending] }"/>			
				<g:set var="shipmentsShipped" value="${outgoingShipmentsByStatus[shipped] }"/>		
				<g:set var="shipmentsReceived" value="${outgoingShipmentsByStatus[received] }"/>		
				<g:set var="outgoingShipmentsTotal" value="${shipmentsPending.objectList.size + shipmentsShipped.objectList.size + shipmentsReceived.objectList.size }"/>	

					
	    		<table>
	    			
	    			<tbody>
						<tr class="even">
							<td class="center" style="width: 1%">
								<img src="${createLinkTo(dir:'images/icons/silk/lorry_flatbed.png')}" class="middle"/>
							</td>
							<td>
								<g:link controller="shipment" action="list" params="['type':'outgoing','status':pending]">
									${warehouse.message(code: 'dashboard.outgoing.pending.label', args: [session.warehouse.name]) }							
								</g:link>
							</td>
							<td style="text-align: right;">
								<g:link controller="shipment" action="list" params="['type':'outgoing','status':pending]">
									${shipmentsPending.objectList.size}
								</g:link>
							</td>
						</tr>	
						<tr class="odd">
							<td class="center" style="width: 1%">
								<img src="${createLinkTo(dir:'images/icons/silk/lorry_go.png')}" class="middle"/>
							</td>
						
							<td>
								<g:link controller="shipment" action="list" params="['type':'outgoing','status':shipped]">
									${warehouse.message(code: 'dashboard.outgoing.shipped.label', args: [session.warehouse.name]) }							
								</g:link>
							</td>
							<td style="text-align: right;">
								<g:link controller="shipment" action="list" params="['type':'outgoing','status':shipped]">
									${shipmentsShipped.objectList.size}
								</g:link>
							</td>
						</tr>
							
						<tr class="even">
							<td class="center" style="width: 1%">
								<img src="${createLinkTo(dir:'images/icons/silk/lorry_stop.png')}" class="middle"/>
							</td>
						
							<td>
								<g:link controller="shipment" action="list" params="['type':'outgoing','status':received]">
									${warehouse.message(code: 'dashboard.outgoing.received.label', args: [session.warehouse.name]) }							
								</g:link>
							</td>
							<td style="text-align: right;">
								<g:link controller="shipment" action="list" params="['type':'outgoing','status':received]">
									${shipmentsReceived.objectList.size}
								</g:link>
							</td>
						</tr>								
			    	</tbody>			    	
			    	<tfoot>
						<tr class="even prop">
							<th colspan="2">
								<warehouse:message code="default.total.label"/>
							</th>
							<th class="right">
								${outgoingShipmentsTotal }
							</th>
						</tr>
			    	</tfoot>
		    	</table>

			</g:else>
		</div>
	</div>	
</div>