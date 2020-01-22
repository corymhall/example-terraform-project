package test

import (
	"fmt"

	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

const ALB_EXAMPLES_DIR = "tests/examples/alb"

func runCreateALB(t *testing.T, awsRegion string) {
	examplesDir := test_structure.CopyTerraformFolderToTemp(t, REPO_ROOT, ALB_EXAMPLES_DIR)

	defer test_structure.RunTestStage(t, "teardown", func() {
		teardownResources(t, examplesDir)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		uniqueId := random.UniqueId()
		terraformVars := map[string]interface{}{
			"name": fmt.Sprintf("terratest-%s", uniqueId),
		}
		deployTerraform(t, awsRegion, examplesDir, uniqueId, terraformVars)
	})

	test_structure.RunTestStage(t, "validate", func() {
		// terraformOptions := test_structure.LoadTerraformOptions(t, examplesDir)
		// run some tests here
	})

}

func runCreateNLB(t *testing.T, awsRegion string) {
	examplesDir := test_structure.CopyTerraformFolderToTemp(t, REPO_ROOT, ALB_EXAMPLES_DIR)

	defer test_structure.RunTestStage(t, "teardown", func() {
		teardownResources(t, examplesDir)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		uniqueId := random.UniqueId()
		terraformVars := map[string]interface{}{
			"name":               fmt.Sprintf("terratest-%s", uniqueId),
			"load_balancer_type": "network",
			"internal":           true,
			"application_port":   3001,
		}
		deployTerraform(t, awsRegion, examplesDir, uniqueId, terraformVars)
	})

	test_structure.RunTestStage(t, "validate", func() {
		// add tests here
	})
}

func runCreateALBWithLambdaTarget(t *testing.T, awsRegion string) {
	examplesDir := test_structure.CopyTerraformFolderToTemp(t, REPO_ROOT, ALB_EXAMPLES_DIR)

	defer test_structure.RunTestStage(t, "teardown", func() {
		teardownResources(t, examplesDir)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		uniqueId := random.UniqueId()
		terraformVars := map[string]interface{}{
			"name":        fmt.Sprintf("terratest-%s", uniqueId),
			"target_type": "lambda",
		}
		deployTerraform(t, awsRegion, examplesDir, uniqueId, terraformVars)
	})

	test_structure.RunTestStage(t, "validate", func() {
		// add tests here
	})
}
