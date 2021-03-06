<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="custom" />
        <g:set var="entityName" value="${warehouse.message(code: 'transaction.label', default: 'Transaction')}" />
        <title>
	        <g:if test="${transactionInstance?.id }">
		        <warehouse:message code="default.edit.label" args="[entityName.toLowerCase()]" />  
	    	</g:if>
	    	<g:else>
		        <warehouse:message code="default.add.label" args="[entityName.toLowerCase()]" />    
			</g:else>    	    
		</title>
    </head>    
    <body>
        <div class="body">

            <g:if test="${flash.message}">
				<div class="message">${flash.message}</div>
            </g:if>						
            <g:hasErrors bean="${transactionInstance}">
	            <div class="errors">
	                <g:renderErrors bean="${transactionInstance}" as="list" />
	            </div>
            </g:hasErrors>    

			<div class="dialog" >
				<g:render template="../transaction/summary"/>

				<div class="yui-g">
					<div class="yui-u first">
						<div class="box">
                            <h2>${warehouse.message(code: 'transaction.details.label')}</h2>
							<g:form action="saveTransaction">
								<g:hiddenField name="id" value="${transactionInstance?.id}"/>
								<table>
									<tbody>
										<tr class="prop">
											<td class="name">
												<label><warehouse:message code="transaction.transactionNumber.label"/></label>
											</td>
											<td class="value">
												<g:if test="${transactionInstance?.id }">
													${transactionInstance?.transactionNumber }
												</g:if>
												<g:else>
													<span class="fade">
														<warehouse:message code="transaction.new.label"/>
													</span>
												</g:else>
											</td>
										</tr>
										<tr class="prop">
											<td class="name">
												<label><warehouse:message code="transaction.status.label"/></label>
											</td>												
											<td class="value">
												<g:if test="${transactionInstance?.id }">
													<warehouse:message code="enum.TransactionStatus.COMPLETE"/>
												</g:if>
												<g:else>
													<warehouse:message code="enum.TransactionStatus.PENDING"/>
												</g:else>
											</td>
										</tr>
										<tr class="prop">
											<td class="name">
												<label><warehouse:message code="transaction.date.label"/></label>
											</td>
											<td class="value">													
												<g:jqueryDatePicker id="transactionDate" name="transactionDate"
														value="${transactionInstance?.transactionDate}" format="MM/dd/yyyy"/>
											</td>
										</tr>											
										<tr class="prop">
											<td class="name">
												<label><warehouse:message code="transaction.type.label"/></label>
											</td>
											<td class="value">
												<span class="value">
													<g:select id="transactionTypeSelector" name="transactionType.id" from="${transactionTypeList}" 
							                       		optionKey="id" optionValue="${{format.metadata(obj:it)}}" value="${transactionInstance.transactionType?.id}" noSelection="['': '']" />
						                       	</span>
											</td>
										</tr>
										<tr class="prop">
											<td class="name">							                  
												<label><warehouse:message code="transaction.source.label"/></label>
											</td>
											<td class="value">
												<g:select id="sourceId" name="source.id" from="${locationInstanceList}" 
						                       		optionKey="id" optionValue="name" value="${transactionInstance?.source?.id}" noSelection="['null': '']" />
				                       		</td>
				                       	</tr>
				                       	<tr class="prop">
				                       		<td class="name">
												<label><warehouse:message code="transaction.destination.label"/></label>
											</td>
											<td class="value">
												<g:select id="destinationId" name="destination.id" from="${locationInstanceList}" 
						                       		optionKey="id" optionValue="name" value="${transactionInstance?.destination?.id}" noSelection="['null': '']" />
											</td>
										</tr>
				                       	<tr class="prop">
				                       		<td class="name">
												<label><warehouse:message code="transaction.inventory.label"/></label>
											</td>
											<td class="value">
												<g:select id="inventoryId" name="inventory.id" from="${locationInstanceList}" 
						                       		optionKey="id" optionValue="name" value="${transactionInstance?.inventory?.id}" noSelection="['null': '']" />
											</td>
										</tr>
										<tr class="prop">
											<td class="name">
												<label><warehouse:message code="transaction.comment.label"/></label>
											</td>
											<td class="value">
												<g:textArea cols="60" rows="5" name="comment" value="${transactionInstance?.comment }"></g:textArea>
											</td>
										</tr>
									</tbody>
									<tfoot>									
										<tr>
											<td class="center" colspan="2">
												<button type="submit" name="save" class="button">
													<warehouse:message code="default.button.save.label"/>
												</button>
												&nbsp;
												<g:if test="${params?.product?.id }">
													<g:link controller="inventoryItem" action="showStockCard" params="['product.id':params?.product?.id]">
														${warehouse.message(code: 'default.button.cancel.label')}
													</g:link>		
												</g:if>
												<g:else>
													<g:link controller="inventory" action="browse">
														${warehouse.message(code: 'default.button.cancel.label')}
													</g:link>
												</g:else>			
												
											</td>
										</tr>
									</tfoot>									
													
								</table>
							</g:form>
						</div>
					</div>
					<div class="yui-u">									
						<div class="box">
                            <h2>${warehouse.message(code: 'transaction.transactionEntries.label')}</h2>
							<g:form action="saveTransaction">
								<g:hiddenField name="id" value="${transactionInstance?.id}"/>
								<g:hiddenField name="inventory.id" value="${transactionInstance?.inventory?.id}"/>
							
								<div style="">
									<table id="transaction-entries-table" border="0" style="margin: 0; padding: 0; border: 0px solid lightgrey; background-color: white;">
										<thead>
											<tr class="odd">
												<th><warehouse:message code="product.label"/></th>
												<th class="center"><warehouse:message code="inventoryItem.lotNumber.label"/></th>
												<th class="center"><warehouse:message code="default.expires.label"/></th>
												<th class="center"><warehouse:message code="inventory.onHandQuantity.label"/></th>
												<th class="center"><warehouse:message code="default.quantity.label"/></th>
												<th class="center"><warehouse:message code="default.actions.label"/></th>
											</tr>
										</thead>
										<tbody>
											<g:each var="transactionEntry" in="${transactionInstance?.transactionEntries }" status="i">
											
			                                    <tr class="${i % 2 ? 'odd' : 'even' }">
			                                    	<td>
														<format:product product="${transactionEntry?.inventoryItem?.product }"/>
			                                    	</td>
			                                    	<td class="center">
			                                    		<g:select name="transactionEntries[${i }].inventoryItem.id" value="${transactionEntry?.inventoryItem?.id }" 
			                                    			from="${inventoryItemsMap[transactionEntry?.inventoryItem?.product]}" noSelection="['null':'']"
			                                    			optionKey="id" optionValue="lotNumber" /> 
			                                    	</td>
			                                    	<td class="center">
			                                    		<g:if test="${transactionEntry?.inventoryItem?.expirationDate }">
				                                    		<format:date obj="${transactionEntry?.inventoryItem?.expirationDate }"/>
				                                    	</g:if>
				                                    	<g:else>
				                                    		<warehouse:message code="default.never.label"/>
				                                    	</g:else>
			                                    	</td>
			                                    	<td class="center">
			                                    		${quantityMap[transactionEntry?.inventoryItem] }
			                                    	</td>
			                                    	<td class="center">
			                                    		<g:textField class="quantity text" name="transactionEntries[${i }].quantity"
                                                            value="${transactionEntry?.quantity }" size="6"/>
			                                    	</td>
			                                    	<td class="center">
		                                    			
		                                    			<%-- 
		                                    			<g:link controller="transactionEntry" action="show" id="${transactionEntry?.id }">
		                                    				<img src="${createLinkTo(dir: 'images/icons/silk', file: 'pencil.png')}" /></g:link>
														&nbsp;
														--%>
		                                    			<g:link controller="transactionEntry" action="delete" id="${transactionEntry?.id }" onclick="return confirm('Are you sure?');">
			                                    			<img src="${createLinkTo(dir: 'images/icons/silk', file: 'delete.png')}" />
			                                    		</g:link>
			                                    	</td>
			                                    </tr>											
											</g:each>
											<g:unless test="${transactionInstance?.transactionEntries }">
												<tr class="empty">
													<td colspan="7" style="text-align: center; display:none;" id="noItemsRow">
														<span class="fade"><warehouse:message code="transaction.noItems.message"/></span>
													</td>
												</tr>											
											</g:unless>
											<%-- 
											<tr class="empty">
												<td colspan="7" style="text-align: center; display:none;" id="noItemsRow">
													<span class="fade"><warehouse:message code="transaction.noItems.message"/></span>
												</td>
											</tr>
		                                    <tr id="itemRowTemplate" style="display:none;">
		                                    	<td>
		                                    		 <g:hiddenField class="entryIdField" name="transactionEntryId" value=""/>
		                                    		 <g:hiddenField class="entryDeleteField" name="deleteEntry" value="false"/>
		                                    		 <g:hiddenField class="productIdField" name="productId" value=""/>
		                                    		 <g:hiddenField class="inventoryItemIdField" name="inventoryItemId" value=""/> 
		                                    		 <span class="productNameLabel"></span>
		                                    	</td>
		                                    	<td class="center">
		                                    		<span class="lotNumberFieldSection" style="display:none;">
		                                    			<g:textField class="lotNumber lotNumberField" name="lotNumber" size="15" value=""/>
		                                    		</span>
		                                    		<span class="lotNumberLabel"></span>
		                                    	</td>
		                                    	<td class="center">
		                                    		<span class="expirationFieldSection" style="display:none;">
		                                    			<g:datePicker class="expirationDateField" name="expirationDate" precision="month" default="none" noSelection="['':'']"/>
		                                    		</span>
		                                    		<span class="expirationLabel"></span>
		                                    	</td>
		                                    	<td class="center" class="onHandQtyLabel"></td>
		                                    	<td class="center"><g:textField class="quantityField" name="quantity" value="" size="6"/></td>
		                                    	<td class="actionsCell center">
	                                    			<g:link controller="transactionEntry" action="edit" id="${transactionEntry?.id }">
	                                    				<img src="${createLinkTo(dir: 'images/icons/silk', file: 'pencil.png')}" class="rowEditButton" />
	                                    			</g:link>
	
	                                    			<img src="${createLinkTo(dir: 'images/icons/silk', file: 'cross.png')}" class="rowDeleteButton" />
		                                    	</td>
		                                    </tr>
		                                    --%>
										</tbody>
										<tfoot>
											<tr>
												<td colspan="6">
													<div class="center">
														<button type="submit" name="save" class="button">
															<warehouse:message code="default.button.save.label"/>
														</button>
														&nbsp;
														<g:if test="${params?.product?.id }">
															<g:link controller="inventoryItem" action="showStockCard" params="['product.id':params?.product?.id]">
																${warehouse.message(code: 'default.button.cancel.label')}
															</g:link>		
														</g:if>
														<g:else>
															<g:link controller="inventory" action="browse">
																${warehouse.message(code: 'default.button.cancel.label')}
															</g:link>
														</g:else>			
													</div>
												</td>
											</tr>
										</tfoot>
									</table>
								</div>	
							</g:form>
						</div>
					</div>
				</div>
			</div>
		</div>
		<script type="text/javascript">
	    	//$(document).ready(function() { });
        </script>
    </body>
</html>
