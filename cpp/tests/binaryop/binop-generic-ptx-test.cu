/*
 * Copyright (c) 2019, NVIDIA CORPORATION.
 *
 * Copyright 2018-2019 BlazingDB, Inc.
 *     Copyright 2018 Christian Noboa Mardini <christian@blazingdb.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <tests/binaryop/assert-binops.h>
#include <cudf/binaryop.hpp>
#include <tests/binaryop/binop-fixture.hpp>

namespace cudf {
namespace test {
namespace binop {
struct BinaryOperationGenericPTXTest : public BinaryOperationTest {
};

TEST_F(BinaryOperationGenericPTXTest, CAdd_Vector_Vector_FP32_FP32_FP32)
{
  // c = a*a*a + b
  const char* ptx =
    R"***(
//
// Generated by NVIDIA NVVM Compiler
//
// Compiler Build ID: CL-26218862
// Cuda compilation tools, release 10.1, V10.1.168
// Based on LLVM 3.4svn
//

.version 6.4
.target sm_70
.address_size 64

	// .globl	_ZN8__main__7add$241Eff
.common .global .align 8 .u64 _ZN08NumbaEnv8__main__7add$241Eff;
.common .global .align 8 .u64 _ZN08NumbaEnv5numba7targets7numbers13int_power$242Efx;

.visible .func  (.param .b32 func_retval0) _ZN8__main__7add$241Eff(
	.param .b64 _ZN8__main__7add$241Eff_param_0,
	.param .b32 _ZN8__main__7add$241Eff_param_1,
	.param .b32 _ZN8__main__7add$241Eff_param_2
)
{
	.reg .f32 	%f<5>;
	.reg .b32 	%r<2>;
	.reg .b64 	%rd<2>;


	ld.param.u64 	%rd1, [_ZN8__main__7add$241Eff_param_0];
	ld.param.f32 	%f1, [_ZN8__main__7add$241Eff_param_1];
	ld.param.f32 	%f2, [_ZN8__main__7add$241Eff_param_2];
	mul.f32 	%f3, %f1, %f1;
	fma.rn.f32 	%f4, %f3, %f1, %f2;
	st.f32 	[%rd1], %f4;
	mov.u32 	%r1, 0;
	st.param.b32	[func_retval0+0], %r1;
	ret;
}
)***";

  using TypeOut = float;
  using TypeLhs = float;
  using TypeRhs = float;

  auto CADD = [](TypeLhs a, TypeRhs b) { return a * a * a + b; };

  auto lhs = make_random_wrapped_column<TypeLhs>(500);
  auto rhs = make_random_wrapped_column<TypeRhs>(500);

  auto out = cudf::binary_operation(lhs, rhs, ptx, data_type(type_to_id<TypeOut>()));

  // pow has a max ULP error of 2 per CUDA programming guide
  ASSERT_BINOP<TypeOut, TypeLhs, TypeRhs>(*out, lhs, rhs, CADD, NearEqualComparator<TypeOut>{2});
}

TEST_F(BinaryOperationGenericPTXTest, CAdd_Vector_Vector_INT64_INT32_INT32)
{
  // c = a*a*a + b
  const char* ptx =
    R"***(
//
// Generated by NVIDIA NVVM Compiler
//
// Compiler Build ID: CL-26218862
// Cuda compilation tools, release 10.1, V10.1.168
// Based on LLVM 3.4svn
//

.version 6.4
.target sm_70
.address_size 64

	// .globl	_ZN8__main__7add$241Eii
.common .global .align 8 .u64 _ZN08NumbaEnv8__main__7add$241Eii;
.common .global .align 8 .u64 _ZN08NumbaEnv5numba7targets7numbers14int_power_impl12$3clocals$3e13int_power$242Exx;

.visible .func  (.param .b32 func_retval0) _ZN8__main__7add$241Eii(
	.param .b64 _ZN8__main__7add$241Eii_param_0,
	.param .b32 _ZN8__main__7add$241Eii_param_1,
	.param .b32 _ZN8__main__7add$241Eii_param_2
)
{
	.reg .b32 	%r<3>;
	.reg .b64 	%rd<7>;


	ld.param.u64 	%rd1, [_ZN8__main__7add$241Eii_param_0];
	ld.param.u32 	%r1, [_ZN8__main__7add$241Eii_param_1];
	cvt.s64.s32	%rd2, %r1;
	mul.wide.s32 	%rd3, %r1, %r1;
	mul.lo.s64 	%rd4, %rd3, %rd2;
	ld.param.s32 	%rd5, [_ZN8__main__7add$241Eii_param_2];
	add.s64 	%rd6, %rd4, %rd5;
	st.u64 	[%rd1], %rd6;
	mov.u32 	%r2, 0;
	st.param.b32	[func_retval0+0], %r2;
	ret;
}
)***";

  using TypeOut = int64_t;
  using TypeLhs = int32_t;
  using TypeRhs = int32_t;

  auto CADD = [](TypeLhs a, TypeRhs b) { return a * a * a + b; };

  auto lhs = make_random_wrapped_column<TypeLhs>(500);
  auto rhs = make_random_wrapped_column<TypeRhs>(500);

  auto out = cudf::binary_operation(lhs, rhs, ptx, data_type(type_to_id<TypeOut>()));

  ASSERT_BINOP<TypeOut, TypeLhs, TypeRhs>(*out, lhs, rhs, CADD);
}

TEST_F(BinaryOperationGenericPTXTest, CAdd_Vector_Vector_INT64_INT32_INT64)
{
  // c = a*a*a + b*b
  const char* ptx =
    R"***(
//
// Generated by NVIDIA NVVM Compiler
//
// Compiler Build ID: CL-24817639
// Cuda compilation tools, release 10.0, V10.0.130
// Based on LLVM 3.4svn
//

.version 6.3
.target sm_70
.address_size 64

	// .globl	_ZN8__main__7add$241Eix
.common .global .align 8 .u64 _ZN08NumbaEnv8__main__7add$241Eix;
.common .global .align 8 .u64 _ZN08NumbaEnv5numba7targets7numbers14int_power_impl12$3clocals$3e13int_power$242Exx;

.visible .func  (.param .b32 func_retval0) _ZN8__main__7add$241Eix(
	.param .b64 _ZN8__main__7add$241Eix_param_0,
	.param .b32 _ZN8__main__7add$241Eix_param_1,
	.param .b64 _ZN8__main__7add$241Eix_param_2
)
{
	.reg .b32 	%r<3>;
	.reg .b64 	%rd<8>;


	ld.param.u64 	%rd1, [_ZN8__main__7add$241Eix_param_0];
	ld.param.u32 	%r1, [_ZN8__main__7add$241Eix_param_1];
	ld.param.u64 	%rd2, [_ZN8__main__7add$241Eix_param_2];
	cvt.s64.s32	%rd3, %r1;
	mul.wide.s32 	%rd4, %r1, %r1;
	mul.lo.s64 	%rd5, %rd4, %rd3;
	mul.lo.s64 	%rd6, %rd2, %rd2;
	add.s64 	%rd7, %rd6, %rd5;
	st.u64 	[%rd1], %rd7;
	mov.u32 	%r2, 0;
	st.param.b32	[func_retval0+0], %r2;
	ret;
}

)***";

  using TypeOut = int64_t;
  using TypeLhs = int32_t;
  using TypeRhs = int64_t;

  auto CADD = [](TypeLhs a, TypeRhs b) { return a * a * a + b * b; };

  auto lhs = make_random_wrapped_column<TypeLhs>(500);
  auto rhs = make_random_wrapped_column<TypeRhs>(500);

  auto out = cudf::binary_operation(lhs, rhs, ptx, data_type(type_to_id<TypeOut>()));

  ASSERT_BINOP<TypeOut, TypeLhs, TypeRhs>(*out, lhs, rhs, CADD);
}

}  // namespace binop
}  // namespace test
}  // namespace cudf
