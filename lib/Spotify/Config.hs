{-# LANGUAGE TemplateHaskell #-}

module Spotify.Config (
  Config (..),
  UserConfig (..),
  readConfig,
  runConfigIO,
) where

import Dhall
import Effectful
import Effectful.Dispatch.Dynamic
import Effectful.TH

import Spotify.Effect.FileSystem

data UserConfig = UserConfig
  { userClientId :: Text
  , userClientSecret :: Text
  }
  deriving stock (Generic, Show)

instance FromDhall UserConfig

data Config :: Effect where
  ReadConfig :: Config m UserConfig

makeEffect ''Config

runConfigIO :: (IOE :> es, FileSystem :> es) => Eff (Config : es) a -> Eff es a
runConfigIO = interpret $ \_ -> \case
  ReadConfig -> readConfigFile "Spotify.dhall" >>= \c -> liftIO (input auto c)
