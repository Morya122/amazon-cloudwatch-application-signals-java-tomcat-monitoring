#!/bin/bash
# Check if the number of arguments is not equal to two
if [ "$#" -ne 2 ]; then
    echo "Error: Tomcat version and maven version are not provided."
    echo "Usage: $0 TOMCAT10_VERSION MAVEN_VERSION"
    exit 1
fi

#Parse Apache Tomcat 10 version using version argument
tomcat_download_link=https://dlcdn.apache.org/tomcat/tomcat-10/v$1/bin/apache-tomcat-$1.tar.gz
tomcat_package_tar=$(echo "$tomcat_download_link" | grep -oE "apache-tomcat-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz")
tomcat_package=$(echo "$tomcat_package_tar" | grep -oE "apache-tomcat-[0-9]+\.[0-9]+\.[0-9]+")

#Parse Apache Maven Download link using version argument
maven_link=https://dlcdn.apache.org/maven/maven-3/$2/binaries/apache-maven-$2-bin.tar.gz
maven_package_tar=$(echo "$maven_link" | grep -oE "apache-maven-[0-9]+\.[0-9]+\.[0-9]+-bin\.tar\.gz")
maven_package=$(echo "$maven_package_tar" | grep -oE "apache-maven-[0-9]+\.[0-9]+\.[0-9]+")

############################################
#Function section
# Function to install Maven
install_maven() {
    echo "Installing Apache Maven..."
    echo "Installing Maven Package $maven_package"
    wget $maven_link
    tar -xvzf $maven_package_tar
    sudo mv $maven_package apache-maven
    sudo mv apache-maven /opt/
    echo 'export PATH=/opt/apache-maven/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc
    mvn -version
    echo "Maven installed successfully."
}
# Function to install git
install_git(){
    echo "Installing Git..."
    sudo yum install git -y 
    echo "Git installed successfully."
}
#function to clone repo
clone_repo(){
    echo "Cloning from Git Repo"
    # Clone the Git repository
    sudo git clone https://github.com/koddas/war-web-project.git $HOME/project
}
# Function to clone Git repository and build WAR file
build_war() {
    echo "Creating WAR File"
    cd project
    # Build the project using Maven
    sudo /opt/apache-maven/bin/mvn clean package -DskipTests
    # Check if the WAR file is created successfully
    if [ -f target/*.war ]; then
        printf "\n####################################################################"
        echo "WAR file created successfully."
        printf "####################################################################\n"
        # Optionally, you can copy the WAR file to a desired location
        # cp target/*.war /path/to/destination
    else
        printf "\n####################################################################"
        echo "Failed to create WAR file. Check the Maven build output for errors."
        printf "####################################################################\n"
        exit 1
    fi
}
# Function to install CW agent
install_cw_agent(){
    # Install CloudWatch Agent
    wget https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
    sudo rpm -U ./amazon-cloudwatch-agent.rpm
}
############################################
# Install Java 17
sudo yum update
sudo amazon-linux-extras enable corretto8
sudo yum install java-17-amazon-corretto-devel -y
java -version
# Download and Install Tomcat 10.*
############################################
# Check if Tomcat is installed, if not exit.
if [ -f "/opt/tomcat/bin/startup.sh" ]; then
    printf "\n####################################################################"
    echo "Tomcat $tomcat_package server was already istalled!!"
    printf "####################################################################\n"
else
    #Download tomcat binary
    wget $tomcat_download_link
    #unzip tomcat binary
    tar -zvxf apache-tomcat-*
    #Rename to tomcat for simplicity
    mv $tomcat_package tomcat
    sudo mv tomcat /opt/
    if [ -f "/opt/tomcat/bin/startup.sh" ]; then
        printf "\n####################################################################"
        echo "Tomcat $tomcat_package server is istalled!!"
        printf "####################################################################\n"
    else
        printf "\n####################################################################"
        echo "Tomcat $tomcat_package installation failed. Thus exiting the script. Please resolve the errors and rerun script"
        printf "####################################################################\n"
        exit 1
    fi  
fi
####################################################################
#Installing CloudWatch Agent
#moving to Home directory
cd
printf "\n####################################################################"
echo "Installing CloudWatch agent."
printf "####################################################################\n"
#installing CW agent.
install_cw_agent

####################################################################
# Download ADOT Java Agent
#moving to Home directory
cd
wget https://github.com/aws-observability/aws-otel-java-instrumentation/releases/latest/download/aws-opentelemetry-agent.jar
sudo mv aws-opentelemetry-agent.jar /opt/aws/
####################################################################################################################
#Installing Maven, creating WAR file, Moving WAR file to Tomcat webapp directory and creating needed environment variables in tomcat bin directory
#moving to Home directory
cd
# Check if Maven is installed, if not, install it
if [ -f "/opt/apache-maven/bin/mvn" ]; then
    echo "Maven is already installed."
else
    install_maven
fi
# Check if git is installed, if not, install it
if command -v git &>/dev/null; then
    echo "Git is already installed."
else
    install_git
fi
# Check if WAR is already created ,Build the WAR file if not created
if [ -f "$HOME/project/target/*.war" ]; then
    echo "WAR file already found under project folder."
elif [ -f "$HOME/project/pom.xml" ]; then
    echo "repo already cloned building WAR.."
    build_war
else
    clone_repo
    build_war
fi
# Define paths
war_file="$HOME/project/target/war-web-project.war"
tomcat_directory="/opt/tomcat"
webapps_directory="$tomcat_directory/webapps"
# Move the WAR file from project directory to Tomcat webapps directory
sudo mv "$war_file" "$webapps_directory/"
printf "\n####################################################################"
echo "Successfully moved WAR file to webapps in $webapps_directory directory"
printf "####################################################################\n"
