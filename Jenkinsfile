pipeline {
    agent {
        node { label "AGENT-1" }
    } 

    options{
        timeout(time: 1, unit: 'HOURS')
        disableConcurrentBuilds()
        ansiColor('xterm') 
    }
    environment {
        PROJECT = 'roboshop'
        COMPONENT = '10-sg'
        AWS_REGION = 'us-east-1'
        AWS_ACC_ID = '793770371113'
    }
    parameters {
                string(name: 'APPLIED_BY',defaultValue: 'Anurag', description: 'Terraform apply by')
                choice(name: 'ENVIRONMENT', choices: ['dev', 'qa', 'prod'], description: 'Target environment')
                booleanParam(name: 'DESTROY_APPROVAL', defaultValue: false, description: 'Destroy resources')
            }
    stages {
        stage('triggering 70-ingress-alb'){
            when { expression { return params.DESTROY_APPROVAL } }
            steps{
                script{
                    script{
                        sh """
                            ls -l
                            cd 00-vpc
                            ls -l
                        """
                    }
                }   
            }
        }
        // stage("Triggering Downstreem Job parallelly to Destroy"){
        //     parallel{
        //         stage('triggering 20-bastion'){
        //             steps{
        //                 script{
        //                     build (
        //                         job: '20-bastion',
        //                         wait: false,
        //                         propagate: false,
        //                         parameters: [string(name: 'ENVIRONMENT',value: params.ENVIRONMENT), string(name: 'APPLIED_BY',value: env.COMPONENT)]
        //                     )
        //                 }   
        //             }
        //         }
        //         stage('triggering 30-sg-rules'){
        //             steps{
        //                 script{
        //                     build (
        //                         job: '30-sg-rules',
        //                         wait: false,
        //                         propagate: false,
        //                         parameters: [string(name: 'ENVIRONMENT',value: params.ENVIRONMENT), string(name: 'APPLIED_BY',value: env.COMPONENT)]
        //                     )
        //                 }   
        //             }
        //         }
        //         stage('triggering 40-ECR'){
        //             steps{
        //                 script{
        //                     build (
        //                         job: '40-ECR',
        //                         wait: false,
        //                         propagate: false,
        //                         parameters: [string(name: 'ENVIRONMENT',value: params.ENVIRONMENT), string(name: 'APPLIED_BY',value: env.COMPONENT)]
        //                     )
        //                 }   
        //             }
        //         }
        //         stage('triggering 60-ACM'){
        //             steps{
        //                 script{
        //                     build (
        //                         job: '60-ACM',
        //                         wait: true,
        //                         propagate: true,
        //                         parameters: [string(name: 'ENVIRONMENT',value: params.ENVIRONMENT), string(name: 'APPLIED_BY',value: env.COMPONENT)]
        //                     )
        //                 }   
        //             }
        //         }
        //         stage('triggering 80-EKS'){
        //             steps{
        //                 script{
        //                     build (
        //                         job: '80-EKS',
        //                         wait: false,
        //                         propagate: false,
        //                         parameters: [string(name: 'ENVIRONMENT',value: params.ENVIRONMENT), string(name: 'APPLIED_BY',value: env.COMPONENT)]
        //                     )
        //                 }   
        //             }
        //         }
        //     }
        // }

    }
    post {
        always{
            sh "echo 'this will be run always'"
            // cleanWs()
        }
        success {
            echo "✅ ${env.COMPONENT} created sucess"
            // slackSend / emailext go here (plugins)
        }
    }
}