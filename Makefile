artifact_name       := notification-letter-producer
version := "unversioned"

dependency_check_runner := 416670754337.dkr.ecr.eu-west-2.amazonaws.com/dependency-check-runner

.PHONY: all
all: build

.PHONY: clean
clean:
	mvn clean
	rm -f ./$(artifact_name).jar
	rm -rf ./build-*
	rm -f ./build.log

.PHONY: build
build:
	mvn compile

.PHONY: test
test: test-unit

.PHONY: test-unit
test-unit: clean
	mvn test

.PHONY: package
package:
ifndef version
	$(error No version given. Aborting)
endif
	$(info Packaging version: $(version))
	mvn versions:set -DnewVersion=$(version) -DgenerateBackupPoms=false
	mvn package -DskipTests=true

.PHONY: dist
dist: clean build package

.PHONY: sonar
sonar:
	mvn sonar:sonar

.PHONY: sonar-pr-analysis
sonar-pr-analysis:
	mvn sonar:sonar	-P sonar-pr-analysis

.PHONY: dependency-check
dependency-check:
	docker run --rm -e DEPENDENCY_CHECK_SUPPRESSIONS_HOME=/opt -v "$$(pwd)":/app -w /app ${dependency_check_runner} --repo-name="$(basename "$$(pwd)")"

.PHONY: security-check
security-check: dependency-check