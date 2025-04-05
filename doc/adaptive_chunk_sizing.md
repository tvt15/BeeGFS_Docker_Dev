# BeeGFS Adaptive Chunk Sizing

## Overview

The adaptive chunk sizing feature in BeeGFS automatically selects appropriate chunk sizes for files based on their size or expected size. This optimization improves I/O performance across various workloads by using smaller chunks for small files (improving distribution) and larger chunks for large files (reducing metadata overhead).

## Configuration Parameters

The following parameters can be set in the BeeGFS configuration file:

### Basic Settings

- `tuneAdaptiveChunkSizing`: (boolean) Enable/disable adaptive chunk sizing
  - Default: false
  - Example: `tuneAdaptiveChunkSizing = true`

### Chunk Size Settings

- `tuneAdaptiveChunkSizeSmall`: Size for small files
  - Default: 64k
  - Example: `tuneAdaptiveChunkSizeSmall = 64k`

- `tuneAdaptiveChunkSizeMedium`: Size for medium files
  - Default: 512k
  - Example: `tuneAdaptiveChunkSizeMedium = 512k`

- `tuneAdaptiveChunkSizeLarge`: Size for large files
  - Default: 2m
  - Example: `tuneAdaptiveChunkSizeLarge = 2m`

- `tuneAdaptiveChunkSizeVeryLarge`: Size for very large files
  - Default: 8m
  - Example: `tuneAdaptiveChunkSizeVeryLarge = 8m`

### Threshold Settings

- `tuneAdaptiveChunkSizeThresholdSmall`: Maximum size for small files
  - Default: 1m
  - Example: `tuneAdaptiveChunkSizeThresholdSmall = 1m`

- `tuneAdaptiveChunkSizeThresholdMedium`: Maximum size for medium files
  - Default: 100m
  - Example: `tuneAdaptiveChunkSizeThresholdMedium = 100m`

- `tuneAdaptiveChunkSizeThresholdLarge`: Maximum size for large files
  - Default: 1g
  - Example: `tuneAdaptiveChunkSizeThresholdLarge = 1g`

## Size Units

The following size units are supported:
- k or K: Kilobytes (1024 bytes)
- m or M: Megabytes (1024 kilobytes)
- g or G: Gigabytes (1024 megabytes)

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

## File Size Estimation

The system uses several methods to estimate the expected size of new files:

1. File Extension Analysis
   - Small files (.txt, .log, .conf, .json, etc.)
   - Medium files (.mp3, .pdf, .docx, etc.)
   - Large files (.mp4, .mkv, .iso, etc.)
   - Archive files (.tar, .gz, .zip, etc.)

2. Directory Path Hints
   - Video directories (video/, movies/, media/)
   - Backup directories (backup/, archive/, dump/)
   - Image directories (images/, photos/, pictures/)
   - Configuration directories (log/, config/, conf/)

## Monitoring and Adjustment

The system includes a monitoring component that:
1. Tracks file growth patterns
2. Identifies files that might benefit from restriping
3. Logs recommendations for manual intervention
4. (Future feature) Automatically restripes files during off-peak hours

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

## Limitations

1. Chunk sizes must be powers of 2
2. Minimum chunk size is 64KB
3. Changes to chunk size require restriping
4. Automatic restriping is not yet implemented

## Troubleshooting

Common issues and solutions:

1. **Performance not improving**
   - Verify adaptive chunk sizing is enabled
   - Check if thresholds match your workload
   - Monitor file size distribution

2. **Unexpected chunk sizes**
   - Check file size estimation accuracy
   - Verify configuration parameters
   - Review log files for warnings

3. **High metadata overhead**
   - Adjust thresholds upward
   - Increase minimum chunk size
   - Consider workload patterns

## Future Enhancements

Planned improvements include:
1. Automatic restriping of files
2. Machine learning-based size prediction
3. Workload pattern analysis
4. Dynamic threshold adjustment 