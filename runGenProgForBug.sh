#!/bin/bash

# The purpose of this script is to run Genprog of a particular defects4j bug.

# Preconditions:
#     - The variable D4J_HOME should be directed to the folder where defects4j is installed.
#     - The variable GP4J_HOME should be directed to the folder where genprog4java is installed.

# Output
#     The output is a folder created in the $D4J_HOME/5thParameter/ where all the variants are stored including the patch, if any was found. 

# Parameters:
#     The only *required* parameter specifies the project (ex: Lang, Chart, Closure, Math, Time) and bug number (ex: 1,2,3,4,...) in the format PROJECT:NUMBER

#     There are multiple optional arguments (defaults for these can be seen and set in `gpConfig.sh`).

#     --option
#         the option of running the test suite (ex: allHuman, oneHuman, oneGenerated)

#     --testsuitesample
#         test suite sample percentage (ex: 1, 100)

#     --bugsfolder
#         the folder where the bug files will be cloned to. Starting from $D4J_HOME (Ex: ExamplesCheckedOut)

#     --approach
#         the repair approach to use (e.g., gp, trp, par, all)

#     --startseed
#         the initial seed. It will then increase the seeds by adding 1 until it gets to the number in the next param.

#     --untilseed
#         the final seed.

#     --justtestingfaultloc
#         on if the purpose is to test only fault loc and not really trying to find a patch. When it has reached the end of fault localization it will stop.

#     --dirofjava7
#         the folder where the java 7 instalation is located

#     --dirofjava8
#         the folder where the java 8 instalation is located

#     --samplenegtests
#         set to \"true\" if negative tests are to be specified using sampled tests else set this to \"false\"

#     --negtestpath
#         the path to file containing sampled negative tests

#     --samplepostests
#         set to \"true\" if positive tests are to be specified using sampled tests else set this to \"false\""

#     --postestpath
#         the path to file containing sampled positive tests

# Example of usage:
#     ./runGenProgForBug.sh Math:2 --option=allHuman --bugsfolder=ExamplesCheckedOut --startseed=10 --untilseed=15

source gpConfig.sh

OPTION=$DEFAULT_OPTION
TESTSUITESAMPLE=$DEFAULT_TESTSUITESAMPLE
BUGSFOLDER=$DEFAULT_BUGSFOLDER
APPROACH=$DEFAULT_APPROACH
STARTSEED=$DEFAULT_STARTSEED
UNTILSEED=$DEFAULT_UNTILSEED
JUSTTESTINGFAULTLOC=$DEFAULT_JUSTTESTINGFAULTLOC
DIROFJAVA7=$DEFAULT_DIROFJAVA7
DIROFJAVA8=$DEFAULT_DIROFJAVA8
SAMPLENEGTESTS=$DEFAULT_SAMPLENEGTESTS
NEGTESTPATH=$DEFAULT_NEGTESTPATH
SAMPLEPOSTESTS=$DEFAULT_SAMPLEPOSTESTS
POSTESTPATH=$DEFAULT_POSTESTPATH

for i in "$@"
do
case $i in

  --help)
    cat help.txt
    exit 0
    ;;
  --option=*)
    OPTION="${i#*=}"
    shift # past argument=value
    ;;
  --testsuitesample=*)
    TESTSUITESAMPLE="${i#*=}"
    shift # past argument=value
    ;;
  --bugsfolder=*)
    BUGSFOLDER="${i#*=}"
    shift # past argument=value
    ;;
  --approach=*)
    APPROACH="${i#*=}"
    shift # past argument=value
    ;;
  --startseed=*)
    STARTSEED="${i#*=}"
    shift # past argument=value
    ;;
  --untilseed=*)
    UNTILSEED="${i#*=}"
    shift # past argument=value
    ;;
  --justtestingfaultloc=*)
    JUSTTESTINGFAULTLOC="${i#*=}"
    shift # past argument=value
    ;;
  --dirofjava7=*)
    DIROFJAVA7="${i#*=}"
    shift # past argument=value
    ;;
  --dirofjava8=*)
    DIROFJAVA8="${i#*=}"
    shift # past argument=value
    ;;
  --samplenegtests=*)
    SAMPLENEGTESTS="${i#*=}"
    shift # past argument=value
    ;;
  --negtestpath=*)
    NEGTESTPATH="${i#*=}"
    shift # past argument=value
    ;;
  --samplepostests=*)
    SAMPLEPOSTESTS="${i#*=}"
    shift # past argument=value
    ;;
  --postestpath=*)
    POSTESTPATH="${i#*=}"
    shift # past argument=value
    ;;
  *)    # unlabelled option, assumed to be project:bugnumber
    PROJECT="${i%:*}"
    BUGNUMBER="${i#*:}"
    shift
    ;;
esac
done

if [ -z "$PROJECT" ] || [ -z "BUGNUMBER" ]; then
  echo "Need to have PROJECT:BUGNUMBER as an argument"
  exit 1
fi
if [ -z "$D4J_HOME" ]; then
    echo "Need to set D4J_HOME"
    exit 1
fi  
if [ -z "$GP4J_HOME" ]; then
    echo "Need to set GP4J_HOME"
    exit 1
fi  
currentDir=$(pwd)


#This transforms the first parameter to lower case. Ex: lang, chart, closure, math or time
LOWERCASEPACKAGE=`echo $PROJECT | tr '[:upper:]' '[:lower:]'`

#Add the path of defects4j so the defects4j's commands run 
export PATH=$PATH:$D4J_HOME/framework/bin

# directory with the checked out buggy project
BUGWD=$D4J_HOME/$BUGSFOLDER"/"$LOWERCASEPACKAGE"$BUGNUMBER"Buggy
export JAVA_HOME=$DIROFJAVA8
export JRE_HOME=$DIROFJAVA8/jre
export PATH=$DIROFJAVA8/bin/:$PATH
#sudo update-java-alternatives -s $DIROFJAVA8

#Compile Genprog and put the class files in /bin
#Go to the GenProg folder
if [ -d "$GP4J_HOME" ]; then
  cd "$GP4J_HOME"
  mvn package
  if [[ $? -ne 0 ]]; then
      echo "error building GenProg; exiting"
      exit 1
  fi

  export JAVA_HOME=$DIROFJAVA7
  export JRE_HOME=$DIROFJAVA7/jre
  export PATH=$DIROFJAVA7/bin/:$PATH
  #sudo update-java-alternatives -s $DIROFJAVA7

  cd $currentDir

  ./prepareBug.sh $PROJECT $BUGNUMBER $OPTION $TESTSUITESAMPLE $BUGSFOLDER $APPROACH $DIROFJAVA7 $DIROFJAVA8 $SAMPLENEGTESTS $NEGTESTPATH $SAMPLEPOSTESTS $POSTESTPATH

  if [ -d "$BUGWD/$WD" ]; then
    #Go to the working directory
    cd $BUGWD/$WD

    for (( seed=$STARTSEED; seed<=$UNTILSEED; seed++ ))
      do  
      echo "RUNNING THE BUG: $PROJECT $BUGNUMBER, WITH THE SEED: $seed"

      #Running until fault loc only
      if [ $JUSTTESTINGFAULTLOC == "true" ]; then
        echo "justTestingFaultLoc = true" >> $D4J_HOME/$BUGSFOLDER/"$LOWERCASEPACKAGE""$BUGNUMBER"Buggy/defects4j.config
      fi

      #Changing the seed
      CHANGESEEDCOMMAND="sed -i '1s/.*/seed = $seed/' "$D4J_HOME/$BUGSFOLDER/"$LOWERCASEPACKAGE""$BUGNUMBER"Buggy/defects4j.config
      eval $CHANGESEEDCOMMAND

      if [ $seed != $STARTSEED ]; then
        REMOVESANITYCOMMAND="sed -i 's/sanity = yes/sanity = no/' "$D4J_HOME/$BUGSFOLDER/"$LOWERCASEPACKAGE""$BUGNUMBER"Buggy/defects4j.config
        eval $REMOVESANITYCOMMAND

        REMOVEREGENPATHS="sed -i '/regenPaths/d' "$D4J_HOME/$BUGSFOLDER/"$LOWERCASEPACKAGE""$BUGNUMBER"Buggy/defects4j.config
        eval $REMOVEREGENPATHS
      fi
        
      export JAVA_HOME=$DIROFJAVA8
      export JRE_HOME=$DIROFJAVA8/jre
        export PATH=$DIROFJAVA8/bin/:$PATH
      #sudo update-java-alternatives -s $DIROFJAVA8

      JAVALOCATION=$(which java)
      timeout -sHUP 4h $JAVALOCATION -ea -Dlog4j.configurationFile=file:"$GP4J_HOME"/src/log4j.properties -Dfile.encoding=UTF-8 -classpath "$GP4J_HOME"/target/uber-GenProg4Java-0.0.1-SNAPSHOT.jar clegoues.genprog4java.main.Main $D4J_HOME/$BUGSFOLDER/"$LOWERCASEPACKAGE""$BUGNUMBER"Buggy/defects4j.config | tee $D4J_HOME/$BUGSFOLDER/"$LOWERCASEPACKAGE""$BUGNUMBER"Buggy/log"$PROJECT""$BUGNUMBER"Seed$seed.txt


      #Save the variants in a tar file
      tar -cvf $D4J_HOME/$BUGSFOLDER/"$LOWERCASEPACKAGE""$BUGNUMBER"Buggy/variants"$PROJECT""$BUGNUMBER"Seed$seed.tar $D4J_HOME/$BUGSFOLDER/"$LOWERCASEPACKAGE""$BUGNUMBER"Buggy/tmp/
      mv $D4J_HOME/$BUGSFOLDER/"$LOWERCASEPACKAGE""$BUGNUMBER"Buggy/tmp/original/ $D4J_HOME/$BUGSFOLDER/"$LOWERCASEPACKAGE""$BUGNUMBER"Buggy/
      rm -r $D4J_HOME/$BUGSFOLDER/"$LOWERCASEPACKAGE""$BUGNUMBER"Buggy/tmp/
      mkdir $D4J_HOME/$BUGSFOLDER/"$LOWERCASEPACKAGE""$BUGNUMBER"Buggy/tmp/
      mv $D4J_HOME/$BUGSFOLDER/"$LOWERCASEPACKAGE""$BUGNUMBER"Buggy/original/ $D4J_HOME/$BUGSFOLDER/"$LOWERCASEPACKAGE""$BUGNUMBER"Buggy/tmp/
      
      done
    fi
  fi
