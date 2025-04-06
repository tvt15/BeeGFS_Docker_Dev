#include <common/toolkit/MessagingTk.h>
#include <common/toolkit/UnitTk.h>
#include <components/ModificationEventFlusher.h>
#include <program/Program.h>
#include <storage/ChunkSizeSelector.h>
#include "MsgHelperMkFile.h"

/*
 * @param stripePattern can be NULL, in which case a new pattern gets created; should only be set
 * if this is the secondary buddy of a mirror group
 */
FhgfsOpsErr MsgHelperMkFile::mkFile(DirInode& parentDir, MkFileDetails* mkDetails,
   const UInt16List* preferredTargets, const unsigned numtargets, const unsigned chunksize,
   StripePattern* stripePattern, EntryInfo* outEntryInfo, FileInodeStoreData* outInodeData,
   StoragePoolId storagePoolId)
{
   const char* logContext = "MsgHelperMkFile (create file)";

   App* app = Program::getApp();
   MetaStore* metaStore = app->getMetaStore();
   ModificationEventFlusher* modEventFlusher = app->getModificationEventFlusher();
   bool modEventLoggingEnabled = modEventFlusher->isLoggingEnabled();
   Config* cfg = app->getConfig();

   // If adaptive chunk sizing is enabled and no specific chunk size was requested,
   // determine the optimal chunk size based on file type/name
   unsigned effectiveChunkSize = chunksize;
   if (cfg->getTuneAdaptiveChunkSizing() && chunksize == 0)
   {
      // Get estimated file size based on name and directory
      uint64_t estimatedSize = ChunkSizeSelector::estimateFileSize(
         mkDetails->newName, parentDir.getID());
      
      // Determine optimal chunk size based on estimated file size
      effectiveChunkSize = static_cast<unsigned>(ChunkSizeSelector::determineOptimalChunkSize(
         estimatedSize, cfg));

      // Ensure chunk size is at least the minimum allowed
      effectiveChunkSize = std::max(effectiveChunkSize, 
         static_cast<unsigned>(STRIPEPATTERN_MIN_CHUNKSIZE));

      // Ensure chunk size is a power of two using bit manipulation
      effectiveChunkSize--;
      effectiveChunkSize |= effectiveChunkSize >> 1;
      effectiveChunkSize |= effectiveChunkSize >> 2;
      effectiveChunkSize |= effectiveChunkSize >> 4;
      effectiveChunkSize |= effectiveChunkSize >> 8;
      effectiveChunkSize |= effectiveChunkSize >> 16;
      effectiveChunkSize++;
   }

   FhgfsOpsErr retVal;

   // create new stripe pattern
   if (!stripePattern)
      stripePattern = parentDir.createFileStripePattern(preferredTargets, numtargets, effectiveChunkSize,
         storagePoolId);

   // check availability of stripe targets
   if(unlikely(!stripePattern || stripePattern->getStripeTargetIDs()->empty()))
   {
      LogContext(logContext).logErr(
         "Unable to create stripe pattern. No storage targets available? "
         "File: " + mkDetails->newName);

      SAFE_DELETE(stripePattern);
      return FhgfsOpsErr_INTERNAL;
   }

   // create meta file
   retVal = metaStore->mkNewMetaFile(parentDir, mkDetails,
         std::unique_ptr<StripePattern>(stripePattern), outEntryInfo, outInodeData);

   if (modEventLoggingEnabled && outEntryInfo)
   {
      std::string entryID = outEntryInfo->getEntryID();
      modEventFlusher->add(ModificationEvent_FILECREATED, entryID);
   }

   return retVal;
}


