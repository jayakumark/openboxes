/**
* Copyright (c) 2012 Partners In Health.  All rights reserved.
* The use and distribution terms for this software are covered by the
* Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php)
* which can be found in the file epl-v10.html at the root of this distribution.
* By using this software in any fashion, you are agreeing to be bound by
* the terms of this license.
* You must not remove this notice, or any other, from this software.
**/ 
package org.pih.warehouse.requisition

import grails.validation.ValidationException
import org.pih.warehouse.core.Location
import org.pih.warehouse.inventory.InventoryItem
import org.pih.warehouse.picklist.Picklist
import org.pih.warehouse.picklist.PicklistItem
import org.pih.warehouse.product.Product
import org.pih.warehouse.product.ProductPackage;

class RequisitionItemController {

	def requisitionService
	def inventoryService
	
    //static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [requisitionItemInstanceList: RequisitionItem.list(params), requisitionItemInstanceTotal: RequisitionItem.count()]
    }

    def create = {
        def requisitionItemInstance = new RequisitionItem()
        requisitionItemInstance.properties = params
        return [requisitionItemInstance: requisitionItemInstance]
    }

    def save = {
        def requisitionItemInstance = new RequisitionItem(params)
        if (requisitionItemInstance.save(flush: true)) {
            flash.message = "${warehouse.message(code: 'default.created.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), requisitionItemInstance.id])}"
            redirect(action: "list", id: requisitionItemInstance.id)
        }
        else {
            render(view: "create", model: [requisitionItemInstance: requisitionItemInstance])
        }
    }

    def show = {
        def requisitionItemInstance = RequisitionItem.get(params.id)
        if (!requisitionItemInstance) {
            flash.message = "${warehouse.message(code: 'default.not.found.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), params.id])}"
            redirect(action: "list")
        }
        else {
            [requisitionItemInstance: requisitionItemInstance]
        }
    }

    def edit = {
        def requisitionItemInstance = RequisitionItem.get(params.id)
        if (!requisitionItemInstance) {
            flash.message = "${warehouse.message(code: 'default.not.found.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [requisitionItemInstance: requisitionItemInstance]
        }
    }

    def change = {
        def location = Location.get(session.warehouse.id)
        def requisitionItemInstance = RequisitionItem.get(params.id)
        def quantityOnHand = inventoryService.getQuantityOnHand(location, requisitionItemInstance?.product)?:0
        def quantityOutgoing = inventoryService.getQuantityToShip(location, requisitionItemInstance?.product)?:0
        def quantityAvailableToPromise = (quantityOnHand - quantityOutgoing)?:0;

        if (!requisitionItemInstance) {
            flash.message = "${warehouse.message(code: 'default.not.found.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [requisitionItemInstance: requisitionItemInstance, quantityOnHand: quantityOnHand, quantityAvailableToPromise: quantityAvailableToPromise]
        }
    }

    def update = {
        def requisitionItemInstance = RequisitionItem.get(params.id)
        if (requisitionItemInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (requisitionItemInstance.version > version) {
                    
                    requisitionItemInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem')] as Object[], "Another user has updated this RequisitionItem while you were editing")
                    render(view: "edit", model: [requisitionItemInstance: requisitionItemInstance])
                    return
                }
            }
            requisitionItemInstance.properties = params
            if (!requisitionItemInstance.hasErrors() && requisitionItemInstance.save(flush: true)) {
                flash.message = "${warehouse.message(code: 'default.updated.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), requisitionItemInstance.id])}"
                //redirect(action: "list", id: requisitionItemInstance.id)
				redirect(controller: "requisition", action: "review", id: requisitionItemInstance?.requisition?.id)
            }
            else {
                render(view: "edit", model: [requisitionItemInstance: requisitionItemInstance])
            }
        }
        else {
            flash.message = "${warehouse.message(code: 'default.not.found.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), params.id])}"
            //redirect(action: "list")
			redirect(controller: "requisition", action: "review", id: requisitionItemInstance?.requisition?.id)
        }
    }

    def delete = {
		
		println "Delete requisition item " + params
        def requisitionItemInstance = RequisitionItem.get(params.id)
        if (requisitionItemInstance) {
            try {
				def requisition = requisitionItemInstance.requisition
				
				if (requisitionItemInstance.parentRequisitionItem) { 
					requisitionItemInstance.parentRequisitionItem.removeFromRequisitionItems(requisitionItemInstance)
				}
				
    			requisition.removeFromRequisitionItems(requisitionItemInstance)
	            requisitionItemInstance.delete(flush: true)
                flash.message = "${warehouse.message(code: 'default.deleted.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), params.id])}"
                //redirect(action: "list")
				redirect(controller: "requisition", action: "review", id: requisition?.id)
			}
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${warehouse.message(code: 'default.not.deleted.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), params.id])}"
                //redirect(action: "list", id: params.id)
				redirect(controller: "requisition", action: "review", id: requisition?.id)
				
            }
        }
        else {
            flash.message = "${warehouse.message(code: 'default.not.found.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), params.id])}"
            //redirect(action: "list")
			redirect(controller: "requisition", action: "review", id: requisition?.id)
        }
    }


    /** ========================================================================================================================= */



    def changeQuantity = {
        log.info "change quantity " + params
        def requisition = Requisition.get(params.id)
        def requisitionItem = RequisitionItem.get(params?.requisitionItem?.id)
        def productPackage = ProductPackage.get(params?.productPackage?.id)
        try {
            requisitionItem.changeQuantity(params.quantity as int, productPackage, params.reasonCode, params.comments);
        } catch(ValidationException e) {
            requisitionItem.errors = e.errors
            flash.errors = e.errors
        }

        // If there are errors we want to render the review page with those errors
        if (requisitionItem.hasErrors()) {
            log.error("There are errors: " + requisitionItem.errors)
            redirect(controller: "requisition", action: "review", id: requisitionItem?.requisition?.id,
                    params:['requisitionItem.id': requisitionItem.id,actionType:params.actionType])
            //render(view: "../requisition/review", model: [requisition:requisition, selectedRequisitionItem: requisitionItem])
            return;
        }
        redirect(controller: "requisition", action: "review", id: requisitionItem?.requisition?.id)
    }

    /**
     *  Allow user to cancel the given requisition item.
     */
    def cancelQuantity = {
        log.info "cancel quantity = " + params
        def requisitionItem = RequisitionItem.get(params.id)
        if (requisitionItem) {

            try {
                requisitionItem.cancelQuantity(params.reasonCode, params.comments)
            } catch(ValidationException e) {
                requisitionItem.errors = e.errors
                flash.errors = e.errors
            }

            // If there are errors we want to render the review page with those errors
            if (requisitionItem.hasErrors()) {
                def redirectAction = params?.redirectAction ?: "review"
                redirect(controller: "requisition", action: redirectAction, id: requisitionItem?.requisition?.id,
                        params:['requisitionItem.id': requisitionItem.id,actionType:params.actionType])
                return;
            }

        }
        else {
            flash.message = "${warehouse.message(code: 'default.not.found.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), params.id])}"
            redirect(controller: "requisition", action: "list")
            return
        }
        redirect(controller: "requisition", action: "review", id: requisitionItem?.requisition?.id)
    }

    /**
     *  Allow user to approve the given requisition item.
     */
    def approveQuantity = {
        log.info "approve quantity = " + params
        def requisitionItem = RequisitionItem.get(params.id)
        if (requisitionItem) {
            requisitionItem.approveQuantity()
            def redirectAction = params?.redirectAction ?: "review"
            // params:['requisitionItem.id':requisitionItem.id]
            redirect(controller: "requisition", action: redirectAction, id: requisitionItem?.requisition?.id)
        }
        else {
            flash.message = "${warehouse.message(code: 'default.not.found.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), params.id])}"
            redirect(controller: "requisition", action: "list")
        }
    }
    /**
     * Allow user to undo changes made during the review process.
     */
    def undoChanges = {
        log.info "cancel quantity = " + params
        def requisitionItem = RequisitionItem.get(params.id)
        if (requisitionItem) {
            requisitionItem.undoChanges()
            //requisitionItem.save();
            def redirectAction = params?.redirectAction ?: "review"
            // For now we don't need to choose the selected requisition item (e.g. params:['requisitionItem.id':requisitionItem.id])
            redirect(controller: "requisition", action: redirectAction,
                    id: requisitionItem?.requisition?.id)
        }
        else {
            flash.message = "${warehouse.message(code: 'default.not.found.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), params.id])}"
            redirect(controller: "requisition", action: "list")
        }
    }

    /**
     * Allow user to choose substitute during the review process.
     */
    def chooseSubstitute = {
        log.info "choose substitute " + params
        def redirectAction = params?.redirectAction ?: "review"
        def requisitionItem = RequisitionItem.get(params.id)
        def product = Product.get(params.productId)
        def productPackage = ProductPackage.get(params.productPackageId)
        if (requisitionItem) {

            try {
                requisitionItem.chooseSubstitute(product, productPackage, params.quantity as int, params.reasonCode, params.comments)
            } catch(ValidationException e) {
                requisitionItem.errors = e.errors
                flash.errors = e.errors
            }

            // If there are errors we want to render the review page with those errors
            if (requisitionItem.hasErrors()) {
                flash.message = "errors"


                chain(controller: "requisition", action: redirectAction, id: requisitionItem?.requisition?.id,
                        params:['requisitionItem.id': requisitionItem.id,actionType:params.actionType], model: [selectedRequisitionItem:requisitionItem])
                return;
            }
        }
        else {
            flash.message = "${warehouse.message(code: 'default.not.found.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), params.id])}"
            redirect(controller: "requisition", action: "list")
            return;
        }
        redirect(controller: "requisition", action: redirectAction, id: requisitionItem?.requisition?.id)

    }


    /** ========================================================================================================================= */

    /**
     *
     */
	def cancelPicking = {
		log.info "Cancel requisition item " + params
		
		def requisitionItem = RequisitionItem.get(params.id)
		if (requisitionItem) {
            requisitionItem.cancelQuantity(params.reasonCode, params.comments)
			//requisitionItem.properties = params
			//requisitionItem.quantityCanceled = requisitionItem.calculateQuantityRemaining()
			//requisitionItem.save(flush:true)
			redirect(controller: "requisition", action: "pick", id: requisitionItem?.requisition?.id , params:['requisitionItem.id':requisitionItem.id])
		}
		else { 
			flash.message = "${warehouse.message(code: 'default.not.found.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), params.id])}"
			redirect(controller: "requisition", action: "list")

		}
    }


    def undoCancelPicking = {
        println params
		def requisitionItem = RequisitionItem.get(params.id)
		if (requisitionItem) {
			requisitionItem.quantityCanceled = 0 
			requisitionItem.cancelComments = null
			requisitionItem.cancelReasonCode = null
			requisitionItem.save(flush:true)
			redirect(controller: "requisition", action: "pick", id: requisitionItem?.requisition?.id, params:['requisitionItem.id':requisitionItem.id])
		}
		else {
			flash.message = "${warehouse.message(code: 'default.not.found.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), params.id])}"
			redirect(controller: "requisition", action: "list")

		}
	}

    def undoCancelReviewing = {
        println "Undo changes: " + params
        def requisitionItem = RequisitionItem.get(params.id)
        if (requisitionItem) {
            requisitionItem.quantityCanceled = 0
            requisitionItem.cancelComments = null
            requisitionItem.cancelReasonCode = null
            requisitionItem.save(flush:true)
            redirect(controller: "requisition", action: "review", id: requisitionItem?.requisition?.id, params:['requisitionItem.id':requisitionItem.id])
        }
        else {
            flash.message = "${warehouse.message(code: 'default.not.found.message', args: [warehouse.message(code: 'requisitionItem.label', default: 'RequisitionItem'), params.id])}"
            redirect(controller: "requisition", action: "list")

        }
    }

    def addAddition = {
        log.info "add addition " + params
        /*
		def requisition = Requisition.get(params.id)
		def requisitionItem = RequisitionItem.get(params.requisitionItem.id)

		def supplementalItem = new RequisitionItem(params)
        supplementalItem.requisition = requisition
        supplementalItem.parentRequisitionItem = requisitionItem
		requisition.addToRequisitionItems(supplementalItem)
		requisitionItem.addToRequisitionItems(supplementalItem)
		if (!supplementalItem.hasErrors() && supplementalItem.save()) {
			flash.message = "saved substitution item " + supplementalItem
		}
		*/
        redirect(controller: "requisition", action: "review", id: requisition?.id)
    }

    def addSubstitution = {
        log.info "add substitution " + params
        /*
		def requisition = Requisition.get(params.id)
		def requisitionItem = RequisitionItem.get(params.requisitionItem.id)
		requisitionItem.cancelReasonCode = params.parentCancelReasonCode
		requisitionItem.quantityCanceled = requisitionItem.quantity

		def substitutionItem = new RequisitionItem(params)
		substitutionItem.requisition = requisition
		substitutionItem.parentRequisitionItem = requisitionItem
		requisition.addToRequisitionItems(substitutionItem)
		requisitionItem.addToRequisitionItems(substitutionItem)
		if (!substitutionItem.hasErrors() && substitutionItem.save()) {
			flash.message = "saved substitution item " + substitutionItem
		}
		*/
        redirect(controller: "requisition", action: "review", id: requisition?.id)
    }



    def undoChangeQuantity = {
        def requisition = Requisition.get(params.id)
        def requisitionItem = RequisitionItem.get(params?.requisitionItem?.id)

        try {
            requisitionItem.cancelComments = null
            requisitionItem.cancelReasonCode = null
            requisitionItem.quantityCanceled = 0
            requisitionItem.requisitionItems.clear();
            requisitionItem.save(flush: true)
        } catch(Exception e) {
            flash.message = "Unable to undo quantity change: " + e.message
        }

        redirect(controller: "requisition", action: "review", id: requisitionItem?.requisition?.id)



    }

    def substitute = {
        println "substitute " + params
        def requisitionItem = RequisitionItem.get(params.requisitionItem.id)
        def requisition = Requisition.get(params.id)
        def picklist = Picklist.findByRequisition(requisition)

        def inventoryItem = InventoryItem.get(params.inventoryItem.id)
        if (!inventoryItem) {
            flash.message = "Could not find inventory item with lot number '${params.lotNumber}'"
        }
        else {
            def picklistItem = new PicklistItem()
            picklistItem.inventoryItem = inventoryItem
            picklistItem.requisitionItem = requisitionItem
            picklistItem.quantity = Integer.valueOf(params.quantity)
            picklist.addToPicklistItems(picklistItem);
            picklist.save(flush:true)
        }

        chain(action: "pick", id: requisition.id, params: ['requisitionItem.id':requisitionItem.id])
    }

}
