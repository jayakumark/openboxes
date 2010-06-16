package org.pih.warehouse


/**
 * A drug may be classified by the chemical type of the active ingredient 
 * or by the way it is used to treat a particular condition.  Each drug can 
 * be classified into one or more drug classes.
 * 
 * See http://www.drugs.com/drug-classes.html?tree=1
 *
 */
class DrugClass extends Type {

	static belongsTo = [ parent : DrugClass ]
	
}