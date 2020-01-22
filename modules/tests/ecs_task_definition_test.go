package test

import (
	"fmt"

	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

const REPO_ROOT = "../"
const EXAMPLES_DIR = "tests/examples/ecs_task_definition"
const ENV_VAR_AWS_REGION = "AWS_DEFAULT_REGION"
const WORK_DIR = "./"

func runCreateTaskDef(t *testing.T, awsRegion string) {
	examplesDir := test_structure.CopyTerraformFolderToTemp(t, REPO_ROOT, EXAMPLES_DIR)

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

func runCreateTaskDefWithOverrides(t *testing.T, awsRegion string) {
	examplesDir := test_structure.CopyTerraformFolderToTemp(t, REPO_ROOT, EXAMPLES_DIR)

	defer test_structure.RunTestStage(t, "teardown", func() {
		teardownResources(t, examplesDir)
	})

	// here we are overwriting some variables to make sure that they are picked up
	test_structure.RunTestStage(t, "deploy", func() {
		uniqueId := random.UniqueId()
		terraformVars := map[string]interface{}{
			"name":   fmt.Sprintf("terratest-%s", uniqueId),
			"cpu":    512,
			"memory": 1024,
			"port_mappings": []map[string]interface{}{
				map[string]interface{}{
					"containerPort": 3001,
					"hostPort":      3001,
					"protocol":      "tcp",
				},
			},
		}
		deployTerraform(t, awsRegion, examplesDir, uniqueId, terraformVars)
	})

	// validate that the variables that we passed in are being set on the created infrastructure
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, examplesDir)
		taskArn := terraform.Output(t, terraformOptions, "arn")
		taskDef := aws.GetEcsTaskDefinition(t, awsRegion, taskArn)
		assert.Equal(t, "512", *taskDef.Cpu)
		assert.Equal(t, "1024", *taskDef.Memory)
		containerPort := *taskDef.ContainerDefinitions[0].PortMappings[0].ContainerPort
		assert.Equal(t, int64(3001), containerPort)
	})
}
