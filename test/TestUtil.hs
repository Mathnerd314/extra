
module TestUtil(runTests, testGen, erroneous) where

import Test.QuickCheck
import Test.QuickCheck.Test
import Control.Monad
import Control.Exception.Extra
import Data.Either.Extra
import Data.IORef
import System.IO.Unsafe


{-# NOINLINE testCount #-}
testCount :: IORef Int
testCount = unsafePerformIO $ newIORef 0


testGen :: Testable prop => String -> prop -> IO ()
testGen msg prop = do
    putStrLn msg
    r <- quickCheckResult prop
    unless (isSuccess r) $ error "Test failed"
    modifyIORef testCount (+1)


erroneous :: a -> Bool
erroneous x = unsafePerformIO $ fmap isLeft $ try_ $ evaluate x


runTests :: IO () -> IO ()
runTests t = do
    writeIORef testCount 0
    t
    n <- readIORef testCount
    putStrLn $ "Success (" ++ show n ++ " tests)"