#!/bin/bash

# Colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# Cluster Region and Name
CLUSTER_NAME="roboshop-dev"
AWS_REGION="us-east-1"

EKS_TARGET_VERSION=$1

LOGS_FOLDER="/home/ec2-user/eks-cluster-upgrade"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER

echo "Script started executed at: $(date)" | tee -a $LOG_FILE

# Checking the args passed
if [ "$#" -ne 1 ]; then
  echo -e "${R}Usage:${N} $0 <EKS_TARGET_VERSION>" | tee -a "$LOG_FILE"
  echo -e "${R}Example:${N} $0 1.34" | tee -a "$LOG_FILE"
  exit 1
fi

# addons list of the cluster, we upgrade addons once control plane is upgraded
ADDONS=$(aws eks list-addons --cluster-name "$CLUSTER_NAME" --region "$AWS_REGION" --output text | awk '{print $2}')

# Function to validate 
VALIDATE(){ 
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

CURRENT_CP_VERSION = $(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query "cluster.version" --output text)
VALIDATE $? "Fenching the Current version of Control Plain"

echo -e "Current version of Control Plain  :${Y}${CURRENT_CP_VERSION}${N}" | tee -a "$LOG_FILE"
echo -e "Target version of Control Plain :${Y}${EKS_TARGET_VERSION}${N}" | tee -a "$LOG_FILE"

# Get the current and target Major and Minor versions
# in 1.33 -> 1 is Major version & 33 is minor version
CUR_MAJOR=$(echo "$CURRENT_CP_VERSION" | cut -d. -f1)
CUR_MINOR=$(echo "$CURRENT_CP_VERSION" | cut -d. -f2)

TGT_MAJOR=$(echo "$EKS_TARGET_VERSION" | cut -d. -f1)
TGT_MINOR=$(echo "$EKS_TARGET_VERSION" | cut -d. -f2)
# checking weather the input target minor version is empty or not
if [[ -z "$CUR_MAJOR" || -z "$CUR_MINOR" || -z "$TGT_MAJOR" || -z "$TGT_MINOR" ]]; then
    echo "${R} Unalbe to get the version ${N}. Current control plane version: ${CURRENT_CP_VERSION} & Target control plane version: ${EKS_TARGET_VERSION}" | tee -a "$LOG_FILE"
    echo "${Y} please exactly give version value. Eg: 1.33 or 1.34 ${N}"
    exit 1
fi
# checking the taret version is one minor version a head or not 
if [[ "$CUR_MAJOR" != "$TGT_MAJOR" || "$((TGT_MINOR - CUR_MINOR))" -ne 1 ]]; then
    echo -e "${R}ABORT:${N} Target version should be one minor version a head. Eg: 1.33 -> 1.34. Current control plane version: ${CURRENT_CP_VERSION} & Target control plane version: ${EKS_TARGET_VERSION}" | tee -a "$LOG_FILE"
    exit 1
fi

echo -e "${G}Version check passed:${N} upgrading from $CURRENT_CP_VERSION -> $EKS_TARGET_VERSION" | tee -a "$LOG_FILE"

echo "Upgrading control plane version" | tee -a "$LOG_FILE"
aws eks update-cluster-version \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --kubernetes-version "$EKS_TARGET_VERSION" &>> "$LOG_FILE"
VALIDATE $? "Trigger control plane upgrade"

get_cluster_status() {
  aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" \
    --query 'cluster.status' --output text
}

get_cluster_version() {
  aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" \
    --query 'cluster.version' --output text
}

wait_cluster_upgrading() {
    local experted=$1
    echo -e "${Y}Waiting for cluster to became active and Version=$experted........${N}" | tee -a "$LOG_FILE"

    while true; do
        status=$(get_cluster_status) 
        version=$(get_cluster_version)

        echo "Cluster status = $status and version = $version"
        if [[ "$status" == "ACTIVE" && "$version" == "$experted" ]]; then 
            echo -e "Control plane upgraded to $version ... ${G}SUCCESS${N}" | tee -a "$LOG_FILE"
            break
        fi

        if [[ "$status" == "FAILED" ]]; then
            echo -e "Control plane upgraded to $version ... ${G}FAILURE${N}" | tee -a "$LOG_FILE"
            exit 1
        fi
        sleep 60
    done
}

wait_cluster_upgrading "$EKS_TARGET_VERSION"

addon_installed() {
  aws eks describe-addon \
    --cluster-name "$CLUSTER_NAME" \
    --addon-name "$1" \
    --region "$AWS_REGION" \
    --query 'addon.addonName' --output text >/dev/null 2>&1
}

addon_version() {
  aws eks describe-addon \
    --cluster-name "$CLUSTER_NAME" \
    --addon-name "$1" \
    --region "$AWS_REGION" \
    --query 'addon.addonVersion' --output text 2>/dev/null || echo "UNKNOWN"
}

latest_compatible_addon_version() {
  local addon="$1"
  local cp_ver="$2"

  aws eks describe-addon-versions \
    --addon-name "$addon" \
    --region "$AWS_REGION" \
    --query "addons[0].addonVersions[?compatibilities[?clusterVersion=='${cp_ver}']].addonVersion" \
    --output text 2>/dev/null \
  | tr '\t' '\n' \
  | sort -V \
  | tail -n 1
}
latest_compatible_addon_version2() {
    local addon="$1"
    local cp_ver="$2"

    aws eks describe-addon-versions \
        --kubernetes-version "$cp_ver" \
        --region "$AWS_REGION" \
        --addon-name "$addon" \
        --query 'addons[].addonVersions[].addonVersion' \
        --output text | tr '\t' '\n' | sort -V | tail -n 1
}
addon_status() {
  aws eks describe-addon \
    --cluster-name "$CLUSTER_NAME" \
    --addon-name "$1" \
    --region "$AWS_REGION" \
    --query 'addon.status' --output text 2>/dev/null || echo "MISSING"
}

wait_addon_active_and_version(){
  local addon="$1"
  local expected="$2"
  echo -e "${Y}Waiting for addon $addon to be ACTIVE at version=$expected ...${N}"
  while true; do
    local st ver
    st=$(addon_status "$addon")
    ver=$(addon_version "$addon")
    echo -e "Addon $addon status=$st version=$ver"
    if [[ "$st" == "ACTIVE" && "$ver" == "$expected" ]]; then
      echo -e "${G}Addon $addon upgraded OK: $ver${N}"
      break
    fi
    if [[ "$st" == "DEGRADED" || "$st" == "UPDATE_FAILED" || "$st" == "FAILED" ]]; then
      echo -e "${R}Addon $addon upgrade problem: status=$st${N}"
      exit 1
    fi
    if [[ "$st" == "MISSING" ]]; then
      echo -e "${Y}Addon $addon not installed. Skipping wait.${N}"
      break
    fi
    sleep 20
  done
}

upgrade_addons_to_latest_compatible(){
  local cp_ver="$1"
  for addon in $ADDONS; do
    
    local current latest
    current=$(addon_version "$addon")
    latest=$(latest_compatible_addon_version "$addon" "$cp_ver")
    #echo "DEBUG: addon=$addon cp_ver=$cp_ver latest='$latest'" | tee -a "$LOG_FILE"

    if [[ -z "$latest" || "$latest" == "None" ]]; then
      echo -e "${R}Could not find compatible latest version for addon $addon on cluster $cp_ver${N}"
      exit 1
    fi

    echo -e "${Y}Addon $addon current=$current latest_compatible=$latest${N}"

    if [[ "$current" == "$latest" ]]; then
      echo -e "${G}Addon $addon already at latest compatible version${N}"
      continue
    fi

    aws eks update-addon \
      --cluster-name "$CLUSTER_NAME" \
      --addon-name "$addon" \
      --addon-version "$latest" \
      --resolve-conflicts PRESERVE \
      --region "$AWS_REGION" &>> "$LOG_FILE"
    VALIDATE $? "Update addon $addon -> $latest"

    wait_addon_active_and_version "$addon" "$latest"
  done
}


upgrade_addons_to_latest_compatible "$EKS_TARGET_VERSION"