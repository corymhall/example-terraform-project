package test

import (
	"crypto/tls"
	"fmt"
	"net/url"
	"time"

	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

const ECS_ALB_EXAMPLES_DIR = "tests/examples/ecs_lb_service"

// This is an end-to-end test that spins up all the infrastructure need to run a load balanced ECS service
// and validates that the request to the LB returns the expected reponse and status code
func runCreateALBService(t *testing.T, awsRegion string) {
	// Copies the terraform files to a temp folder so the tests can run in parallel without the state files
	// overwriting each other.
	examplesDir := test_structure.CopyTerraformFolderToTemp(t, REPO_ROOT, ECS_ALB_EXAMPLES_DIR)

	// defer terraform destroy until all tests are complete
	defer test_structure.RunTestStage(t, "teardown", func() {
		teardownResources(t, examplesDir)
	})

	// run the deploy stage
	test_structure.RunTestStage(t, "deploy", func() {
		// generate a unique string so that we ensure there will never be a naming conflict
		uniqueId := random.UniqueId()

		// setup any terraform variables that we will pass to the module
		terraformVars := map[string]interface{}{
			"name": fmt.Sprintf("terratest-%s", uniqueId),
		}
		deployTerraform(t, awsRegion, examplesDir, uniqueId, terraformVars)
	})

	// run our validation tests against the infrastructure that was created
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, examplesDir)
		// get the ALB url from the terraform outputs
		albUrl := terraform.Output(t, terraformOptions, "alb_url")
		// parse the url so that we can change the scheme to https
		parsedUrl, err := url.Parse(albUrl)
		if err != nil {
			t.Logf(err.Error())
			t.Fail()
		}
		parsedUrl.Scheme = "https"

		// get the cluster and service name from the outputs
		clusterName := terraform.Output(t, terraformOptions, "cluster_name")
		serviceName := terraform.Output(t, terraformOptions, "service_name")
		maxRetries := 30
		timeBetweenRetries := 5 * time.Second

		// get the ECS service details and validate that it was create in private subnets
		service := aws.GetEcsService(t, awsRegion, clusterName, serviceName)
		subnets := service.NetworkConfiguration.AwsvpcConfiguration.Subnets

		isPublic := false
		for _, s := range subnets {
			public := aws.IsPublicSubnet(t, *s, awsRegion)
			if public {
				isPublic = true
			}
		}
		assert.False(t, isPublic)

		// make an http request to the load balancer and validate that we get the correct reponse and status code
		http_helper.HttpGetWithRetry(t, parsedUrl.String(), &tls.Config{InsecureSkipVerify: true}, 200, "hello", maxRetries, timeBetweenRetries)
	})

}
