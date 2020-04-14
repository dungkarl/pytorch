#include <c10/test/util/complex_test_common.h>

__global__ void test_thrust_kernel() {
  // thrust conversion
  {
  constexpr float num1 = float(1.23);
  constexpr float num2 = float(4.56);
  assert(c10::complex<float>(thrust::complex<float>(num1, num2)).real() == num1);
  assert(c10::complex<float>(thrust::complex<float>(num1, num2)).imag() == num2);
  }
  {
  constexpr double num1 = double(1.23);
  constexpr double num2 = double(4.56);
  assert(c10::complex<double>(thrust::complex<double>(num1, num2)).real() == num1);
  assert(c10::complex<double>(thrust::complex<double>(num1, num2)).imag() == num2);
  }
  // thrust assignment
  auto tup = assignment::one_two_thrust();
  assert(std::get<c10::complex<double>>(tup).real() == double(1));
  assert(std::get<c10::complex<double>>(tup).imag() == double(2));
  assert(std::get<c10::complex<float>>(tup).real() == float(1));
  assert(std::get<c10::complex<float>>(tup).imag() == float(2));
}

__global__ void test_std_functions_kernel() {
  assert(std::abs(c10::complex<float>(3, 4)) == float(5));
  assert(std::abs(c10::complex<double>(3, 4)) == double(5));

  assert(std::abs(std::arg(c10::complex<float>(0, 1)) - PI / 2) < 1e-6);
  assert(std::abs(std::arg(c10::complex<double>(0, 1)) - PI / 2) < 1e-6);

  assert(std::abs(c10::polar(float(1), float(PI / 2)) - c10::complex<float>(0, 1)) < 1e-6);
  assert(std::abs(c10::polar(double(1), double(PI / 2)) - c10::complex<double>(0, 1)) < 1e-6);
}

__global__ void test_reinterpret_cast() {
  std::complex<float> z(1, 2);
  c10::complex<float> zz = *reinterpret_cast<c10::complex<float>*>(&z);
  assert(zz.real() == float(1));
  assert(zz.imag() == float(2));

  std::complex<double> zzz(1, 2);
  c10::complex<double> zzzz = *reinterpret_cast<c10::complex<double>*>(&zzz);
  assert(zzzz.real() == double(1));
  assert(zzzz.imag() == double(2));
}

TEST(DeviceTests, ThrustConversion) {
  cudaDeviceSynchronize();
  test_thrust_kernel<<<1, 1>>>();
  cudaDeviceSynchronize();
  ASSERT_EQ(cudaGetLastError(), cudaSuccess);
}

TEST(DeviceTests, StdFunctions) {
  cudaDeviceSynchronize();
  test_std_functions_kernel<<<1, 1>>>();
  cudaDeviceSynchronize();
  ASSERT_EQ(cudaGetLastError(), cudaSuccess);
}

TEST(DeviceTests, ReinterpretCast) {
  cudaDeviceSynchronize();
  test_reinterpret_cast<<<1, 1>>>();
  cudaDeviceSynchronize();
  ASSERT_EQ(cudaGetLastError(), cudaSuccess);
}

