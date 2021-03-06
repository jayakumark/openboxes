
	<div id="showLotNumbers" class="list">	
			<g:form controller="inventoryItem" action="create">	
						
			
		
			<table>
				<thead>
					<tr class="odd">
						<th class="center" style=""><warehouse:message code="default.actions.label"/></th>												
						<th><warehouse:message code="default.lotSerialNo.label"/></th>
						<th><warehouse:message code="default.expires.label"/></th>
						<th class="center middle" ><warehouse:message code="default.qty.label"/></th>
						<g:hasErrors bean="${flash.itemInstance}">													
							<th></th>
						</g:hasErrors>
					</tr>											
				</thead>
				<tbody>
					<g:if test="${!commandInstance?.lotNumberList}">
						<tr class="even" style="min-height: 100px;">
							<td colspan="5" style="text-align: center; vertical-align: middle">
								<warehouse:message code="inventory.noItemsCurrentlyInStock.message" args="[format.product(product:commandInstance?.productInstance)]"/>
							</td>
						</tr>
					</g:if>
					<g:set var="count" value="${0 }"/>
					<g:each var="itemInstance" in="${commandInstance?.lotNumberList }" status="status">	
						<g:set var="quantity" value="${commandInstance.quantityByInventoryItemMap.get(itemInstance)}"/>		
						<!-- only show items with quantities -->	
						<g:set var="itemQuantity" value="${commandInstance.quantityByInventoryItemMap.get(itemInstance) }"/>
						<g:set var="selected" value="${params?.inventoryItem?.id && (itemInstance.id == params?.inventoryItem?.id) }"/>
						<g:set var="styleClass" value="${(count++%2==0)?'even':'odd' }"/>
						<g:if test="${selected }">
							<g:set var="styleClass" value="selected-row"/>
						</g:if>
							
						<style>
							.selected-row { background-color: lightyellow; } 
						</style>			
						<tr class="${styleClass} prop">
							<td class="middle center" nowrap="nowrap" style="width: 1%;">
								<div class="action-menu">
									<button class="action-btn">
										<img src="${resource(dir: 'images/icons/silk', file: 'bullet_arrow_down.png')}" style="vertical-align: middle;"/>
									</button>
									<div class="actions left">
										<g:render template="editItemDialog" model="[itemInstance:itemInstance, itemQuantity: itemQuantity]"/>
										<g:render template="adjustStock" model="[itemInstance:itemInstance, itemQuantity: itemQuantity]" />
										<g:render template="addToShipment" model="[itemInstance:itemInstance, itemQuantity: itemQuantity]" />
										<div class="action-menu-item">					
											<g:link controller="inventoryItem" action="showLotNumbers" params="['product.id':commandInstance?.productInstance?.id,'inventoryItem.id':itemInstance?.id]">
												<img src="${resource(dir: 'images/icons/silk', file: 'zoom.png')}"/>&nbsp;
												<warehouse:message code="inventoryItem.show.label"/>
											</g:link>
										</div>
										
										<div class="action-menu-item">					
											<g:link controller="inventoryItem" action="delete" id="${itemInstance?.id}">
												<img src="${resource(dir: 'images/icons/silk', file: 'delete.png')}"/>&nbsp;
												<warehouse:message code="inventoryItem.delete.label"/>
											</g:link>
										</div>
									</div>
								</div>
							</td>															
							<td class="top">
								<g:link action="show" controller="inventoryItem" id="${itemInstance?.id }">
								</g:link>
								<g:link controller="inventoryItem" action="showLotNumbers" params="['product.id':commandInstance?.productInstance?.id,'inventoryItem.id':itemInstance?.id]">
									<span class="lotNumber">
									${itemInstance?.lotNumber?:'<span class="fade"><warehouse:message code="default.none.message"/></span>' }							
									</span>
								</g:link>
							</td>														
							<td class="top">
								<g:if test="${itemInstance?.expirationDate}">
									<format:expirationDate obj="${itemInstance?.expirationDate}"/>
								</g:if>
								<g:else>
									<span class="fade"><warehouse:message code="default.never.label"/></span>
								</g:else>
							</td>
							<td class="top center">
								<g:set var="styleClass" value=""/>
								<g:if test="${itemQuantity<0}">
									<g:set var="styleClass" value="color: red;"/>																	
								</g:if>
								<span style="${styleClass}">${itemQuantity }</span> 
															
							</td>
							
							<g:hasErrors bean="${flash.itemInstance}">
								<td>
									<g:if test="${selected }">
										<div class="errors dialog">
											<g:eachError bean="${flash.itemInstance}">
												<warehouse:message error="${it}"/>
											</g:eachError>																	
										</div>
									</g:if>																									
								</td>
							</g:hasErrors>	
						</tr>
												
					</g:each>
						<g:isUserManager>
							<tr>
								<td>	
									
								</td>
								<td>
									<g:hiddenField name="product.id" value="${commandInstance?.productInstance?.id }"/>
									<g:textField name="lotNumber" class="text" />
								</td>
								<td>
									<g:set var="yearStart" value="${new Date().format('yyyy')as int}"/>
									<g:set var="yearEnd" value="${2020}"/>
									<g:datePicker name="expirationDate" precision="month" noSelection="['null':'']" value=""
										years="${yearStart..yearEnd }"/>						
								</td>
								<td class="center">
									<button class="button icon add">
										<warehouse:message code="default.button.add.label"/>
									</button>						
								</td>
							</tr>
						</g:isUserManager>						
					
				</tbody>
				<g:if test="${commandInstance?.lotNumberList}">
					<tfoot>
						<tr>
							<td colspan="2">
								<label>
									${warehouse.message(code: 'default.total.label') }
								</label>
							</td>
							<td></td>
							<td style="text-align: center; vertical-align: middle;">
								<span style="font-size: 1em;"> 
									<g:set var="styleClass" value="color: black;"/>																	
									<g:if test="${commandInstance.totalQuantity < 0}">
										<g:set var="styleClass" value="color: red;"/>																	
									</g:if>														
									<span style="${styleClass }">${commandInstance.totalQuantity }</span> 
								</span>
							</td>
							<g:hasErrors bean="${flash.itemInstance}">
								<td style="border: 0px;">
								
								</td>
							</g:hasErrors>
						</tr>
					</tfoot>
				</g:if>
			</table>		
		</g:form>	
				
	</div>	


<div class="list">
	<g:if test="${transactionEntries }">
		<h3>${warehouse.message(code: 'transaction.transactionEntries.label') } &rsaquo; <span class="lotNumber">${inventoryItem?.lotNumber}</span></h3>
		<div>
			<table>
				<tbody>
					<tr>
						<td colspan="5" style="padding: 0px; margin: 0px">
							<div class="box" style="padding: 0px; margin: 0px">
								<table>
									<thead>
										<tr>
											<th>
												${warehouse.message(code: 'transaction.transactionDate.label') }
											</th>
											<th>
												${warehouse.message(code: 'default.time.label') }
											</th>
											<th>
												${warehouse.message(code: 'transaction.transactionNumber.label') }
											</th>
											<th>
												${warehouse.message(code: 'transaction.transactionType.label') }
											</th>
											<th>
												${warehouse.message(code: 'default.quantity.label') }
											</th>
											<th>
												${warehouse.message(code: 'default.dateCreated.label') }
											</th>
										</tr>
									</thead>
									<tbody>											
										<g:each var="transactionEntry" in="${transactionEntries }" status="j">
											<tr class="${j%2?'even':'odd' }">
												<td>
													<g:formatDate obj="${transactionEntry.transaction?.transactionDate}" format="MMMMM dd yyyy"/>
												</td>
												<td>
													<g:formatDate date="${transactionEntry.transaction?.transactionDate}" format="hh:mm:ss"/>
												</td>
												<td>
													<g:link controller="inventory" action="editTransaction" id="${transactionEntry?.transaction?.id }">
														${transactionEntry?.transaction?.transactionNumber?:transactionEntry?.transaction?.id }
													</g:link>
												</td>
												<td>
													<format:metadata obj="${transactionEntry.transaction?.transactionType }"/>												
												</td>
												<td>
													${transactionEntry?.quantity }
												</td>						
												<td>
													<format:datetime obj="${transactionEntry?.transaction?.dateCreated }"/>
												</td>						
											</tr>
										</g:each>
									</tbody>
								</table>
							</div>
						</td>
					</tr>	
				</tbody>
			</table>
		</div>
	</g:if>
</div>
