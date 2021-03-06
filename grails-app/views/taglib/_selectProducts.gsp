
<table>
	<tr>
		<td style="width: 75%;" style="padding:0; margin: 0">
			<g:set var="selectedProducts" value="${attrs.value }"/>
			
			
			<div class="box">
				<h2>Selected (${selectedProducts.size() })</h2>
				<table id="selectedProducts" class="products">
					<thead>
						<tr class="">
							<th class="middle center"><input type="checkbox" class="checkAll" > </th>
							<th><warehouse:message code="products.label"/></th>
							<th><warehouse:message code="product.manufacturer.label"/></th>
							<th><warehouse:message code="product.vendor.label"/></th>
						</tr>
					</thead>
					<tbody>
						<g:each var="product" in="${selectedProducts }" status="i">
							<tr class="prop ${i%2?'even':'odd' }">
								<td width="1%" style="padding: 0; margin: 0;" class="middle center">
									<g:hiddenField name="${attrs.name }" value="${product.id }"></g:hiddenField>
										
										
									<g:checkBox name="delete-product.id" value="${product?.id }" class="selectedProduct" checked="false"/>
								</td>
								<td>
									${product.name } ${product.unitOfMeasure }
								</td>
								<td>
									 ${product.manufacturer }
									<g:if test="${product?.manufacturerCode }">
										<span class="fade">#${product?.manufacturerCode }</span> 
									</g:if>
								</td>
								<td>
									${product.vendor } 
									<g:if test="${product?.vendorCode }">
										<span class="fade">#${product?.vendorCode }</span> 
									</g:if>
								</td>
							</tr>
						</g:each>
					</tbody>
				</table>
				
				
			</div>
		</td>
		<td class="center middle">
			<div>
				<g:actionSubmit class="button" controller="productGroup" action="addProductsToProductGroup"
					value="${warehouse.message(code: 'default.button.addSelected.label', default: '<')}" />		
			</div>
			<br/>	
			<div>
				<g:actionSubmit class="button" controller="productGroup" action="removeProductsFromProductGroup"
						value="${warehouse.message(code: 'default.button.removeSelected.label', default: '>')}" />
			</div>
		</td>

	
		<td>
		
			<g:set var="availableProducts" value="${attrs.products.findAll { !attrs.value.contains(it) }}"/>
			
			
			<div class="box">
				<h2>Available (${availableProducts.size() })</h2>
				<table id="availableProducts" class="products">				
					<thead>
						<tr class="">
							<th class="middle" colspan="2">
								<g:textField id="productFilter" name="productFilter" value="" size="50" 
									class="medium text"/>
							</th>
						</tr>
					</thead>				
					<tbody>
						<g:each var="product" in="${availableProducts }" status="i">
							<tr class="prop ${i%2?'odd':'even' }">
								<td width="1%" class="middle center">
									<%-- 
									<g:link action="addProducts" id="${productGroupInstance?.id }" params="['product.id':product.id ]">
										<img src="${createLinkTo(dir:'images/icons/silk',file:'add.png')}" />
									</g:link>
									--%>
									<g:checkBox class="availableProduct" 
										name="add-product.id" value="${product.id }" 
										checked="${attrs.value.contains(product) }"></g:checkBox>
								</td>
								<td>
									${product.name }
									<div>
									${product.manufacturer }									
									<g:if test="${product?.manufacturerCode }">
										<span class="fade">#${product?.manufacturerCode }</span> 
									</g:if>
									</div>
									<div>
									${product.vendor } 
									<g:if test="${product?.vendorCode }">
										<span class="fade">#${product?.vendorCode }</span> 
									</g:if>
									</div>
								</td>
							</tr>
						</g:each>
					</tbody>
				</table>
			</div>
		</td>
	</tr>
</table>

<script>
	//filter results based on query
	function filter(selector, query, andOr) {
		query = $.trim(query); //trim white space
		query = query.replace(/ /gi, andOr); //add OR for regex query
	
		$(selector).each(function() {
			($(this).text().search(new RegExp(query, "i")) < 0) ? $(this).hide().removeClass('visible') : $(this).show().addClass('visible');
		});
	}

	//used to apply alternating row styles
	function zebraRows(selector, className) {
	  $(selector).removeClass(className).addClass(className);
	}
	    

	$(document).ready(function() {			
		zebraRows('#availableProducts tbody tr:odd', 'odd');

		/*
		$(".checkAll").click(function(){
			if($(this).attr('checked')) { 
				$('.availableCheckbox').attr('checked','checked');
			}
			else { 
				$('.availableCheckbox').removeAttr('checked');
			}
		});
		*/

		// Check all checkboxes under the same DIV element
		$('.checkAll').click(function () {
			$(this).parents('div:eq(0)').find(':checkbox').attr('checked', this.checked);		
		});

		$("#productFilter").watermark("${warehouse.message(code:'product.filterProducts.label')}");	
		
		//$("#category").change(function() {
		//	$(this).closest("form").submit();
		//});

		//$('#demotable').tableFilter();
		//default each row to visible
		$('tbody tr').addClass('visible');
		$('#productFilter').keyup(function(event) {
			//if esc is pressed or nothing is entered
			if (event.keyCode == 27 || $(this).val() == '') {
    			//if esc is pressed we want to clear the value of search box
		    	$(this).val('');

			    //we want each row to be visible because if nothing
			    //is entered then all rows are matched.
				$('#availableProducts tbody tr').removeClass('visible').show().addClass('visible');
			}
			//if there is text, lets filter
			else {
				filter('#availableProducts tbody tr', $(this).val(), '|');  // '|' or '&'
			}
			//reapply zebra rows
			$('.visible td').removeClass('odd');
			//zebraRows('.visible:odd td', 'odd');	
		});   
	});		
</script>
