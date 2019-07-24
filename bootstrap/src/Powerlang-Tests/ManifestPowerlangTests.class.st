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
	^ #(#(#(#RGClassDefinition #(#SmalltalkScannerTest)) #'2019-07-23T20:01:17.988314-03:00') )
]
