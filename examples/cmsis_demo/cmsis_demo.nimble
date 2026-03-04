# Package
version       = "0.1.0"
author        = "Nimphea Contributors"
description   = "Nimphea Example: cmsis_demo"
license       = "MIT"
srcDir        = "src"
bin           = @["cmsis_demo"]

requires "nim >= 2.0.0"
requires "nimphea >= 1.1.0"

import os, strutils
const linkerScript = "STM32H750IB_flash.lds"
const customDefines = "-d:useCMSIS -d:bootQspi"

include "../../nimble_tasks.nims"
