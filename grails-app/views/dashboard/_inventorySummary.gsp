<div class="widget-large">
	<div class="widget-header">
		<h2><warehouse:message code="inventory.label" args="[session.warehouse.name]"/></h2>
	</div>	    			
	<div class="widget-content">	    					    			
		<div id="inventorysummary">	
			<div style="padding-top:0px;">
				<g:form method="GET" controller="inventory" action="browse">
					<div>
							
						<g:globalSearch id="dashboardSearchBox" cssClass="globalSearch" size="80"
							name="searchTerms" 
							value="${params?.searchTerms }" 
							placehoder="${warehouse.message(code:'inventory.filterByKeyword.label')}"
							jsonUrl="${request.contextPath }/json/globalSearch"></g:globalSearch>
							
						<%-- 				
						<g:textField id="dashboardSearchBox" name="searchTerms" style="width: 60%" value="${params.searchTerms }" 
							class="globalSearch"/>						
						<g:hiddenField name="resetSearch" value="true"/>							
						<g:hiddenField name="categoryId" value="${rootCategory.id }"/>							
						<g:hiddenField name="showHiddenProducts" value="on"/>
						<g:hiddenField name="showOutOfStockProducts" value="on"/>
						--%>
						<button type="submit" class="button icon search">					
							<warehouse:message code="default.search.label"/>
						</button>
							
					</div>
				</g:form>
			</div>
		</div>
	</div>
</div>	