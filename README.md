# How to run defects4j bugs in genprog4java

To run a single defects4j bug in genprog4java use the `runGenProgForBug.sh` script

The purpose of this script is to instantiate a defects4j bug and run it in genprog4java to try to find a patch.

## Preconditions:

* The variable `D4J_HOME` should be directed to the folder where defects4j is installed.
* The variable `GP4J_HOME` should be directed to the folder where genprog4java is installed.

## Output

The output is a folder created in the $D4J_HOME/5thParameter/1stParam2ndParam/ with log and tar files where all the variants are stored including the patch, if any was found. 

## Parameters:
The only *required* parameter specifies the project (ex: Lang, Chart, Closure, Math, Time) and bug number (ex: 1,2,3,4,...) in the format `PROJECT:NUMBER`.

There are multiple optional arguments (defaults for these can be seen and set in `gpConfig.sh`).

--help
    shows the help

--option
    the option of running the test suite (ex: allHuman, oneHuman, oneGenerated)

--testsuitesample
    test suite sample percentage (ex: 1, 100)

--bugsfolder
    the folder where the bug files will be cloned to. Starting from $D4J_HOME (Ex: ExamplesCheckedOut)

--approach
    the repair approach to use (e.g., gp, trp, par, all)

--startseed
    the initial seed. It will then increase the seeds by adding 1 until it gets to the number in the next param.

--untilseed
    the final seed.

--justtestingfaultloc
    on if the purpose is to test only fault loc and not really trying to find a patch. When it has reached the end of fault localization it will stop.

--dirofjava7
    the folder where the java 7 instalation is located

--dirofjava8
    the folder where the java 8 instalation is located

--samplenegtests
    set to \"true\" if negative tests are to be specified using sampled tests else set this to \"false\"

--negtestpath
    the path to file containing sampled negative tests

--samplepostests
    set to \"true\" if positive tests are to be specified using sampled tests else set this to \"false\""

--postestpath
    the path to file containing sampled positive tests

## Example of usage:

`./runGenProgForBug.sh Math:2 --option=allHuman --bugsfolder=ExamplesCheckedOut --startseed=10 --untilseed=15`
