module Main where

import Prelude
import Control.Monad.Aff (Canceler, launchAff, makeAff, Aff)
import Control.Monad.Aff.Console (logShow)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Parallel.Class (parallel, runParallel)

type FilePath = String
type FileType = String
type Orig = FilePath
type Dest = FilePath
type Name = String
type Length = Int

type Args =
  { orig :: Orig
  , dest :: Dest
  , filetype :: FileType
  }

foreign import getArgs :: Unit -> Args

type ConvertOptions =
  { orig :: FilePath
  , path :: FilePath
  , length :: Int
  , filetype :: FileType
  }
foreign import data IMAGEMAGICK :: !
foreign import convert :: forall e.  ( String -> Eff ( im :: IMAGEMAGICK | e ) Unit ) -> ConvertOptions -> Eff ( im :: IMAGEMAGICK | e ) Unit
convert' :: forall e. ConvertOptions -> Aff ( im :: IMAGEMAGICK | e ) String
convert' opts = makeAff (\e s -> convert s opts)

main :: forall e.
  Eff
    ( err :: EXCEPTION, im :: IMAGEMAGICK | e )
    ( Canceler ( im :: IMAGEMAGICK | e ) )
main = launchAff do
  let args = getArgs unit
  let opts length = { orig: args.orig, path: args.dest, length: length, filetype: args.filetype }
  let f a b c d = do
        logShow a
        logShow b
        logShow c
        logShow d
  let convert'' x = parallel $ convert' $ opts x
  runParallel $ f
    <$> (convert'' 64)
    <*> (convert'' 128)
    <*> (convert'' 256)
    <*> (convert'' 512)
