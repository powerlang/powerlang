"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestPowerlangTestsFailing,
	#superclass : #PackageManifest,
	#category : #'Powerlang-TestsFailing-Manifest'
}

{ #category : #'code-critics' }
ManifestPowerlangTestsFailing class >> ruleRBSentNotImplementedRuleV1FalsePositive [
	^ #(#(#(#RGClassDefinition #(#BootstrapTest)) #'2020-10-12T12:05:39.124538-03:00') )
]
