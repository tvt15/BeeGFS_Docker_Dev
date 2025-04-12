# BeeGFS Adaptive Chunk Sizing

## Overview

The adaptive chunk sizing feature in BeeGFS automatically selects appropriate chunk sizes for files based on their size or expected size. This optimization improves I/O performance across various workloads by using smaller chunks for small files (improving distribution) and larger chunks for large files (reducing metadata overhead).

## Implementation Details

The adaptive chunk sizing feature is implemented across several components of the BeeGFS codebase:

- **Configuration**: `meta/source/app/config/Config.cpp` and `meta/source/app/config/Config.h` define the tuning parameters for the feature.
- **Core Logic**: `meta/source/storage/ChunkSizeSelector.h` contains the implementation of the chunk size selection algorithm.
- **File Creation Integration**: `meta/source/net/msghelpers/MsgHelperMkFile.cpp` integrates the feature into the file creation path.
- **Monitoring**: `meta/source/storage/ChunkSizeMonitor.h` provides a skeleton for future monitoring capabilities (currently contains placeholder code).
- **Tests**: `meta/tests/TestChunkSizing.cpp` contains unit tests that verify the functionality, though some test config setup code is commented out.

## Configuration Parameters

The following parameters can be set in the BeeGFS configuration file (typically `/etc/beegfs/beegfs-meta.conf`):

### Basic Settings

- `tuneAdaptiveChunkSizing`: (boolean) Enable/disable adaptive chunk sizing
  - Default: false
  - Example: `tuneAdaptiveChunkSizing = true`

### Chunk Size Settings

- `tuneAdaptiveChunkSizeSmall`: Size for small files
  - Default: 64k
  - Example: `tuneAdaptiveChunkSizeSmall = 64k`
  - Defined in: `meta/source/app/config/Config.cpp` (line ~90)

- `tuneAdaptiveChunkSizeMedium`: Size for medium files
  - Default: 512k
  - Example: `tuneAdaptiveChunkSizeMedium = 512k`
  - Defined in: `meta/source/app/config/Config.cpp` (line ~91)

- `tuneAdaptiveChunkSizeLarge`: Size for large files
  - Default: 2m
  - Example: `tuneAdaptiveChunkSizeLarge = 2m`
  - Defined in: `meta/source/app/config/Config.cpp` (line ~92)

- `tuneAdaptiveChunkSizeVeryLarge`: Size for very large files
  - Default: 8m
  - Example: `tuneAdaptiveChunkSizeVeryLarge = 8m`
  - Defined in: `meta/source/app/config/Config.cpp` (line ~93)

### Threshold Settings

- `tuneAdaptiveChunkSizeThresholdSmall`: Maximum size for small files
  - Default: 1m
  - Example: `tuneAdaptiveChunkSizeThresholdSmall = 1m`
  - Defined in: `meta/source/app/config/Config.cpp` (line ~94)

- `tuneAdaptiveChunkSizeThresholdMedium`: Maximum size for medium files
  - Default: 100m
  - Example: `tuneAdaptiveChunkSizeThresholdMedium = 100m`
  - Defined in: `meta/source/app/config/Config.cpp` (line ~95)

- `tuneAdaptiveChunkSizeThresholdLarge`: Maximum size for large files
  - Default: 1g
  - Example: `tuneAdaptiveChunkSizeThresholdLarge = 1g`
  - Defined in: `meta/source/app/config/Config.cpp` (line ~96)

## Size Units

The following size units are supported in the configuration file:
- k or K: Kilobytes (1024 bytes)
- m or M: Megabytes (1024 kilobytes)
- g or G: Gigabytes (1024 megabytes)

The parsing of these units is handled by the `UnitTk::strHumanToInt64()` function in `common/toolkit/UnitTk.cpp`.

## Example Configuration

```ini
# Enable adaptive chunk sizing
tuneAdaptiveChunkSizing = true

# Chunk sizes for different file categories
tuneAdaptiveChunkSizeSmall = 64k
tuneAdaptiveChunkSizeMedium = 512k
tuneAdaptiveChunkSizeLarge = 2m
tuneAdaptiveChunkSizeVeryLarge = 8m

# Thresholds for file size categories
tuneAdaptiveChunkSizeThresholdSmall = 1m
tuneAdaptiveChunkSizeThresholdMedium = 100m
tuneAdaptiveChunkSizeThresholdLarge = 1g
```

## Recommended Values for Different Workloads

### Small File Workload (e.g., Web Hosting)
```ini
tuneAdaptiveChunkSizeSmall = 32k
tuneAdaptiveChunkSizeMedium = 256k
tuneAdaptiveChunkSizeLarge = 1m
tuneAdaptiveChunkSizeVeryLarge = 4m
tuneAdaptiveChunkSizeThresholdSmall = 512k
tuneAdaptiveChunkSizeThresholdMedium = 50m
tuneAdaptiveChunkSizeThresholdLarge = 500m
```

### Large File Workload (e.g., Media Storage)
```ini
tuneAdaptiveChunkSizeSmall = 128k
tuneAdaptiveChunkSizeMedium = 1m
tuneAdaptiveChunkSizeLarge = 4m
tuneAdaptiveChunkSizeVeryLarge = 16m
tuneAdaptiveChunkSizeThresholdSmall = 2m
tuneAdaptiveChunkSizeThresholdMedium = 200m
tuneAdaptiveChunkSizeThresholdLarge = 2g
```

### Mixed Workload
```ini
tuneAdaptiveChunkSizeSmall = 64k
tuneAdaptiveChunkSizeMedium = 512k
tuneAdaptiveChunkSizeLarge = 2m
tuneAdaptiveChunkSizeVeryLarge = 8m
tuneAdaptiveChunkSizeThresholdSmall = 1m
tuneAdaptiveChunkSizeThresholdMedium = 100m
tuneAdaptiveChunkSizeThresholdLarge = 1g
```

## Implementation Mechanism

### Chunk Size Selection Algorithm
The `ChunkSizeSelector::determineOptimalChunkSize()` method in `meta/source/storage/ChunkSizeSelector.h` determines the optimal chunk size based on file size using the following logic:

1. If adaptive chunk sizing is disabled, use the default chunk size
2. Get thresholds and chunk sizes from configuration
3. Compare file size against thresholds:
   - Size < smallThreshold → use smallChunkSize
   - Size < mediumThreshold → use mediumChunkSize
   - Size < largeThreshold → use largeChunkSize
   - Size >= largeThreshold → use veryLargeChunkSize

### File Size Estimation

The system uses several methods to estimate the expected size of new files through the `ChunkSizeSelector::estimateFileSize()` method in `meta/source/storage/ChunkSizeSelector.h`:

1. **File Extension Analysis** (`estimateFromExtension()` method)
   - Small files (.txt, .log) - typically under 1MB
   - Medium files (.mp3, .wav) - typically 10MB
   - Large files (.mp4, .mkv) - typically 1GB
   - Limited file types are currently implemented, with more to be added

2. **Directory Path Hints** (`estimateFromDirectoryHints()` method)
   - Video directories (containing "video") - typically 1GB files
   - Audio directories (containing "audio") - typically 10MB files
   - Log directories (containing "logs") - typically 1MB files
   - Basic implementation that only checks for these specific strings in directory paths

### Integration with File Creation

The adaptive chunk sizing feature is integrated into the file creation path in `meta/source/net/msghelpers/MsgHelperMkFile.cpp`:

1. When a new file is created, if adaptive chunk sizing is enabled and no specific chunk size was requested:
   - Estimate the expected file size based on name and directory
   - Determine the optimal chunk size based on the estimated size
   - Ensure the chunk size is at least STRIPEPATTERN_MIN_CHUNKSIZE (64KB)
   - Ensure the chunk size is a power of 2 (using bit manipulation)
   - Create the file with the determined chunk size

## Monitoring and Adjustment

The monitoring component in `meta/source/storage/ChunkSizeMonitor.h` is currently in early development:

1. A skeleton thread implementation is provided
2. The monitoring functionality is mostly commented out placeholder code
3. The intended functionality includes:
   - Identifying files that have grown significantly
   - Calculating optimal chunk sizes for their current size
   - Logging recommendations for potential restriping
   - Future automatic restriping capability

The monitoring code sets a minimum growth factor (CHUNKSIZEMONITOR_MIN_GROWTH_FACTOR) of 4x, meaning a file should grow to at least 4 times its current chunk size before being considered for restriping.

## Performance Considerations

- Smaller chunk sizes (32k-128k) are better for:
  - Small files
  - Random access patterns
  - Many concurrent clients
  - Limited client memory

- Larger chunk sizes (1m-16m) are better for:
  - Large files
  - Sequential access patterns
  - High-bandwidth operations
  - Clients with ample memory

The performance benefits are achieved through:
- Reducing metadata overhead for large files (fewer chunks to track)
- Improving distribution for small files (more even spread across targets)
- Optimizing I/O patterns for different file types

## Technical Constraints and Limitations

1. Chunk sizes must be powers of 2 (enforced in `meta/source/net/msghelpers/MsgHelperMkFile.cpp` and checked in `meta/source/net/message/storage/creating/MkFileWithPatternMsgEx.cpp`)
2. Minimum chunk size is 64KB (defined as STRIPEPATTERN_MIN_CHUNKSIZE in `common/storage/striping/StripePattern.h`)
3. Changes to chunk size require restriping (currently a manual operation)
4. Automatic restriping is not implemented - only placeholder code exists in `meta/source/storage/ChunkSizeMonitor.h`
5. The file size estimation is limited to a few specific file extensions and directory keywords
6. Test implementation in `meta/tests/TestChunkSizing.cpp` has commented-out code for setting test values, indicating the feature may still be in development

## Troubleshooting

Common issues and solutions:

1. **Performance not improving**
   - Verify adaptive chunk sizing is enabled in the configuration
   - Check if thresholds match your workload (analyze file size distribution)
   - Monitor file size distribution with `beegfs-ctl --getentryinfo`
   - Check logs for any warnings related to chunk sizing

2. **Unexpected chunk sizes**
   - Check file size estimation accuracy (examine file extensions and paths)
   - Verify configuration parameters in `/etc/beegfs/beegfs-meta.conf`
   - Review log files for warnings (search for "ChunkSizeSelector" in logs)
   - Use `beegfs-ctl --getentryinfo <path>` to inspect chunk size of existing files

3. **High metadata overhead**
   - Adjust thresholds upward to use larger chunks more often
   - Increase minimum chunk size in your configuration
   - Consider your workload patterns and adjust settings accordingly
   - Monitor metadata server load before and after configuration changes

## Future Work and Current Status

The adaptive chunk sizing feature is functional but not yet fully implemented. The following components are:

**Implemented:**
- Configuration parameters in `Config.cpp`
- Chunk size selection algorithm in `ChunkSizeSelector.h`
- File creation integration in `MsgHelperMkFile.cpp`
- Basic file extension and directory path analysis
- Unit tests validating the functionality

**Not Fully Implemented:**
- Comprehensive file type detection (limited extensions supported)
- Directory path analysis (only basic keyword matching)
- File monitoring (skeleton code only)
- Automatic restriping capability

Planned improvements include:
1. Completing the ChunkSizeMonitor implementation (currently just placeholder code)
2. Adding more file types to the extension analysis
3. Implementing more sophisticated directory path analysis
4. Developing automatic restriping capabilities
5. Machine learning-based size prediction (replacing simple heuristics)
6. Workload pattern analysis (tracking access patterns over time)
7. Dynamic threshold adjustment (self-tuning based on observed behaviors) 