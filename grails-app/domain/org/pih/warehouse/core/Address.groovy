package org.pih.warehouse.core

class Address {
	
	String address
    String address2
    String city
    String stateOrProvince
    String postalCode
    String country

    static constraints = {
		postalCode(nullable:true)
		stateOrProvince(nullable:true)
    }
}