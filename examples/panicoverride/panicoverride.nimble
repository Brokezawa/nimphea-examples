# Package
version       = "0.1.0"
author        = "Nimphea Contributors"
description   = "Nimphea Example: panicoverride"
license       = "MIT"
srcDir        = "src"
bin           = @["panicoverride"]

requires "nim >= 2.0.0"
requires "nimphea >= 1.1.0"

import os, strutils
const linkerScript = "STM32H750IB_flash.lds"

include "../../nimble_tasks.nims"
