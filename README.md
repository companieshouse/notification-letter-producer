Notification Letter Producer (CHIPS)
===

The Letter Producer is used to produce the XML files that are read by the Doc 1 producer application.
Each XML file represents a single letter.
The Letter Producer extracts a list of letters to produce, and based on the letter type, runs the required SQL statement
from the database and outputs the data to a letter producer directory.
The letter producer is a two step process – the first step will produce the XML files in the letter producer directory,
at which point they can be processed by the DOC1 producer. A stat.txt file will be created in the letter producer output
directory when the first stage has finished.
The second stage will be background processing, such as updating transaction status (When required), informing workflow
a letter has been sent (When required) and deleting the letter from the database.

Guide
---
For a more detailed description see the full
[design here](https://companieshouse.atlassian.net/wiki/spaces/IDV/pages/5142675571/Directions+Nudge?force_transition=e9353503-ba32-45fc-9149-962408594428)

Requirements
---

- [Java 8](https://www.oracle.com/uk/java/technologies/downloads/#java8)
- [Maven](https://maven.apache.org/download.cgi)
- [Git](https://git-scm.com/downloads)
- [Make](https://www.gnu.org/software/make/)

Getting started
---

#### Building with Make (Linux/Unix)

1. Clean - This will clean any built artifacts from the repository

   ```
   make clean
   ```

2. Build - This will pull down any dependencies and compile code.

   ```
   make build
   ```

3. Package - This will produce a runnable jar and a versioned zip file containing both the jar and start scripts.

   ```
   make dist version="$(< version)
   ```

4. Running

   ```
   java -jar notification-letter-producer.jar <PROPERTIES_FILE>
   ```

#### Building with Maven (Windows/Mac)

1. In config folder, copy notification-letter-producer.properties.template to notification-letter-producer.properties
   and populate values

   ```
   cp notification-letter-producer.properties.template notification-letter-producer.properties
   ```  

2. Clean - This will clean any built artifacts from the repository

   ```
   mvn clean
   ```

3. Build - This will produce a jar in the repository root.

   ```
   mvn -P mvn-build package
   ```

4. Running

   ```
   cd target
   notification-letter-producer.bat <PROPERTIES_FILE>
   ```

# OWASP Dependency check

to run a check for dependency security vulnerabilities run the following command:

```shell
mvn dependency-check:check
```

# List Dependencies

```shell
mvn dependency:tree
```

Properties file
---
A template properties file can be found in the config folder. Four properties need to be provided:

* provider.host - e.g. localhost
* provider.port - e.g. 7001
* principal - e.g. jimmy
* password - e.g. dong

Scripts
---
For convenience scripts have been provided to run the jar once built.

* Unix

```
notification-letter-producer.sh <PROPERTIES_FILE>
```

* Windows

```
notification-letter-producer.bat <PROPERTIES_FILE>
```
