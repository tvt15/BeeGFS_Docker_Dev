#ifndef CHUNKSIZEMONITOR_H_
#define CHUNKSIZEMONITOR_H_

#include <common/Common.h>
#include <common/threading/Mutex.h>
#include <common/threading/Thread.h>
#include <common/toolkit/Time.h>
#include <app/config/Config.h>
#include <storage/ChunkSizeSelector.h>
#include <storage/FileInode.h>
#include <storage/MetaStore.h>

#define CHUNKSIZEMONITOR_SLEEP_MS 60000 // 1 minute between checks
#define CHUNKSIZEMONITOR_MIN_GROWTH_FACTOR 4 // Minimum growth factor to trigger restripe consideration

class ChunkSizeMonitor : public Thread
{
   public:
      ChunkSizeMonitor()
         : Thread("ChunkSizeMon"),
           running(true)
      {
      }

      virtual ~ChunkSizeMonitor()
      {
         running = false;
         join();
      }

      void run() override
      {
         while (running)
         {
            monitorFileSizes();
            
            if (running)
               Thread::sleep(CHUNKSIZEMONITOR_SLEEP_MS);
         }
      }

   private:
      bool running;
      Mutex mutex;

      void monitorFileSizes()
      {
         App* app = Program::getApp();
         Config* cfg = app->getConfig();
         MetaStore* metaStore = app->getMetaStore();

         if (!cfg->getTuneAdaptiveChunkSizing())
            return; // Adaptive chunk sizing not enabled

         // Get list of files to check
         // Note: In a real implementation, we would need a way to efficiently track and iterate
         // over files that have grown significantly. This is just a basic example.
         
         // For each file that has grown significantly...
         // Note: This is a placeholder for the actual implementation
         /*
         for (auto& fileID : filesToCheck)
         {
            FileInode* inode = metaStore->referenceFile(fileID);
            if (!inode)
               continue;

            StatData statData;
            if (inode->getStatData(statData) == FhgfsOpsErr_SUCCESS)
            {
               uint64_t currentSize = statData.getFileSize();
               uint64_t currentChunkSize = inode->getStripePattern()->getChunkSize();
               
               // Calculate optimal chunk size for current file size
               uint64_t optimalChunkSize = ChunkSizeSelector::determineOptimalChunkSize(
                  currentSize, cfg);

               // If the file has grown significantly and would benefit from larger chunks
               if (optimalChunkSize > currentChunkSize && 
                   currentSize > currentChunkSize * CHUNKSIZEMONITOR_MIN_GROWTH_FACTOR)
               {
                  // Log potential restripe candidate
                  log.log(Log_DEBUG, 
                     "File " + fileID + " has grown significantly. "
                     "Current chunk size: " + StringTk::uintToStr(currentChunkSize) + ", "
                     "Optimal chunk size: " + StringTk::uintToStr(optimalChunkSize));

                  // In a full implementation, we would:
                  // 1. Add the file to a restripe candidate list
                  // 2. Consider system load and time of day
                  // 3. Potentially trigger restriping during off-peak hours
                  // 4. Handle restripe operation atomically
                  // 5. Update stripe pattern after successful restripe
               }
            }

            metaStore->releaseFile(fileID, inode);
         }
         */
      }
};

#endif // CHUNKSIZEMONITOR_H_ 