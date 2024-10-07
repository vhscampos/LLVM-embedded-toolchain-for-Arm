@REM Copyright (c) 2024, Arm Limited and affiliates.
@REM SPDX-License-Identifier: Apache-2.0
@REM
@REM Licensed under the Apache License, Version 2.0 (the "License");
@REM you may not use this file except in compliance with the License.
@REM You may obtain a copy of the License at
@REM
@REM     http://www.apache.org/licenses/LICENSE-2.0
@REM
@REM Unless required by applicable law or agreed to in writing, software
@REM distributed under the License is distributed on an "AS IS" BASIS,
@REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@REM See the License for the specific language governing permissions and
@REM limitations under the License.

@if [%1]==[] goto :target_empty
@set target=%1
@goto :make
:target_empty
@set target=build

:make
@if [%target%]==[build] goto :build
@if [%target%]==[run] goto :run
@if [%target%]==[clean] goto :clean
@echo Error: unknown target "%target%"
@exit /B 1

:build
@if [%BIN_PATH%]==[] goto :bin_path_empty
@call :build_fn
@exit /B

:run
@if exist hello.hex goto :do_run
@if [%BIN_PATH%]==[] goto :bin_path_empty
@call :build_fn
:do_run
qemu-system-arm.exe -M microbit -semihosting -nographic -device loader,file=hello.hex
qemu-system-arm.exe -M microbit -semihosting -nographic -device loader,file=hello-exn.hex
@exit /B

:clean
if exist hello.elf del /q hello.elf
if exist hello.hex del /q hello.hex
if exist hello-exn.elf del /q hello-exn.elf
if exist hello-exn.hex del /q hello-exn.hex
@exit /B

:bin_path_empty
@echo Error: BIN_PATH environment variable is not set
@exit /B 1

:build_fn
%BIN_PATH%\clang++.exe --target=armv6m-none-eabi -mfloat-abi=soft -march=armv6m -mfpu=none -lcrt0-semihost -lsemihost -fno-exceptions -fno-rtti -print-multi-directory -g -T ..\..\ldscripts\microbit.ld -o hello.elf hello.cpp
%BIN_PATH%\clang++.exe --target=armv6m-none-eabi -mfloat-abi=soft -march=armv6m -mfpu=none -lcrt0-semihost -lsemihost -fno-exceptions -fno-rtti -g -T ..\..\ldscripts\microbit.ld -o hello.elf hello.cpp
%BIN_PATH%\llvm-objcopy.exe -O ihex hello.elf hello.hex
%BIN_PATH%\clang++.exe --target=armv6m-none-eabi -mfloat-abi=soft -march=armv6m -mfpu=none -lcrt0-semihost -lsemihost -print-multi-directory -g -T ..\..\ldscripts\microbit.ld -o hello-exn.elf hello-exn.cpp
%BIN_PATH%\clang++.exe --target=armv6m-none-eabi -mfloat-abi=soft -march=armv6m -mfpu=none -lcrt0-semihost -lsemihost -g -T ..\..\ldscripts\microbit.ld -o hello-exn.elf hello-exn.cpp
%BIN_PATH%\llvm-objcopy.exe -O ihex hello-exn.elf hello-exn.hex
@exit /B

:build_exn_fn
@exit /B