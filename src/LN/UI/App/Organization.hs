{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies      #-}

module LN.UI.App.Organization (
  Store,
  defaultStore,
  Action (..),
  store,
  view,
  view_
) where



import           Control.DeepSeq         (NFData)
import           Data.Text               (Text)
import           Data.Typeable           (Typeable)
import           GHC.Generics            (Generic)
import           React.Flux              hiding (view)
import qualified React.Flux              as RF

import qualified LN.UI.App.Delete        as Delete
import           LN.UI.Router.Class.CRUD



data Store = Store
  deriving (Show, Typeable, Generic, NFData)



data Action = Action
  deriving (Show, Typeable, Generic, NFData)



instance StoreData Store where
  type StoreAction Store = Action
  transform action st = do
    putStrLn "Organization"
    pure Store



store :: ReactStore Store
store = mkStore defaultStore



defaultStore :: Store
defaultStore = Store



view_ :: CRUD -> ReactElementM eventHandler ()
view_ crud =
  RF.view view crud mempty



view :: ReactView CRUD
view = defineControllerView "organization" store $ \st crud ->
  case crud of
    ShowS org_sid   -> viewShowS org_sid
    New             -> viewNew
    EditS org_sid   -> viewEditS org_sid
    DeleteS org_sid -> Delete.view_



viewShowS :: Text -> ReactElementM ViewEventHandler ()
viewShowS org_sid = p_ $ elemText "show"



viewNew :: ReactElementM ViewEventHandler ()
viewNew = p_ $ elemText "new"



viewEditS :: Text -> ReactElementM ViewEventHandler ()
viewEditS org_sid = p_ $ elemText "edit"
