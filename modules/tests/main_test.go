/**
 * The structure for this test case was taken from the hashicorp vault terraform module. This module has great detailed examples of performing
 * complex tests with terratest https://github.com/hashicorp/terraform-aws-vault/tree/master/test
 */
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

type testCase struct {
	Name string                   // Name of the test
	Func func(*testing.T, string) // Function that runs test. Receives(t, awsRegion)
}

// list of tests to run
var testCases = []testCase{
	{
		"TestTaskDefinitionCreate",
		runCreateTaskDef,
	},
	{
		"TestTaskDefinitionWithOverrides",
		runCreateTaskDefWithOverrides,
	},
	{
		"TestALB",
		runCreateALB,
	},
	{
		"TestALBWithLambdaTarget",
		runCreateALBWithLambdaTarget,
	},
	{
		"TestNLB",
		runCreateNLB,
	},
	{
		"TestCreateLBService",
		runCreateALBService,
	},
}

// The base test that will kick off each of the individual tests in parallel
func TestTerraformEcsService(t *testing.T) {
	// you can also use aws.GetRandomRegion() from the github.com/gruntwork-io/terratest/modules/aws
	// package to run this in a random region. This is useful if you know you will be provisioning your infrastructure in
	// multiple regions and need to ensure that it will work in any
	awsRegion := "us-east-2"

	for _, testCase := range testCases {
		testCase := testCase
		t.Run(testCase.Name, func(t *testing.T) {
			t.Parallel()
			testCase.Func(t, awsRegion)
		})
	}
}

// This is used to run Terraform init and apply given the inputs
func deployTerraform(t *testing.T, awsRegion string, examplesDir string, uniqueId string, terraformVars map[string]interface{}) {
	terraformOptions := &terraform.Options{
		TerraformDir: examplesDir,
		Vars:         terraformVars,
		EnvVars: map[string]string{
			ENV_VAR_AWS_REGION: awsRegion,
		},
		// There might be transient errors with the http requests to fetch files
		RetryableTerraformErrors: map[string]string{
			"Error installing provider": "Failed to download terraform package",
		},
	}

	test_structure.SaveTerraformOptions(t, examplesDir, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
}

// This is used to run Terraform destroy after all of the tests complete
func teardownResources(t *testing.T, examplesDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, examplesDir)
	terraform.Destroy(t, terraformOptions)
}
