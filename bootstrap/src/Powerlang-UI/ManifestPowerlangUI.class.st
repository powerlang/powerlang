"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestPowerlangUI,
	#superclass : #PackageManifest,
	#category : #'Powerlang-UI-Manifest'
}

{ #category : #'code-critics' }
ManifestPowerlangUI class >> ruleRBSentNotImplementedRuleV1FalsePositive [
	^ #(#(#(#RGPackage #(#'Powerlang-UI')) #'2020-02-26T15:11:39.440217-03:00') )
]

{ #category : #'code-critics' }
ManifestPowerlangUI class >> ruleRBStringConcatenationRuleV1FalsePositive [
	^ #(#(#(#RGPackage #(#'Powerlang-UI')) #'2020-02-26T15:11:21.726644-03:00') )
]
