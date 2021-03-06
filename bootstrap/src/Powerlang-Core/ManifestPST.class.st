"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestPST,
	#superclass : #PackageManifest,
	#category : #'Powerlang-Core-Manifest'
}

{ #category : #'code-critics' }
ManifestPST class >> ruleAssertEqualSignIntoAssertEqualsV1FalsePositive [
	^ #()
]

{ #category : #'code-critics' }
ManifestPST class >> ruleRBCodeCruftLeftInMethodsRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#MethodEvaluator #dispatchUndermessage: #false)) #'2020-05-12T15:13:21.078914-03:00') )
]

{ #category : #'code-critics' }
ManifestPST class >> ruleRBEmptyExceptionHandlerRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#SSmalltalkParser #methodFragment #false)) #'2019-07-29T21:47:48.456702-03:00') )
]

{ #category : #'code-critics' }
ManifestPST class >> ruleRBIfTrueReturnsRuleV1FalsePositive [
	^ #(#(#(#RGPackage #(#'Powerlang-Core')) #'2019-07-24T02:26:09.214605-03:00') )
]

{ #category : #'code-critics' }
ManifestPST class >> ruleRBLiteralArrayCharactersRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#SSmalltalkScanner #isBinary: #false)) #'2019-07-24T02:26:44.802941-03:00') )
]

{ #category : #'code-critics' }
ManifestPST class >> ruleRBNoClassCommentRuleV1FalsePositive [
	^ #(#(#(#RGClassDefinition #(#SExpression)) #'2019-05-26T03:31:15.275028-03:00') )
]

{ #category : #'code-critics' }
ManifestPST class >> ruleRBReturnsIfTrueRuleV1FalsePositive [
	^ #(#(#(#RGPackage #(#'Powerlang-Core')) #'2019-07-24T02:27:55.345612-03:00') )
]

{ #category : #'code-critics' }
ManifestPST class >> ruleRBSearchingLiteralRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#SSmalltalkScanner #nextColon #false)) #'2019-07-24T02:24:50.040758-03:00') #(#(#RGClassDefinition #(#SSmalltalkScanner)) #'2019-07-24T02:27:27.311656-03:00') )
]

{ #category : #'code-critics' }
ManifestPST class >> ruleRBStringConcatenationRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#SlotObjectMap #printOn: #false)) #'2019-05-19T00:11:27.865645-03:00') #(#(#RGMetaclassDefinition #(#'HeapModel class' #HeapModel)) #'2019-05-28T11:56:52.832767-03:00') #(#(#RGPackageDefinition #(#'Powerlang-Core')) #'2020-07-12T18:56:24.522032-03:00') )
]

{ #category : #'code-critics' }
ManifestPST class >> ruleRBTempsReadBeforeWrittenRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#ProjectSpec #load #false)) #'2019-05-22T01:07:44.263209-03:00') )
]

{ #category : #'code-critics' }
ManifestPST class >> ruleRBUnaryAccessingMethodWithoutReturnRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#InlinedMessageNativizer #inlineOr #false)) #'2020-06-18T04:18:13.832024-03:00') )
]

{ #category : #'code-critics' }
ManifestPST class >> ruleRBUncommonMessageSendRuleV1FalsePositive [
	^ #(#(#(#RGPackage #(#'Powerlang-Core')) #'2019-07-29T19:59:46.632993-03:00') )
]
