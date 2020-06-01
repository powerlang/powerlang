node ( "linux && x86_64" ) { ws {
    stage ( "Checkout" ) {
        checkout scm
        checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'bootstrap/specs/bee-dmr']], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/powerlang/bee-dmr.git']]])
        writeFile file: 'bootstrap/specs/current', text: 'bee-dmr'
    }

    stage ( "Bootstrap" ) {
        sh  """
            make -C bootstrap
            make -C bootstrap test
            """
        junit 'bootstrap/test-reports/*-Test.xml'
    }
}}