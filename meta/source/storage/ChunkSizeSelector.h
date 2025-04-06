#ifndef CHUNKSIZESELECTOR_H_
#define CHUNKSIZESELECTOR_H_

#include <common/Common.h>
#include <common/toolkit/MathTk.h>
#include <common/toolkit/StringTk.h>
#include <common/toolkit/UnitTk.h>
#include <app/config/Config.h>
#include <program/Program.h>
#include <storage/MetaStore.h>

class ChunkSizeSelector
{
   public:
      /**
       * Determines the optimal chunk size based on file size and configuration settings.
       * 
       * @param fileSize The size of the file in bytes
       * @param config Pointer to the configuration object
       * @return The optimal chunk size in bytes
       */
      static uint64_t determineOptimalChunkSize(uint64_t fileSize, Config* config)
      {
         if (!config->getTuneAdaptiveChunkSizing())
            return config->getTuneDefaultChunkSize();

         // Get thresholds from config
         uint64_t smallThreshold = config->getTuneAdaptiveChunkSizeThresholdSmall();
         uint64_t mediumThreshold = config->getTuneAdaptiveChunkSizeThresholdMedium();
         uint64_t largeThreshold = config->getTuneAdaptiveChunkSizeThresholdLarge();

         // Get chunk sizes from config
         uint64_t smallChunkSize = config->getTuneAdaptiveChunkSizeSmall();
         uint64_t mediumChunkSize = config->getTuneAdaptiveChunkSizeMedium();
         uint64_t largeChunkSize = config->getTuneAdaptiveChunkSizeLarge();
         uint64_t veryLargeChunkSize = config->getTuneAdaptiveChunkSizeVeryLarge();

         // Determine chunk size based on file size
         if (fileSize < smallThreshold)
            return smallChunkSize;
         else if (fileSize < mediumThreshold)
            return mediumChunkSize;
         else if (fileSize < largeThreshold)
            return largeChunkSize;
         else
            return veryLargeChunkSize;
      }

      /**
       * Estimates the expected file size based on file extension, path hints, and directory patterns.
       * 
       * @param fileName The name of the file
       * @param parentDirID The ID of the parent directory
       * @return Estimated file size in bytes
       */
      static uint64_t estimateFileSize(const std::string& fileName, const std::string& parentDirID)
      {
         // Default to medium size if no hints available
         uint64_t defaultSize = 100 * 1024 * 1024; // 100MB
         uint64_t sizeEstimate = defaultSize;

         // First check file extension
         sizeEstimate = estimateFromExtension(fileName);

         // Then check directory path hints
         uint64_t dirHintSize = estimateFromDirectoryHints(parentDirID);
         if (dirHintSize > 0)
         {
            // If we have both estimates, use the larger one as it's better to overestimate
            // than underestimate for performance reasons
            sizeEstimate = std::max(sizeEstimate, dirHintSize);
         }

         return sizeEstimate;
      }

   private:
      ChunkSizeSelector() {} // Static class - prevent instantiation

      /**
       * Extract file extension from filename.
       */
      static std::string extractFileExtension(const std::string& fileName)
      {
         size_t dotPos = fileName.find_last_of('.');
         if (dotPos == std::string::npos || dotPos == 0 || dotPos == fileName.length() - 1)
            return "";
         
         return fileName.substr(dotPos + 1);
      }

      /**
       * Estimates file size based on file extension.
       */
      static uint64_t estimateFromExtension(const std::string& fileName)
      {
         std::string extension = extractFileExtension(fileName);
         if(extension.empty())
            return 0;

         std::transform(extension.begin(), extension.end(), extension.begin(), ::tolower);

         // Default sizes for common file types
         if(extension == "txt" || extension == "log")
            return 1ULL * 1024 * 1024; // 1MB
         if(extension == "mp3" || extension == "wav")
            return 10ULL * 1024 * 1024; // 10MB
         if(extension == "mp4" || extension == "mkv")
            return 1ULL * 1024 * 1024 * 1024; // 1GB
         
         return 0; // Unknown extension
      }

      /**
       * Estimates file size based on directory path hints.
       */
      static uint64_t estimateFromDirectoryHints(const std::string& parentDirID)
      {
         App* app = Program::getApp();
         MetaStore* metaStore = app->getMetaStore();

         // Get the parent directory
         DirInode* parentDir = metaStore->referenceDir(parentDirID, false, true);
         if (!parentDir)
            return 0;

         // Get the full path of the directory
         std::string dirPath = parentDir->getID();
         
         // Release the directory reference
         metaStore->releaseDir(parentDirID);

         // Convert path to lowercase for case-insensitive matching
         std::string lowerPath = dirPath;
         std::transform(lowerPath.begin(), lowerPath.end(), lowerPath.begin(), ::tolower);

         // Check directory hints
         if(lowerPath.find("video") != std::string::npos)
            return 1ULL * 1024 * 1024 * 1024; // 1GB
         if(lowerPath.find("audio") != std::string::npos)
            return 10ULL * 1024 * 1024; // 10MB
         if(lowerPath.find("logs") != std::string::npos)
            return 1ULL * 1024 * 1024; // 1MB
         
         return 0; // No hints found
      }
};

#endif // CHUNKSIZESELECTOR_H_ 