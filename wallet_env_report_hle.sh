#!/bin/bash

cd /opt/jenkins/kms
gcloud config set project kohls-mobile-hle

gcloud config set account mdop-admin@kohls-mobile-hle.iam.gserviceaccount.com

gcloud auth activate-service-account mdop-admin@kohls-mobile-hle.iam.gserviceaccount.com --key-file=mdop-admin.json

cd ${WORKSPACE}

echo "<h1 align=center> <marquee><i>Wallet HLE Environment Details</i></marquee> </h1>" >Wallet_Env_Report.html
echo "<table  border=\"1\" align=\"center\">" >>Wallet_Env_Report.html
echo "<tr><th colspan=\"3\" >Page Updated Time --> $(date +%Y-%m-%d_%H-%M-%S_%Z)</th></tr>" >>Wallet_Env_Report.html
Cluster_name=""
for clusterNumber in {1..6}; do
  if [[ $clusterNumber == 1 ]]; then
    gcloud container --project "kohls-mobile-hle" clusters get-credentials walletservices-hle-usc1 --zone="us-central1-b"
    echo "<tr><th colspan=\"3\" bgcolor="#00ffcc">Cluser Name  --> HLE QA US CENTRAL / walletservices-hle-usc1 </th></tr>" >> Wallet_Env_Report.html
    Cluster_name="walletservices-hle-usc1"
  elif [[ $clusterNumber == 2 ]]; then
    gcloud container --project "kohls-mobile-hle" clusters get-credentials walletservices-hle-use1 --zone="us-east1-b"
    echo "<tr><th colspan=\"3\" bgcolor="#00ffcc">Cluser Name  --> HLE QA US EAST /  walletservices-hle-use1</th></tr>" >> Wallet_Env_Report.html
    Cluster_name="walletservices-hle-use1"
  elif [[ $clusterNumber == 3 ]]; then
    gcloud container --project "kohls-mobile-hle" clusters get-credentials walletservices-perf-usc1 --zone="us-central1-b"
    echo "<tr><th colspan=\"3\" bgcolor="#00ffcc">Cluser Name  --> HLE PERF US CENTRAL / walletservices-perf-usc1 </th></tr>" >> Wallet_Env_Report.html
    Cluster_name="walletservices-perf-usc1"
  elif [[ $clusterNumber == 4 ]]; then
    gcloud container --project "kohls-mobile-hle" clusters get-credentials walletservices-perf2-usc1 --zone="us-central1-b"
    echo "<tr><th colspan=\"3\" bgcolor="#00ffcc">Cluser Name  --> HLE PERF2 US CENTRAL / walletservices-perf2-usc1 </th></tr>" >> Wallet_Env_Report.html
    Cluster_name="walletservices-perf2-usc1"
  elif [[ $clusterNumber == 5 ]]; then
    gcloud container --project "kohls-mobile-hle" clusters get-credentials walletservices-perf-use1 --zone="us-east1-b"
    echo "<tr><th colspan=\"3\" bgcolor="#00ffcc">Cluser Name  --> HLE PERF US EAST / walletservices-perf-use1 </th></tr>" >> Wallet_Env_Report.html
    Cluster_name="walletservices-perf-use1"
  elif [[ $clusterNumber == 6 ]]; then
    gcloud container --project "kohls-mobile-hle" clusters get-credentials walletservices-webstore-perf1-usc1 --zone="us-central1-b"
    echo "<tr><th colspan=\"3\" bgcolor="#00ffcc">Cluser Name  --> HLE Webstore PERF US CENTRAL / walletservices-webstore-perf1-usc1 </th></tr>" >> Wallet_Env_Report.html
    Cluster_name="walletservices-webstore-perf1-usc1"
  fi

  /usr/local/bin/kubectl get namespaces | grep ingress >namespaces
  cat namespaces | cut -d' ' -f1 >ingressnamespaces.txt
  ingressnamespaces=$(cat ingressnamespaces.txt)
  for ingressnamespace in $ingressnamespaces; do
    echo "ingressnamespace --> $ingressnamespace"
    if [ "$ingressnamespace" != "" ]; then
      echo "insdie $ingressnamespace"
      old="$IFS"
      IFS=$'\n'
      /usr/local/bin/kubectl get service -o=custom-columns=NAME:.metadata.name,NAME:.spec.selector.version --namespace=$ingressnamespace | grep -v NAME | grep -v VERSION >DeploymentVersionList.txt
      cat DeploymentVersionList.txt
      DeploymentVersionListFile=$(cat DeploymentVersionList.txt)

      for DeploymentVersion in $DeploymentVersionListFile; do
        if [ "$DeploymentVersion" != "" ]; then
          Service_Name=$(echo $DeploymentVersion | tr -s ' ' | cut -d ' ' -f1)
          echo "Service_Name ----> $Service_Name"
          DeploymentVersion=$(echo $DeploymentVersion | tr -s ' ' | cut -d ' ' -f2)
          echo "DeploymentVersion----> $DeploymentVersion"

          IFS="$old"
          /usr/local/bin/kubectl get deployment -o=custom-columns=NAME:.metadata.name -l version==$DeploymentVersion --namespace=$ingressnamespace | grep -v NAME >deploymentList.txt
          #sed -i "1d" deploymentList.txt

          for deploymentName in "$(cat deploymentList.txt)"; do
            Pods_Counts=$(/usr/local/bin/kubectl get --no-headers=true pods -o name -l version==$DeploymentVersion --namespace=$ingressnamespace)
            echo "Pods_Counts --> $Pods_Counts"
            echo "Service_Name --> $Service_Name"
            echo "deploymentName --> $deploymentName"
            if [[ "$deploymentName" != "" && "$Pods_Counts" != "" ]]; then
              echo "<tr><th>env_name</th><th colspan=\"2\" bgcolor=\"green\">$(echo $ingressnamespace | sed 's/ingress-//g')</th></tr>" >>Wallet_Env_Report.html
              if [[ "$ingressnamespace" == "ingress-relqa" && "$Cluster_name" == "walletservices-hle-usc1" ]]; then
                echo "<tr><td></td><td>Wallet service/akamai URL</td><td>wallet-qa.kohlsecommerce.com</td></tr>" >>Wallet_Env_Report.html
                echo "<tr><td></td><td>Origin URL</td><td>wallet-qa-uscentral1.hle-mcommerce.kohls.com</td></tr>" >>Wallet_Env_Report.html
              elif [[ "$ingressnamespace" == "ingress-relqa" && "$Cluster_name" == "walletservices-hle-use1" ]]; then
                echo "<tr><td></td><td>Wallet service/akamai URL</td><td>wallet-qa2.kohlsecommerce.com</td></tr>" >>Wallet_Env_Report.html
                echo "<tr><td></td><td>Origin URL</td><td>wallet-qa-useast1.hle-mcommerce.kohls.com</td></tr>" >>Wallet_Env_Report.html
              elif [[ "$ingressnamespace" == "ingress-svctest1" && "$Cluster_name" == "walletservices-hle-use1" ]]; then
                echo "<tr><td></td><td>Wallet service/akamai URL</td><td>wallet-int.kohlsecommerce.com</td></tr>" >>Wallet_Env_Report.html
                echo "<tr><td></td><td>Origin URL</td><td>wallet-svctest1-useast1.hle-mcommerce.kohls.com</td></tr>" >>Wallet_Env_Report.html
              elif [[ "$ingressnamespace" == "ingress-svctest2" && "$Cluster_name" == "walletservices-hle-use1" ]]; then
                echo "<tr><td></td><td>Wallet service/akamai URL</td><td>wallet-int2.kohlsecommerce.com</td></tr>" >>Wallet_Env_Report.html
                echo "<tr><td></td><td>Origin URL</td><td>wallet-svctest2-useast1.hle-mcommerce.kohls.com</td></tr>" >>Wallet_Env_Report.html
              elif [[ "$ingressnamespace" == "ingress-perf" && "$Cluster_name" == "walletservices-perf-usc1" ]]; then
                echo "<tr><td></td><td>Wallet service/akamai URL</td><td>wallet-perf.kohlsecommerce.com</td></tr>" >>Wallet_Env_Report.html
                echo "<tr><td></td><td>Origin URL</td><td>wallet-perf-uscentral1.hle-mcommerce.kohls.com</td></tr>" >>Wallet_Env_Report.html
              elif [[ "$ingressnamespace" == "ingress-perf" && "$Cluster_name" == "walletservices-perf2-usc1" ]]; then
                echo "<tr><td></td><td>Wallet service/akamai URL</td><td>wallet-perf2.kohlsecommerce.com</td></tr>" >>Wallet_Env_Report.html
                echo "<tr><td></td><td>Origin URL</td><td>wallet-perf2-uscentral1.hle-mcommerce.kohls.com</td></tr>" >>Wallet_Env_Report.html
              elif [[ "$ingressnamespace" == "ingress-perf" && "$Cluster_name" == "walletservices-perf-use1" ]]; then
                echo "<tr><td></td><td>Wallet service/akamai URL</td><td>NA</td></tr>" >>Wallet_Env_Report.html
                echo "<tr><td></td><td>Origin URL</td><td>wallet-perf-useast1.hle-mcommerce.kohls.com</td></tr>" >>Wallet_Env_Report.html
              elif [[ "$ingressnamespace" == "ingress-perf" && "$Cluster_name" == "walletservices-webstore-perf1-usc1" ]]; then
                echo "<tr><td></td><td>Wallet service/akamai URL</td><td>wallet-perfsvc.kohlsecommerce.com</td></tr>" >>Wallet_Env_Report.html
                echo "<tr><td></td><td>Origin URL</td><td>wallet-perfsvc-uscentral1.hle-mcommerce.kohls.com</td></tr>" >>Wallet_Env_Report.html
              else
                echo "<tr><td></td><td>service URL</td><td>$(echo $ingressnamespace | sed 's/ingress-//g').hle-mcommerce.kohls.com</td></tr>" >>Wallet_Env_Report.html
              fi

              echo "### START OF Ingress ###"
              Image_Name=$(/usr/local/bin/kubectl get pods -o=jsonpath='{.items[0].spec.containers[0].image}' --namespace=$ingressnamespace | cut -d '/' -f3 | cut -d ':' -f2)
              Current_Pods=$(kubectl get deployment $deploymentName -o=jsonpath='{.spec.replicas}' --namespace=$ingressnamespace)
              Min_Replicas=$(kubectl get hpa $deploymentName -o=jsonpath='{.spec.minReplicas}' --namespace=$ingressnamespace)
              Max_Replicas=$(kubectl get hpa $deploymentName -o=jsonpath='{.spec.maxReplicas}' --namespace=$ingressnamespace)
              Target_CPU_Percentage=$(kubectl get hpa $deploymentName -o=jsonpath='{.spec.targetCPUUtilizationPercentage}' --namespace=$ingressnamespace)

              Limits_cpu=$(kubectl get deployment $deploymentName -o=jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' --namespace=$ingressnamespace)
              Limits_memory=$(kubectl get deployment $deploymentName -o=jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' --namespace=$ingressnamespace)

              echo "<tr><td></td><td colspan=\"2\" align=\"center\"><b>$Service_Name</b></td></tr>" >>Wallet_Env_Report.html
              echo "<tr><td></td><td>NameSpace </td><td>$ingressnamespace</td></tr>" >>Wallet_Env_Report.html
              echo "<tr><td></td><td>Image_Name</td><td>$Image_Name</td></tr>" >>Wallet_Env_Report.html
              echo "<tr><td></td><td>Current_Pods</td><td>$Current_Pods</td></tr>" >>Wallet_Env_Report.html

              if [ "$Min_Replicas" != "" ]; then
                echo "<tr><td></td><td>Min_Replicas</td><td>$Min_Replicas</td></tr>" >>Wallet_Env_Report.html
                echo "Min_Replicas --> $Min_Replicas"
              fi
              if [ "$Max_Replicas" != "" ]; then
                echo "<tr><td></td><td>Max_Replicas</td><td>$Max_Replicas</td></tr>" >>Wallet_Env_Report.html
                echo "Max_Replicas --> $Max_Replicas"
              fi
              if [ "$Target_CPU_Percentage" != "" ]; then
                echo "<tr><td></td><td>Target_CPU_Percentage</td><td>$Target_CPU_Percentage</td></tr>" >>Wallet_Env_Report.html
                echo "Target_CPU_Percentage --> $Target_CPU_Percentage"
              fi

              echo "<tr><td></td><td>Limits_cpu</td><td>$Limits_cpu</td></tr>" >>Wallet_Env_Report.html
              echo "<tr><td></td><td>Limits_memory</td><td>$Limits_memory</td></tr>" >>Wallet_Env_Report.html
              echo "### END OF INGRESS ###"

              siteConigVersion=$(/usr/local/bin/kubectl get deployment $deploymentName --namespace=$ingressnamespace -o yaml | grep "name: sites-config" | cut -d':' -f2 | cut -d' ' -f2)
              echo "siteConigVersion -->$siteConigVersion"
              /usr/local/bin/kubectl get configmap $siteConigVersion --namespace=$ingressnamespace -o yaml | grep svc.cluster.local | grep -v { | grep -v http >endpoints.txt
              sed -i "s/server//g" endpoints.txt
              sed -i "s/ //g" endpoints.txt
              endpoints=$(cat endpoints.txt)
              for endpoint in $endpoints; do
                echo $endpoint
                endpointServiceName=$(echo $endpoint | tr -d ' ' | cut -d'.' -f1 | sed "s/http:\/\///g")
                endpointNameSpace=$(echo $endpoint | cut -d'.' -f2)
                echo "endpointServiceName --> $endpointServiceName ; endpointNameSpace --> $endpointNameSpace"
                echo "<tr><td></td><td colspan=\"2\" align=\"center\"><b>$endpointServiceName</b></td></tr>" >>Wallet_Env_Report.html
                echo "<tr><td></td><td>NameSpace </td><td>$endpointNameSpace</td></tr>" >>Wallet_Env_Report.html

                serviceDeploymentVersion=$(/usr/local/bin/kubectl get service $endpointServiceName -o=custom-columns=NAME:.spec.selector.version --namespace=$endpointNameSpace | grep -v NAME | grep -v VERSION)
                if [ "$serviceDeploymentVersion" != "" ]; then
                  /usr/local/bin/kubectl get deployment -o=custom-columns=NAME:.metadata.name -l version==$serviceDeploymentVersion --namespace=$endpointNameSpace | grep -v NAME >servicedeploymentList.txt

                  for servicedeploymenName in "$(cat servicedeploymentList.txt)"; do
                    echo "servicedeploymenName --> $servicedeploymenName"
                    if [ "$servicedeploymenName" != "" ]; then
                      env_config=$(/usr/local/bin/kubectl get deployment $servicedeploymenName --namespace=$endpointNameSpace -o yaml | grep "name: env-config" | grep -v "env-config-volume" | cut -d':' -f2 | cut -d' ' -f2)
                      echo "env_config -->$env_config"
                      OAPI_DOMAIN=$(/usr/local/bin/kubectl get configmap $env_config --namespace=$endpointNameSpace -o yaml | grep -v annotations | awk '{gsub(/\\n/,"\n")}1' | tr -d ' ' | grep "^openapi.v1.secureurl" | cut -f2 -d"=" | sed "s/# OAPI//g" | sed "s/http:\/\///g" | sed "s/https:\/\///g" | sed 's/\\n//g' | cut -f1 -d"/")
                      OMNIPAY_DOMAIN=$(/usr/local/bin/kubectl get configmap $env_config --namespace=$endpointNameSpace -o yaml | grep -v annotations | awk '{gsub(/\\n/,"\n")}1' | tr -d ' ' | grep "^omnipay.secureurl" | cut -f2 -d"=" | sed "s/# OAPI//g" | sed "s/http:\/\///g" | sed "s/https:\/\///g" | sed 's/\\n//g' | cut -f1 -d"/")
                      WALLET_DOMAIN=$(/usr/local/bin/kubectl get configmap $env_config --namespace=$endpointNameSpace -o yaml | grep -v annotations | awk '{gsub(/\\n/,"\n")}1' | tr -d ' ' | grep "^wallet.api.url" | cut -f2 -d"=" | sed "s/# OAPI//g" | sed "s/http:\/\///g" | sed "s/https:\/\///g" | sed 's/\\n//g' | cut -f1 -d"/")

                      echo "<tr><td></td><td>OpenAPI</td><td>$OAPI_DOMAIN</td></tr>" >>Wallet_Env_Report.html
                      echo "<tr><td></td><td>OMNIPAY</td><td>$OMNIPAY_DOMAIN</td></tr>" >>Wallet_Env_Report.html
                      #echo "<tr><td></td><td>WALLET_DOMAIN</td><td>$WALLET_DOMAIN</td></tr>" >> Wallet_Env_Report.html

                      Branch_Name=$(/usr/local/bin/kubectl exec $(/usr/local/bin/kubectl get pods -o=jsonpath='{.items[0].metadata.name}' --namespace=$endpointNameSpace) --namespace=$endpointNameSpace -- curl -H "Accept: application/json" localhost:8080/actuator/info --silent | grep -o "branch.*}" | cut -d ',' -f1 | cut -d ':' -f2 | tr -d '}' | cut -d '/' -f2 | tr -d '"')
                      Commit_Time=$(/usr/local/bin/kubectl exec $(/usr/local/bin/kubectl get pods -o=jsonpath='{.items[0].metadata.name}' --namespace=$endpointNameSpace) --namespace=$endpointNameSpace -- curl -H "Accept: application/json" localhost:8080/actuator/info --silent | grep -o "\"commit\":{\"time\".*" | cut -d ',' -f1 | cut -d ':' -f3,4,5,6 | tr -d '"')
                      Deployment_Time=$(/usr/local/bin/kubectl exec $(/usr/local/bin/kubectl get pods -o=jsonpath='{.items[0].metadata.name}' --namespace=$endpointNameSpace) --namespace=$endpointNameSpace -- curl -H "Accept: application/json" localhost:8080/actuator/info --silent | grep -o ",\"time\":.*" | cut -d ',' -f2 | cut -d ':' -f2,3,4 | tr -d '}' | tr -d '"')
                      Commit_Id=$(/usr/local/bin/kubectl exec $(/usr/local/bin/kubectl get pods -o=jsonpath='{.items[0].metadata.name}' --namespace=$endpointNameSpace) --namespace=$endpointNameSpace -- curl -H "Accept: application/json" localhost:8080/actuator/info --silent | grep -o "\"id\".*" | cut -d ',' -f1 | cut -d ':' -f2 | tr -d '}' | tr -d '"')
                      Image_Name=$(/usr/local/bin/kubectl get pods -o=jsonpath='{.items[0].spec.containers[0].image}' --namespace=$endpointNameSpace | cut -d '/' -f3 | cut -d ':' -f2)

                      Current_Pods=$(kubectl get deployment $servicedeploymenName -o=jsonpath='{.spec.replicas}' --namespace=$endpointNameSpace)
                      Min_Replicas=$(kubectl get hpa $servicedeploymenName -o=jsonpath='{.spec.minReplicas}' --namespace=$endpointNameSpace)
                      Max_Replicas=$(kubectl get hpa $servicedeploymenName -o=jsonpath='{.spec.maxReplicas}' --namespace=$endpointNameSpace)
                      Target_CPU_Percentage=$(kubectl get hpa $servicedeploymenName -o=jsonpath='{.spec.targetCPUUtilizationPercentage}' --namespace=$endpointNameSpace)

                      Limits_cpu=$(kubectl get deployment $servicedeploymenName -o=jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' --namespace=$endpointNameSpace)
                      Limits_memory=$(kubectl get deployment $servicedeploymenName -o=jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' --namespace=$endpointNameSpace)

                      Egproxy_Host=$(/usr/local/bin/kubectl get pods -l version==$serviceDeploymentVersion -o=jsonpath='{.items[0].spec.containers[0].args[1]}' --namespace=$endpointNameSpace | tr ';' '\n' | grep host | cut -d '>' -f1 | tr -d "'" | sed "s/echo//g" | tr '\n' ' ')

                      ND_Version=$(/usr/local/bin/kubectl exec $(/usr/local/bin/kubectl get pods -l version==$serviceDeploymentVersion -o=jsonpath='{.items[0].metadata.name}' --namespace=$endpointNameSpace) --namespace=$endpointNameSpace -- cat /kohls/cavisson/netdiagnostics/etc/version | tr '\n' ' ')
                      echo "<tr><td></td><td>Branch_Name</td><td>$Branch_Name</td></tr>" >>Wallet_Env_Report.html
                      echo "<tr><td></td><td>Commit_Time</td><td>$Commit_Time</td></tr>" >>Wallet_Env_Report.html
                      echo "<tr><td></td><td>Commit_Id</td><td>$Commit_Id</td></tr>" >>Wallet_Env_Report.html
                      echo "<tr><td></td><td>Deployment_Time</td><td>$Deployment_Time</td></tr>" >>Wallet_Env_Report.html
                      echo "<tr><td></td><td>Deployment_Name</td><td>$servicedeploymenName</td></tr>" >>Wallet_Env_Report.html
                      echo "<tr><td></td><td>Image_Name</td><td>$Image_Name</td></tr>" >>Wallet_Env_Report.html
                      echo "<tr><td></td><td>Current_Pods</td><td>$Current_Pods</td></tr>" >>Wallet_Env_Report.html

                      if [ "$Min_Replicas" != "" ]; then
                        echo "<tr><td></td><td>Min_Replicas</td><td>$Min_Replicas</td></tr>" >>Wallet_Env_Report.html
                        echo "Min_Replicas--> $Min_Replicas"
                      fi
                      if [ "$Max_Replicas" != "" ]; then
                        echo "<tr><td></td><td>Max_Replicas</td><td>$Max_Replicas</td></tr>" >>Wallet_Env_Report.html
                        echo "Max_Replicas--> $Max_Replicas"
                      fi
                      if [ "$Target_CPU_Percentage" != "" ]; then
                        echo "<tr><td></td><td>Target_CPU_Percentage</td><td>$Target_CPU_Percentage</td></tr>" >>Wallet_Env_Report.html
                        echo "Target_CPU_Percentage--> $Target_CPU_Percentage"
                      fi
                      echo "<tr><td></td><td>Limits_cpu</td><td>$Limits_cpu</td></tr>" >>Wallet_Env_Report.html
                      echo "<tr><td></td><td>Limits_memory</td><td>$Limits_memory</td></tr>" >>Wallet_Env_Report.html
                      echo "<tr><td></td><td>Egproxy_Host</td><td>$Egproxy_Host</td></tr>" >>Wallet_Env_Report.html
                      echo "<tr><td></td><td>ND_Version</td><td>$ND_Version</td></tr>" >>Wallet_Env_Report.html
                    fi
                  done
                fi
              done
            fi
          done
        fi
      done
    fi
  done
done
echo "</table>" >>Wallet_Env_Report.html
