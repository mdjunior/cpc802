package main

import (
	"testing"
)

var result int

func TestReturn(t *testing.T) {

	model := &LinearSVC{
		coefficients: []float64{0.0, 0.0, 1.0},
		intercepts:   4.0,
	}

	class := model.Predict([]float64{0.0, 0.0, 0.0})
	if class != 0 && class != 1 {
		t.Error("Result of predict must be 0 or 1")
	}
}

// Para executar o benchmark, use: go test -bench="."
func BenchmarkPredictFull(b *testing.B) {

	model := &LinearSVC{
		coefficients: Coefficients,
		intercepts:   Intercepts,
	}

	var internalResult int
	for i := 0; i < b.N; i++ {
		// always record the result of Fib to prevent
		// the compiler eliminating the function call.
		internalResult = model.Predict(Coefficients)
	}

	// always store the result to a package level variable
	// so the compiler cannot eliminate the Benchmark itself.
	result = internalResult
}

func benchmarkPredictVariable(modelSize int, b *testing.B) {

	localCoefficients := Coefficients[:modelSize]

	model := &LinearSVC{
		coefficients: localCoefficients,
		intercepts:   Intercepts,
	}

	var internalResult int
	for i := 0; i < b.N; i++ {
		// always record the result of Fib to prevent
		// the compiler eliminating the function call.
		internalResult = model.Predict(localCoefficients)
	}

	// always store the result to a package level variable
	// so the compiler cannot eliminate the Benchmark itself.
	result = internalResult
}

func BenchmarkPredictModelSize10(b *testing.B) {
	benchmarkPredictVariable(10, b)
}

func BenchmarkPredictModelSize100(b *testing.B) {
	benchmarkPredictVariable(100, b)
}

func BenchmarkPredictModelSize1000(b *testing.B) {
	benchmarkPredictVariable(1000, b)
}

func BenchmarkPredictModelSize10000(b *testing.B) {
	benchmarkPredictVariable(10000, b)
}
