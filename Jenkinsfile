//node('TAW005')
//{

	env.WORKSPACE = 'C:/jenkins_home/workspace/valic-pso/Consumer-Valic-PipelineBuilder/valic-pso/master'
echo 'FINE TILL HERE'
	//env();

	//env.WORKSPACE=pwd()

	//try 

	//{ 
		stage 'Checkout'
		
			// temporary  code  for now 
			// def srcJob= build job: 'test-proj'
			// def sourceDir = srcJob.rawBuild.environment.WORKSPACE
			// echo "${sourceDir}"
		
			bat 'git init &&  git config http.sslVerify false'
			checkout([$class: 'GitSCM', branches: [[name: '*/master']],
			userRemoteConfigs: [[url: 'https://github.com/vmsiva/Valic-pso-master.git']]])

		stage 'Build'

			String appsHome = "C:/jenkins_home/apps"
				
			bat "\"${appsHome}/nuget/nuget.exe\" restore SampleWebApp.sln"
			bat "\"C:/Program Files (x86)/MSBuild/14.0/Bin/MSBuild.exe\" SampleWebApp.sln  /p:OutDir=target /p:Configuration=Debug /p:Platform=\"Any CPU\" /p:ProductVersion=1.0.0.${env.BUILD_NUMBER}"

		stage 'Test'    

			parallel unitTests: { 	
				bat "\"C:/jenkins_home/apps/NUnit.Framework-3.6.0/bin/net-4.5/nunitlite-runner.exe\" --result:TestResult.xml;format=nunit2  Tests/target/Tests.dll"
				step([$class: 'NUnitPublisher', testResultsPattern:'**/TestResult.xml', debug: false, keepJUnitReports: true, skipJUnitArchiver:false, failIfNoResults: true]) 
			},
			failFast: false
	  
		stage 'Code Analysis'

			String sonarMSBuild = "C:/jenkins_home/apps/sonar-scanner-msbuild"		

			//String sonarqube_host ="http://algsasc2tm0092.r1-core.r1.aig.net:9000/"        
			String projectKey     = "SampleWebApp"
			def currentDir      = pwd()

			bat "\"${sonarMSBuild}/SonarQube.Scanner.MSBuild.exe\" begin /s:${currentDir}/SonarQube.Analysis.xml  /k:\"${projectKey}\" /n:\"${projectKey}\" /v:\"1.0\" "
			bat "\"C:/Program Files (x86)/MSBuild/14.0/Bin/MSBuild.exe\" /t:Rebuild"
			bat "\"${sonarMSBuild}/MSBuild.SonarQube.Runner.exe\" end"

			//def response = httpRequest "http://algsasc2tm0092.r1-core.r1.aig.net:9000/api/qualitygates/project_status?projectKey=\"${projectKey}\""
			//def slurper = new groovy.json.JsonSlurper()
			//def result = slurper.parseText(response.content)                       
			//if (result.projectStatus.status == "ERROR") {
			//	currentBuild.result = 'FAILURE'
			//}else{
			//	currentBuild.result ='SUCCESS'
			//}


		stage 'Archive'

			def server = Artifactory.newServer url:'http://algsasc2tm0076.r1-core.r1.aig.net:8081/artifactory', username:'rsingh', password:'AKCp2Vp51q8fNPWgx1Cg2vLGVXBNW4BpKczxnXoePAxCCBMAEaEa9npCcb5TjeYvSM6ttaQqi'
			server.setBypassProxy(true)
			zip archive: true, dir: "DataLayer/target/", glob: '**', zipFile: "DataLayer-" + "${env.BUILD_NUMBER}" + ".zip"
			zip archive: true, dir: "ServiceLayer/target/", glob: '**', zipFile: "ServiceLayer-" + "${env.BUILD_NUMBER}" + ".zip"
			zip archive: true, dir: "SampleWebApp/target/", glob: '**', zipFile: "SampleWebApp-" + "${env.BUILD_NUMBER}" + ".zip"

			// find the path of assemblyInfo files of projects
			def sampleWebAppAssemblyInfo  = findFiles(glob: '**SampleWebApp/**/AssemblyInfo.cs')
			def serviceLayerAssemblyInfo  = findFiles(glob: '**ServiceLayer/**/AssemblyInfo.cs')
			def dataLayerAssemblyInfo     = findFiles(glob: '**DataLayer/**/AssemblyInfo.cs')

			// set major.minor.micro.buildnumber
			def sampleWebAppVersion =  sampleWebAppAssemblyInfo ? ( version ( sampleWebAppAssemblyInfo[0] )) : null
			sampleWebAppVersion = sampleWebAppVersion ? (sampleWebAppVersion + "." + env.BUILD_NUMBER) : env.BUILD_NUMBER

			def serviceLayerVersion =  serviceLayerAssemblyInfo ? ( version ( serviceLayerAssemblyInfo[0] )) : null
			serviceLayerVersion = serviceLayerVersion ? (serviceLayerVersion + "." + env.BUILD_NUMBER) : env.BUILD_NUMBER        

			def dataLayerVersion =  dataLayerAssemblyInfo ? ( version ( dataLayerAssemblyInfo[0] )) : null
			dataLayerVersion = dataLayerVersion ? (dataLayerVersion + "." + env.BUILD_NUMBER) : env.BUILD_NUMBER        

			def uploadSpec =
				'''{
				"files": [
					{
						"pattern": "DataLayer-*.zip",
						"target": "aig-generic-local/nuget/DataLayer-''' + "${dataLayerVersion}" + '''.zip"
					},
					{
						"pattern": "ServiceLayer-*.zip",
						"target": "aig-generic-local/nuget/ServiceLayer-''' + "${serviceLayerVersion}" + '''.zip"
						
					},
					{
						"pattern": "SampleWebApp-*.zip",
						"target": "aig-generic-local/nuget/SampleWebApp-''' + "${sampleWebAppVersion}" + '''.zip"
						
					}
				]
			}'''

			// Upload to Artifactory and publish.
			def buildInfo = server.upload spec: uploadSpec
			server.publishBuildInfo buildInfo

		currentBuild.result = "SUCCESS"
		env.REPOSITORY_FILE="SampleWebApp-${sampleWebAppVersion}.zip"
	    env.APPLICATION="SampleMvcApp"
	    env.$WEBAPP_PORT=8082

		stage 'Package'
			xldCreatePackage artifactsPath: 'SampleWebApp/', manifestPath: 'deployit-manifest.xml', darPath: '$JOB_NAME-$BUILD_NUMBER.0.dar'

		stage 'Publish'  
			xldPublishPackage serverCredentials: 'xl-deploy-prod', darPath: '$JOB_NAME-$BUILD_NUMBER.0.dar'

		stage 'Deploy'  
			xldDeploy serverCredentials: 'xl-deploy-prod', environmentId: 'Environments/Valic/DEV', packageId: 'Applications/Valic/$APPLICATION/$BUILD_NUMBER.0'

		stage 'Start XLR Release' 
			xlrCreateRelease serverCredentials: 'xl-release-prod', template: 'Digital Project Release Template', releaseTitle: 'Release for Valic $BUILD_TAG', 
							variables: [[propertyName: '${version}', propertyValue: '$BUILD_NUMBER.0'], 
							[propertyName: '${isProjectCharterNeeded}', propertyValue: 'false'], 
							[propertyName: '${applicationIDGEAR}', propertyValue: 'true'], 
							[propertyName: '${applicationFeasibilityStudy}', propertyValue: 'true'], 
							[propertyName: '${appName}', propertyValue: 'Valic'],
							[propertyName: '${isRealProject}', propertyValue: 'false']
							], 
							startRelease: true

	//}
	catch (err) {
		currentBuild.result = "FAILURE"    
		throw err
	}
	finally {
		// delete the build files if any 
		bat "del DataLayer*.zip /s/q >nul 2>&1  && del ServiceLayer*.zip /s/q >nul 2>&1 && del SampleWebApp*.zip /s/q >nul 2>&1 " 

		mail body: "It appears that ${env.BUILD_URL} with status = ${currentBuild.result}, workspace ${env.WORKSPACE}" ,
		from: 'noreply@ci-jenkins.org',
		replyTo: 'girdhar.katiyar@aig.com',
		subject: "${env.JOB_NAME} (${env.BUILD_NUMBER}) with status = ${currentBuild.result}",
		to: 'Rishi.Singh1@aig.com',
		cc: 'girdhar.katiyar@aig.com,praveen.rawat@aig.com,mudit.chaunal@aig.com'

		//    emailext attachLog: true, attachmentsPattern: '**/TestResult.xml', body: 'It appears that ${env.BUILD_URL} with status = ${currentBuild.result}', compressLog: true, replyTo: 'girdhar.katiyar@aig.com', subject: '${env.JOB_NAME} (${env.BUILD_NUMBER}) with status = ${currentBuild.result}', to: 'girdhar.katiyar@aig.com'
	}
//}

def version(def AssemblyInfo) {
	def matcher = readFile("${AssemblyInfo}") =~  '\\[assembly: AssemblyVersion\\("(\\d*).(\\d*).(\\d*)'
	def versionDetails = null
	matcher ? (versionDetails= matcher[0]) : null
	versionDetails ? ( versionDetails[1] + "."
					 + versionDetails[2] + "."
					 + versionDetails[3]
					  )
					 : null
}
