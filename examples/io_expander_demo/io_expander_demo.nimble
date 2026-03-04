# Package
version       = "0.1.0"
author        = "Nimphea Contributors"
description   = "Nimphea Example: io_expander_demo"
license       = "MIT"
srcDir        = "src"
bin           = @["io_expander_demo"]

requires "nim >= 2.0.0"
requires "nimphea >= 1.1.0"

import os, strutils
const linkerScript = "STM32H750IB_flash.lds"

include "../../nimble_tasks.nims"
