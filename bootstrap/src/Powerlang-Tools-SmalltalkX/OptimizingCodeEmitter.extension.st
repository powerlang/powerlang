Extension { #name : #OptimizingCodeEmitter }

{ #category : #'*Powerlang-Tools-SmalltalkX' }
OptimizingCodeEmitter >> assemblers [
	^ assemblers
]

{ #category : #'*Powerlang-Tools-SmalltalkX' }
OptimizingCodeEmitter class >> performedSelectors [
	| proto |

	proto := self basicNew.
	proto initializeAssemblers.
	^ super performedSelectors ,
	  (proto assemblers values collect: [ :e | (#assemble , e , #'Constant:') ]) ,
	  (proto assemblers values collect: [ :e | (#assemble , e , #':') ])  

	"
	self performedSelectors
	"

]
