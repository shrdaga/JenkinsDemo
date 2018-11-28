#!/bin/bash

#1 - change file name
#2 - target file name
#3 - target folder name

echo Source file: $1
echo Target name: $2
echo Folder name: $3

echo Searching for script file $1...
echo Searching for script file $2...
echo Searching for script file $3...
if [ -e $1 ]
then
  SCRIPTFILE=$3'/'$2'.xml'
  echo Scriptfile is: $SCRIPTFILE
  echo ===PKGXML===
  echo Creating new package.xml
  echo '<?xml version="1.0" encoding="UTF-8"?><Package></Package>' > $SCRIPTFILE
  while read CFILE
  do
    echo Analyzing file `basename $CFILE`
    case "$CFILE"
      in
      *.app) TYPENAME="CustomApplication";;
      *.appMenu) TYPENAME="AppMenu";;
      *.approvalProcess) TYPENAME="ApprovalProcess";;
      *.assignmentRules) TYPENAME="AssignmentRules";;
      *.asset) TYPENAME="ContentAsset";;
      *.autoResponseRules) TYPENAME="AutoResponseRules";;
      *.cls) TYPENAME="ApexClass";;
      *.community) TYPENAME="Community";;
      *.component) TYPENAME="ApexComponent";;
      *.connectedApp) TYPENAME="ConnectedApp";;
      *.crt) TYPENAME="Certificate";;
      *.customPermission) TYPENAME="CustomPermission";;
      *.duplicateRule) TYPENAME="DuplicateRule";;
      *.dataSource) TYPENAME="ExternalDataSource";;
      *.email) TYPENAME="EmailTemplate";;
      *.escalationRules) TYPENAME="EscalationRules";;
      *.flexipage) TYPENAME="FlexiPage";;
      *.globalValueSet) TYPENAME="GlobalValueSet";;
      *.group) TYPENAME="Group";;
      *.homePageLayout) TYPENAME="HomePageLayout";;
      *.labels) TYPENAME="CustomLabels";;
      *.layout) TYPENAME="Layout";;
      *.letter) TYPENAME="Letterhead";;
      *.LeadConvertSetting) TYPENAME="LeadConvertSettings";;
      *.managedTopics) TYPENAME="ManagedTopics";;
      *.matchingRule) TYPENAME="MatchingRule";;
      *.network) TYPENAME="Network";;
      *.object) TYPENAME="CustomObject";;
      *.objectTranslation) TYPENAME="CustomObjectTranslation";;
      *.page) TYPENAME="ApexPage";;
      *.permissionset) TYPENAME="PermissionSet";;
      *.profile) TYPENAME="Profile";;
      *.queue) TYPENAME="Queue";;
      *.quickAction) TYPENAME="QuickAction";;
      *.remoteSite) TYPENAME="RemoteSiteSettings";;
      *.reportType) TYPENAME="ReportType";;
      *.resource) TYPENAME="StaticResource";;
      *.role) TYPENAME="Role";;
      *.settings) TYPENAME="Settings";;
      *.sharingRules) TYPENAME="SharingRules";;
      *.standardValueSet) TYPENAME="StandardValueSet";;
      *.site) TYPENAME="CustomSite";;
      *.tab) TYPENAME="CustomTab";;
      *.translation) TYPENAME="Translations";;
      *.territory2Type) TYPENAME="Territory2Type";;
      *.trigger) TYPENAME="ApexTrigger";;
      *.workflow) TYPENAME="Workflow";;
      *) TYPENAME="UNKNOWN";;
    esac

    if [[ "$TYPENAME" == "CustomSite" && "$(basename -- "$(dirname -- "$CFILE")")" == "siteDotComSites" ]]
    then
      TYPENAME="SiteDotCom"
    fi

    if [[ "$TYPENAME" == "UNKNOWN" && "$(basename -- "$(dirname -- "$CFILE")")" == "email" ]]
    then
      TYPENAME="EmailTemplateFolder"
    fi

    if [ "$TYPENAME" != "UNKNOWN" ]
    then
      ENTITY=$(basename "$CFILE")
      ENTITY="${ENTITY%.*}"

      if [ "$TYPENAME" == "EmailTemplate" ]
      then
        ENTITY=$(basename -- "$(dirname -- "$CFILE")")"/"$ENTITY
      fi
      #Email template parsing
      if [ "$TYPENAME" == "EmailTemplateFolder" ]
      then
        TYPENAME="EmailTemplate"
        ENTITY=$(basename $ENTITY "-meta")
      fi

      #Wohack - Matching rules hack
      if [ "$TYPENAME" == "MatchingRule" ]
      then
        TYPENAME="MatchingRules"
        ENTITY="*"
      fi
      #Wohack end

      if grep -Fq ">$TYPENAME<" $SCRIPTFILE
      then
        #Wohack - Dont add additional asterisk if one already there
        if [ "$TYPENAME" == "MatchingRules" ]
        then
          #Do nothing
          echo Matching rule inbound...
        else
          echo Generating new member for $ENTITY
          C:/Jenkins/workspace/xmlstarlet/xmlstarlet/xml.exe ed -L -s "Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" $SCRIPTFILE
        fi
        #Wohack end
      else
        echo Generating new $TYPENAME type
        C:/Jenkins/workspace/xmlstarlet/xmlstarlet/xml.exe ed -L -s "Package" -t elem -n types -v "" $SCRIPTFILE
        C:/Jenkins/workspace/xmlstarlet/xmlstarlet/xml.exe ed -L -s "Package/types[not(*)]" -t elem -n name -v "$TYPENAME" $SCRIPTFILE
        echo Generating new member for $ENTITY
        C:/Jenkins/workspace/xmlstarlet/xmlstarlet/xml.exe ed -L -s "Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" $SCRIPTFILE
      fi
    else
      echo ERROR: UNSUPPORTED FILE TYPE $CFILE
    fi
  done < $1
  echo Cleaning up package.xml
  if [[ "$2" != *"destructive"* ]]
  then
    C:/Jenkins/workspace/xmlstarlet/xmlstarlet/xml.exe ed -L -s "Package" -t elem -n version -v "40.0" $SCRIPTFILE
  fi
  C:/Jenkins/workspace/xmlstarlet/xmlstarlet/xml.exe ed -L -i "Package" -t attr -n xmlns -v "http://soap.sforce.com/2006/04/metadata" $SCRIPTFILE
  echo ====FINAL PACKAGE.XML=====
  cat $SCRIPTFILE
else
  echo Change file not found!
fi