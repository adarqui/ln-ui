{-# LANGUAGE BangPatterns      #-}
{-# LANGUAGE OverloadedStrings #-}

module LN.UI.ReactFlux.Helpers.ReactFluxView (
  defineViewWithSKey
) where



import           Data.Typeable
import           React.Flux
import qualified React.Flux as RF

import           LN.UI.Core.Helpers.GHCJS



defineViewWithSKey
  :: Typeable props
  => JSString                                     -- ^ A name & key for this view
  -> props                                        -- ^ props
  -> (props -> ReactElementM ViewEventHandler ()) -- ^ The rendering function
  -> ReactElementM ViewEventHandler ()

-- TESTING
--
-- defineViewWithSKey key props handler =
--   handler props
--   where
--   go = defineView key handler

defineViewWithSKey key props handler =
  viewWithSKey go key props mempty
  where
  go = defineView key handler

-- defineViewWithSKey key props handler =
--   RF.view (defineView key handler) props mempty
