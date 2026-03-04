# Package
version       = "0.1.0"
author        = "Nimphea Contributors"
description   = "Nimphea Example: system_demo"
license       = "MIT"
srcDir        = "src"
bin           = @["system_demo"]

requires "nim >= 2.0.0"
requires "nimphea >= 1.1.0"

import os, strutils
const linkerScript = "STM32H750IB_flash.lds"

include "../../nimble_tasks.nims"
