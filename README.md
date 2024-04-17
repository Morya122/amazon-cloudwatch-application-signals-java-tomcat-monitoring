## Monitoring Java application running on Tomcat server using Amazon CloudWatch Application Signals

This repository contains a script for [AWS Knowledge Center Blog](To Be insserted) demonstrating a AWS CloudWatch Application Signals setup for Java applications running in EC2. The script ```get_requirements.sh``` clones the [Spring Framework Petclinic Repository](https://github.com/spring-petclinic/spring-framework-petclinic.git), installs Cloudwatch Agent and deploys the Sample PetClinic Application as WAR file in Tomcat server.

## Architecture Overview

![AppSignalsJava drawio](https://github.com/aws-samples/amazon-cloudwatch-application-signals-java-tomcat-monitoring/assets/150599257/3b994b01-8bb4-404c-afdc-a66b1a5cf7b9)


## Usage

You need a EC2 instance as shared in Blog and can use below commands to clone the script.

```
git clone https://github.com/aws-samples/amazon-cloudwatch-application-signals-java-tomcat-monitoring
sudo chmod +x get_requirements.sh
TOMCAT_VER=10.1.19
MAVEN_VER=3.9.6 
sudo ./get_requirements.sh $TOMCAT_VER $MAVEN_VER
```

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

