<%@ page import="org.pih.warehouse.inventory.Transaction" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="custom" />        
        <title><warehouse:message code="inventory.expiredStock.label"/></title>    
    </head>    

	<body>
		<div class="body">
       		
			<g:if test="${flash.message}">
				<div class="message">${flash.message}</div>
			</g:if>
            
           
            <h3><warehouse:message code="inventory.expiredStock.label"/></h3>
            
            
            <div class="yui-gf">
				<div class="yui-u first">
				
			
		            <g:form action="listExpiredStock" method="get">
						<div class="box">
                            <h2>
                                <warehouse:message code="default.filters.label" default="Filters"/>
                            </h2>
		          			<span class="filter-list-item">
		           				<label><warehouse:message code="category.label"/></label>            			
				           		<g:select name="category"
												from="${categories}"
												optionKey="id" optionValue="${{format.category(category:it)}}" value="${categorySelected?.id}" 
												noSelection="['': warehouse.message(code:'default.all.label')]" />   
							</span>
							<span class="filter-list-item">
								<button name="filter">
									<img src="${resource(dir: 'images/icons/silk', file: 'zoom.png')}"/>&nbsp;<warehouse:message code="default.button.filter.label"/> 
								</button>
							</span>
						</div>

		
		            </g:form>
				</div>
				<div class="yui-u">
		            <div class="box">
                        <h2>
                            <warehouse:message code="default.results.label" default="Results"/>
                        </h2>
						<table>
							<tr>					
								<td>
									<div class="">
							            <form id="inventoryActionForm" name="inventoryActionForm" action="createTransaction" method="POST">
											<table>
							                    <thead>
							                        <tr class="odd">   
							                        	<th class="center">
							                        		<input type="checkbox" id="toggleCheckbox"/>
							                        	</th>
														<th><warehouse:message code="category.label"/></th>
														<th><warehouse:message code="item.label"/></th>
														<th><warehouse:message code="inventory.lotNumber.label"/></th>
														<th class="center"><warehouse:message code="inventory.expires.label"/></th>
														<th class="center"><warehouse:message code="default.qty.label"/></th>
														<th class="center"><warehouse:message code="product.uom.label"/></th>
							                        </tr>
							                    </thead>
							       	           	<tbody>			
							       	     			<g:set var="counter" value="${0 }" />
							       	     			<g:set var="anyExpiredStock" value="${false }"/>
													<g:each var="inventoryItem" in="${inventoryItems}" status="i">           
														<g:set var="quantity" value="${quantityMap[inventoryItem] }"/>
														<g:set var="anyExpiredStock" value="${true }"/>
														<tr class="${(counter++ % 2) == 0 ? 'even' : 'odd'}">            
															<td class="center">
																<g:checkBox id="${inventoryItem?.id }" name="inventoryItem.id" 
																	class="checkbox" style="top:0em;" checked="${false }" 
																		value="${inventoryItem?.id }" />
															
															</td>
															<td class="checkable">
																<span class="fade"><format:category category="${inventoryItem?.product?.category}"/> </span>
															</td>												
															<td class="checkable">
																<g:link controller="inventoryItem" action="showStockCard" params="['product.id':inventoryItem?.product?.id]">
																	<format:product product="${inventoryItem?.product}"/> 
																</g:link>
																
															</td>
															<td class="checkable">
																<span class="lotNumber">
																	${inventoryItem?.lotNumber }
																</span>
															</td>
															<td class="checkable center">
																<span class="fade">
																	<g:formatDate date="${inventoryItem?.expirationDate}" format="MMM yyyy"/>
																</span>													
															</td>
															<td class="center checkable">
																${quantity }
															</td>
															<td class="center checkable">
																${inventoryItem?.product?.unitOfMeasure?:"EA" }
																
															</td>									
														</tr>						
													</g:each>
													<g:if test="${!anyExpiredStock }">
														<tr>
															<td colspan="7">
																<div class="padded center fade">
																	<warehouse:message code="inventory.noExpiredStock.label" />
																</div>
															</td>
														</tr>
													</g:if>
												</tbody>
												<tfoot>
													<tr style="border-top: 1px solid lightgrey">
														<td colspan="7">
															<div>
																<g:render template="./actionsExpiredStock" />									
															</div>
														</td>
													</tr>									
												</tfoot>
											</table>		
										</form>		
									</div>
								</td>
							</tr>			
						</table>
					</div>
				</div>
			</div>
		</div>
		<script>
			$(document).ready(function() {
				$(".checkable a").click(function(event) {
					event.stopPropagation();
				});
				$('.checkable').toggle(
					function(event) {
						$(this).parent().find('input').click();
						//$(this).parent().addClass('checked');
						return false;
					},
					function(event) {
						$(this).parent().find('input').click();
						//$(this).parent().removeClass('checked');
						return false;
					}
				);
				
				$("#toggleCheckbox").click(function(event) {
					$(".checkbox").attr("checked", $(this).attr("checked"));
				});	
			});	
		</script>	
	</body>
</html>
