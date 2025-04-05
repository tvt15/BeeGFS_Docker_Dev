#ifndef CHUNKSIZESELECTOR_H_
#define CHUNKSIZESELECTOR_H_

#include <common/Common.h>
#include <common/toolkit/MathTk.h>
#include <common/toolkit/StringTk.h>
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
       * Estimates file size based on file extension.
       */
      static uint64_t estimateFromExtension(const std::string& fileName)
      {
         // Default to medium size if no extension found
         uint64_t defaultSize = 100 * 1024 * 1024; // 100MB

         // Extract file extension
         size_t dotPos = fileName.find_last_of('.');
         if (dotPos == std::string::npos)
            return defaultSize;

         std::string extension = fileName.substr(dotPos + 1);
         StringTk::strToLower(extension); // Convert to lowercase for comparison
         
         // Estimate based on common file extensions
         if (extension == "txt" || extension == "log" || extension == "conf" || 
             extension == "json" || extension == "xml" || extension == "ini" ||
             extension == "yaml" || extension == "yml" || extension == "md")
            return 64 * 1024; // 64KB - small text files

         else if (extension == "mp3" || extension == "pdf" || extension == "docx" ||
                 extension == "xlsx" || extension == "pptx" || extension == "odt" ||
                 extension == "jpg" || extension == "jpeg" || extension == "png")
            return 10 * 1024 * 1024; // 10MB - medium files

         else if (extension == "mp4" || extension == "mkv" || extension == "iso" ||
                 extension == "vmdk" || extension == "vdi" || extension == "qcow2" ||
                 extension == "avi" || extension == "mov")
            return 2 * 1024 * 1024 * 1024ULL; // 2GB - large files

         else if (extension == "tar" || extension == "gz" || extension == "zip" ||
                 extension == "7z" || extension == "rar" || extension == "bz2" ||
                 extension == "xz" || extension == "tgz")
            return 500 * 1024 * 1024; // 500MB - medium-large files

         // If no specific match, return default size
         return defaultSize;
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
         StringTk::strToLower(lowerPath);

         // Check for common directory name patterns that suggest file sizes
         if (lowerPath.find("video") != std::string::npos ||
             lowerPath.find("movies") != std::string::npos ||
             lowerPath.find("media") != std::string::npos)
            return 2 * 1024 * 1024 * 1024ULL; // 2GB - video files

         else if (lowerPath.find("backup") != std::string::npos ||
                 lowerPath.find("archive") != std::string::npos ||
                 lowerPath.find("dump") != std::string::npos)
            return 1 * 1024 * 1024 * 1024ULL; // 1GB - backup files

         else if (lowerPath.find("images") != std::string::npos ||
                 lowerPath.find("photos") != std::string::npos ||
                 lowerPath.find("pictures") != std::string::npos)
            return 5 * 1024 * 1024; // 5MB - image files

         else if (lowerPath.find("log") != std::string::npos ||
                 lowerPath.find("config") != std::string::npos ||
                 lowerPath.find("conf") != std::string::npos)
            return 1 * 1024 * 1024; // 1MB - log/config files

         // No specific directory hint found
         return 0;
      }
};

#endif // CHUNKSIZESELECTOR_H_ 