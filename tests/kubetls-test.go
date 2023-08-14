package test

import (
	"encoding/csv"
	"os"

	// . "github.com/kubearmor/KubeArmor/tests/util"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = BeforeSuite(func() {
	// err := K8sApply([]string{"res/test-k8tls.yaml"})
	// Expect(err).To(BeNil())
	// install wordpress-mysql app
	// err := K8sApply([]string{"res/test-k8tls.yaml"})
	// Expect(err).To(BeNil())
	// time.Sleep(5 * time.Second)

})

var _ = AfterSuite(func() {

	// err := K8sDelete([]string{"res/test-k8tls.yaml"})
	// Expect(err).To(BeNil())

})

func matchCSV(file1 string, file2 string) {
	// Read the first CSV file
	file1Data, err := os.Open(file1)
	Expect(err).NotTo(HaveOccurred())
	defer file1Data.Close()

	reader1 := csv.NewReader(file1Data)
	file1Records, err := reader1.ReadAll()
	Expect(err).NotTo(HaveOccurred())

	// Read the second CSV file
	file2Data, err := os.Open(file2)
	Expect(err).NotTo(HaveOccurred())
	defer file2Data.Close()

	reader2 := csv.NewReader(file2Data)
	file2Records, err := reader2.ReadAll()
	Expect(err).NotTo(HaveOccurred())

	// Determine the index of the "Address" column
	addressColumnIndex := -1
	for i, header := range file1Records[0] {
		if header == "Address" {
			addressColumnIndex = i
			break
		}
	}

	// Compare headers
	Expect(len(file1Records[0])).To(Equal(len(file2Records[0])))

	for i := 0; i < len(file1Records[0]); i++ {
		if i == addressColumnIndex {
			continue // Skip comparing the "Address" column
		}
		Expect(file1Records[0][i]).To(Equal(file2Records[0][i]))
	}

	// Compare rows
	Expect(len(file1Records)).To(Equal(len(file2Records)))

	for i := 0; i < len(file1Records); i++ {
		for j := 0; j < len(file1Records[i]); j++ {
			if j == addressColumnIndex {
				continue // Skip comparing the "Address" column
			}
			Expect(file1Records[i][j]).To(Equal(file2Records[i][j]))
		}
	}
}

var _ = Describe("CSV Matching", func() {

	It("should match the summary output files", func() {

		file1 := "/tmp/summary.csv"
		file2 := "summary-test.csv"
		matchCSV(file1, file2)
	})

	It("should match the table output files", func() {
		file1 := "/tmp/out.csv"
		file2 := "table-test.csv"
		matchCSV(file1, file2)
	})
})
