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
	| module |
	module := anEvaluationContext staticBindingFor: name first.
	cache := anEvaluationContext staticBindingFor: name second inModule: module
]
