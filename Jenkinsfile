node ( "linux && x86_64" ) { ws {
    stage ( "Checkout" ) {
        checkout scm
        checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'specs/bee-dmr']], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/powerlang/bee-dmr.git']]])
        writeFile file: 'specs/current', text: 'bee-dmr'
    }

    stage ( "Compile" ) {
        sh "make"
    }

    stage ( "Test" ) {
        sh "make test"
        junit 'test-reports/*-Test.xml'
    }
}}
