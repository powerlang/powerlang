Class {
	#name : #SNestedDynamicBinding,
	#superclass : #SDynamicBinding,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SNestedDynamicBinding class >> decodeUsing: anAstcodeDecoder [
	^ anAstcodeDecoder decodeNestedDynamicVar
]

{ #category : #accessing }
SNestedDynamicBinding >> lookupWithin: anEvaluationContext [
	cache := anEvaluationContext staticBindingForNested: name
]
