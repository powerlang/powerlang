"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestPowerlangTests,
	#superclass : #PackageManifest,
	#category : #'Powerlang-Tests-Manifest'
}

{ #category : #'code-critics' }
ManifestPowerlangTests class >> ruleAssertEqualSignIntoAssertEqualsV1FalsePositive [
	^ #(#(#(#RGClassDefinition #(#SmalltalkScannerTest)) #'2019-07-23T20:01:17.988314-03:00') #(#(#RGPackage #(#'Powerlang-Tests')) #'2019-07-24T21:08:47.817591-03:00') )
]

{ #category : #'code-critics' }
ManifestPowerlangTests class >> ruleRBConsistencyCheckRuleV1FalsePositive [
	^ #(#(#(#RGPackage #(#'Powerlang-Tests')) #'2019-07-24T21:37:19.12369-03:00') )
]

{ #category : #'code-critics' }
ManifestPowerlangTests class >> ruleRBSentNotImplementedRuleV1FalsePositive [
	^ #(#(#(#RGPackage #(#'Powerlang-Tests')) #'2020-02-26T15:19:33.083731-03:00') )
]

{ #category : #'code-critics' }
ManifestPowerlangTests class >> ruleRBUncommonMessageSendRuleV1FalsePositive [
	^ #(#(#(#RGPackageDefinition #(#'Powerlang-Tests')) #'2020-11-17T16:21:46.297523-03:00') )
]
