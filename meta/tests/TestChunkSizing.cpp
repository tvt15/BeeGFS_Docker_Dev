#include <common/toolkit/StringTk.h>
#include <common/toolkit/UnitTk.h>
#include <program/Program.h>
#include <storage/ChunkSizeSelector.h>
#include <gtest/gtest.h>

class TestChunkSizing : public ::testing::Test
{
   protected:
      Config* cfg;

      virtual void SetUp() override
      {
         cfg = Program::getApp()->getConfig();

         // Store original values
         origAdaptiveEnabled = cfg->getTuneAdaptiveChunkSizing();
         origSmallSize = cfg->getTuneAdaptiveChunkSizeSmall();
         origMediumSize = cfg->getTuneAdaptiveChunkSizeMedium();
         origLargeSize = cfg->getTuneAdaptiveChunkSizeLarge();
         origVeryLargeSize = cfg->getTuneAdaptiveChunkSizeVeryLarge();
         origSmallThreshold = cfg->getTuneAdaptiveChunkSizeThresholdSmall();
         origMediumThreshold = cfg->getTuneAdaptiveChunkSizeThresholdMedium();
         origLargeThreshold = cfg->getTuneAdaptiveChunkSizeThresholdLarge();

         // Set test values
         setTestConfig();
      }

      virtual void TearDown() override
      {
         // Restore original values
         restoreConfig();
      }

   private:
      bool origAdaptiveEnabled;
      uint64_t origSmallSize;
      uint64_t origMediumSize;
      uint64_t origLargeSize;
      uint64_t origVeryLargeSize;
      uint64_t origSmallThreshold;
      uint64_t origMediumThreshold;
      uint64_t origLargeThreshold;

      void setTestConfig()
      {
         // Enable adaptive chunk sizing
         cfg->setQuotaEnableEnforcement(true);  // Using this as an example of how to set config values

         // Set test values (these would need proper setter methods in Config class)
         /*
         cfg->setTuneAdaptiveChunkSizing(true);
         cfg->setTuneAdaptiveChunkSizeSmall(64*1024);
         cfg->setTuneAdaptiveChunkSizeMedium(512*1024);
         cfg->setTuneAdaptiveChunkSizeLarge(2*1024*1024);
         cfg->setTuneAdaptiveChunkSizeVeryLarge(8*1024*1024);
         cfg->setTuneAdaptiveChunkSizeThresholdSmall(1024*1024);
         cfg->setTuneAdaptiveChunkSizeThresholdMedium(100*1024*1024);
         cfg->setTuneAdaptiveChunkSizeThresholdLarge(1024*1024*1024);
         */
      }

      void restoreConfig()
      {
         // Restore original values (these would need proper setter methods in Config class)
         /*
         cfg->setTuneAdaptiveChunkSizing(origAdaptiveEnabled);
         cfg->setTuneAdaptiveChunkSizeSmall(origSmallSize);
         cfg->setTuneAdaptiveChunkSizeMedium(origMediumSize);
         cfg->setTuneAdaptiveChunkSizeLarge(origLargeSize);
         cfg->setTuneAdaptiveChunkSizeVeryLarge(origVeryLargeSize);
         cfg->setTuneAdaptiveChunkSizeThresholdSmall(origSmallThreshold);
         cfg->setTuneAdaptiveChunkSizeThresholdMedium(origMediumThreshold);
         cfg->setTuneAdaptiveChunkSizeThresholdLarge(origLargeThreshold);
         */
      }
};

TEST_F(TestChunkSizing, optimalChunkSizeSmallFile)
{
   uint64_t fileSize = 500 * 1024; // 500KB
   uint64_t chunkSize = ChunkSizeSelector::determineOptimalChunkSize(fileSize, cfg);
   EXPECT_EQ(chunkSize, cfg->getTuneAdaptiveChunkSizeSmall());
}

TEST_F(TestChunkSizing, optimalChunkSizeMediumFile)
{
   uint64_t fileSize = 50 * 1024 * 1024; // 50MB
   uint64_t chunkSize = ChunkSizeSelector::determineOptimalChunkSize(fileSize, cfg);
   EXPECT_EQ(chunkSize, cfg->getTuneAdaptiveChunkSizeMedium());
}

TEST_F(TestChunkSizing, optimalChunkSizeLargeFile)
{
   uint64_t fileSize = 500 * 1024 * 1024; // 500MB
   uint64_t chunkSize = ChunkSizeSelector::determineOptimalChunkSize(fileSize, cfg);
   EXPECT_EQ(chunkSize, cfg->getTuneAdaptiveChunkSizeLarge());
}

TEST_F(TestChunkSizing, optimalChunkSizeVeryLargeFile)
{
   uint64_t fileSize = 2ULL * 1024 * 1024 * 1024; // 2GB
   uint64_t chunkSize = ChunkSizeSelector::determineOptimalChunkSize(fileSize, cfg);
   EXPECT_EQ(chunkSize, cfg->getTuneAdaptiveChunkSizeVeryLarge());
}

TEST_F(TestChunkSizing, fileExtensionEstimation)
{
   // Test small file extensions
   EXPECT_LT(ChunkSizeSelector::estimateFileSize("config.txt", ""), 1024 * 1024);
   EXPECT_LT(ChunkSizeSelector::estimateFileSize("server.log", ""), 1024 * 1024);
   EXPECT_LT(ChunkSizeSelector::estimateFileSize("settings.json", ""), 1024 * 1024);

   // Test medium file extensions
   EXPECT_GE(ChunkSizeSelector::estimateFileSize("song.mp3", ""), 1024 * 1024);
   EXPECT_GE(ChunkSizeSelector::estimateFileSize("document.pdf", ""), 1024 * 1024);
   EXPECT_LT(ChunkSizeSelector::estimateFileSize("document.pdf", ""), 100 * 1024 * 1024);

   // Test large file extensions
   EXPECT_GE(ChunkSizeSelector::estimateFileSize("movie.mp4", ""), 100 * 1024 * 1024);
   EXPECT_GE(ChunkSizeSelector::estimateFileSize("backup.iso", ""), 100 * 1024 * 1024);
}

TEST_F(TestChunkSizing, directoryHintEstimation)
{
   // Test video directory hints
   EXPECT_GE(ChunkSizeSelector::estimateFileSize("file.dat", "videos"), 100 * 1024 * 1024);
   EXPECT_GE(ChunkSizeSelector::estimateFileSize("file.dat", "movies"), 100 * 1024 * 1024);

   // Test backup directory hints
   EXPECT_GE(ChunkSizeSelector::estimateFileSize("file.dat", "backup"), 100 * 1024 * 1024);
   EXPECT_GE(ChunkSizeSelector::estimateFileSize("file.dat", "archive"), 100 * 1024 * 1024);

   // Test image directory hints
   EXPECT_GE(ChunkSizeSelector::estimateFileSize("file.dat", "photos"), 1024 * 1024);
   EXPECT_LT(ChunkSizeSelector::estimateFileSize("file.dat", "images"), 100 * 1024 * 1024);

   // Test config directory hints
   EXPECT_LT(ChunkSizeSelector::estimateFileSize("file.dat", "config"), 10 * 1024 * 1024);
   EXPECT_LT(ChunkSizeSelector::estimateFileSize("file.dat", "logs"), 10 * 1024 * 1024);
}

TEST_F(TestChunkSizing, powerOfTwoValidation)
{
   // Test that all chunk sizes are powers of 2
   EXPECT_TRUE(MathTk::isPowerOfTwo(cfg->getTuneAdaptiveChunkSizeSmall()));
   EXPECT_TRUE(MathTk::isPowerOfTwo(cfg->getTuneAdaptiveChunkSizeMedium()));
   EXPECT_TRUE(MathTk::isPowerOfTwo(cfg->getTuneAdaptiveChunkSizeLarge()));
   EXPECT_TRUE(MathTk::isPowerOfTwo(cfg->getTuneAdaptiveChunkSizeVeryLarge()));
}

TEST_F(TestChunkSizing, minimumChunkSizeValidation)
{
   // Test that all chunk sizes are at least STRIPEPATTERN_MIN_CHUNKSIZE
   EXPECT_GE(cfg->getTuneAdaptiveChunkSizeSmall(), STRIPEPATTERN_MIN_CHUNKSIZE);
   EXPECT_GE(cfg->getTuneAdaptiveChunkSizeMedium(), STRIPEPATTERN_MIN_CHUNKSIZE);
   EXPECT_GE(cfg->getTuneAdaptiveChunkSizeLarge(), STRIPEPATTERN_MIN_CHUNKSIZE);
   EXPECT_GE(cfg->getTuneAdaptiveChunkSizeVeryLarge(), STRIPEPATTERN_MIN_CHUNKSIZE);
}

TEST_F(TestChunkSizing, thresholdOrdering)
{
   // Test that thresholds are properly ordered
   EXPECT_LT(cfg->getTuneAdaptiveChunkSizeThresholdSmall(),
             cfg->getTuneAdaptiveChunkSizeThresholdMedium());
   EXPECT_LT(cfg->getTuneAdaptiveChunkSizeThresholdMedium(),
             cfg->getTuneAdaptiveChunkSizeThresholdLarge());
}

TEST_F(TestChunkSizing, chunkSizeOrdering)
{
   // Test that chunk sizes are properly ordered
   EXPECT_LT(cfg->getTuneAdaptiveChunkSizeSmall(),
             cfg->getTuneAdaptiveChunkSizeMedium());
   EXPECT_LT(cfg->getTuneAdaptiveChunkSizeMedium(),
             cfg->getTuneAdaptiveChunkSizeLarge());
   EXPECT_LT(cfg->getTuneAdaptiveChunkSizeLarge(),
             cfg->getTuneAdaptiveChunkSizeVeryLarge());
} 