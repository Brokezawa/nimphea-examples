## Build All Examples Script
## 
## This nimscript builds all examples in the examples/ directory.
## Usage: nim build_all.nims [options]
##   Options:
##     -d:verbose     Show verbose output
##
## Examples:
##   nim build_all.nims              # Build all examples
##   nim build_all.nims -d:verbose   # Build with verbose output

import os, strutils, algorithm

const
  ExamplesDir = "examples"

type
  BuildResult = object
    name: string
    success: bool
    output: string

proc getExamples(): seq[string] =
  ## Get list of all example directories
  result = @[]
  if dirExists(ExamplesDir):
    for kind, path in walkDir(ExamplesDir):
      if kind == pcDir:
        let exampleName = path.splitPath().tail
        let nimbleFile = path / exampleName & ".nimble"
        if fileExists(nimbleFile):
          result.add(exampleName)
  result.sort(system.cmp[string])

proc buildExample(exampleName: string, verbose: bool): BuildResult =
  ## Build a single example
  result.name = exampleName
  let examplePath = ExamplesDir / exampleName
  
  echo "Building: ", exampleName, " ..."
  
  try:
    # Use absolute path to avoid directory issues
    let absPath = getCurrentDir() / examplePath
    let cmd = "cd " & absPath & " && nimble make"
    
    let (output, exitCode) = gorgeEx(cmd)
    
    result.success = exitCode == 0
    result.output = output
    
    if result.success:
      echo "  ✓ Success"
    else:
      echo "  ✗ Failed"
      if verbose and output.len > 0:
        let lines = output.splitLines()
        if lines.len > 0:
          echo "  Error: ", lines[^1]
        
  except Exception as e:
    result.success = false
    result.output = e.msg
    echo "  ✗ Error: ", e.msg

proc printSummary(results: seq[BuildResult]) =
  ## Print build summary
  var successful = 0
  var failed = 0
  
  for res in results:
    if res.success:
      successful += 1
    else:
      failed += 1
  
  echo ""
  echo "========================================"
  echo "           BUILD SUMMARY"
  echo "========================================"
  echo "Total:    ", results.len
  if results.len > 0:
    echo "Success:  ", successful, " (", 
         (successful * 100) div results.len, "%)"
    echo "Failed:   ", failed, " (", 
         (failed * 100) div results.len, "%)"
  
  if failed > 0:
    echo ""
    echo "Failed examples:"
    for res in results:
      if not res.success:
        echo "  - ", res.name
  
  echo "========================================"

# Main execution
let verbose = defined(verbose)

echo ""
echo "Nimphea Examples Build Script"
echo "=============================="

let examples = getExamples()

if examples.len == 0:
  echo "No examples found in ", ExamplesDir, "/"
  quit(1)

echo "Found ", examples.len, " examples"
echo ""
echo "=== Building ", examples.len, " examples ==="
echo ""

var results: seq[BuildResult] = @[]

for example in examples:
  results.add(buildExample(example, verbose))

echo ""
echo "=== Build complete ==="

printSummary(results)

# Exit with error code if any builds failed
for res in results:
  if not res.success:
    quit(1)
