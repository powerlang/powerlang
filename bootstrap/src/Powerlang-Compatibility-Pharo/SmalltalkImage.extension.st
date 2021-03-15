Extension { #name : #SmalltalkImage }

{ #category : #'*Powerlang-Core' }
SmalltalkImage >> associationAt: aSymbol [
	^globals associationAt: aSymbol
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
SmalltalkImage >> getPackageDirectoryForPackage: anRPackage [
	"Return a directory from which given package has been loaded.
	 
	 CAVEAT: This only works for packages loaded from GIT repository and
	 having in registered in Iceberg"
	
	| repo |
	repo := IceRepository registry 
					detect:[ :each | each loadedPackages contains: [:icep | icep name = anRPackage name ] ]
					ifNone:[ ^ nil ].
	^repo codeDirectory / anRPackage name

]

{ #category : #'*Powerlang-Compatibility-Pharo' }
SmalltalkImage >> host [
	"Return current host identification string (that is, identification
	of machine the smalltalk is currently running on). 

	The format of the string is that of GNU triplets except that 'vendor'
	part is ommited (mostly unused these days anyway). 

	Examples:   
			* x86_64-linux-gnu 
			* x86_64-win32
			* riscv64-linux-gnu
			
	CAVEAT: following code simply assumes that Pharo is used
	on x86_64 systems only and also assumes that if the OS is 
	not Windows nor macOS, it must be Linux (and not, for instance,
	FreeBSD or Solaris). 

	Is there a standard way to figure that out? 
	"
	
	| platform |
	
	platform := OSPlatform current.
		
	(platform isWin64 or: [platform isWin32 and: [Smalltalk vm wordSize = 8]]) ifTrue: [ ^'x86_64-win32' ].
	platform isMacOSX ifTrue:[ ^'x86_64-darwin' ].
	platform isUnix64 ifTrue:[ ^'x86_64-linux-gnu' ].
	
	self error: 'Unknown host!'
	
	







]
