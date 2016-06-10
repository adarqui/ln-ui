module LN.View.Forums.Show (
  renderView_Forums_Show,
  renderView_Forums_Show'
) where



import Daimyo.Data.ArrayList           (listToArray)
import Data.Map                        as M
import Data.Maybe                      (Maybe(..), maybe)
import Halogen                         (ComponentHTML, HTML)
import Halogen.HTML.Indexed            as H
import Halogen.HTML.Properties.Indexed as P
import Halogen.Themes.Bootstrap3       as B
import Optic.Core                      ((^.), (..))
import Prelude                         (id, map, show, ($), (<>), (/=))

import LN.Input.Types                  (Input)
import LN.Router.Link                  (linkToP_Classes, linkToP_Glyph', linkToP)
import LN.Router.Types                 (Routes(..), CRUD(..))
import LN.State.Types                  (State)
import LN.View.Boards.Index            (renderView_Boards_Index')
import LN.View.Module.Loading          (renderLoading)
import LN.T                            ( ForumPackResponse
                                       , _ForumPackResponse, _ForumResponse, organization_
                                       , _ForumPackResponse, _ForumResponse, forum_
                                       , OrganizationPackResponse, OrganizationResponse
                                       , _OrganizationPackResponse, _OrganizationResponse
                                       , organization_)




renderView_Forums_Show :: State -> ComponentHTML Input
renderView_Forums_Show st =

  case st.currentOrganization, st.currentForum of

       Just org_pack, Just forum_pack ->
         renderView_Forums_Show' org_pack forum_pack (renderView_Boards_Index' org_pack forum_pack st.boards)

       _, _                           -> renderLoading



renderView_Forums_Show'
  :: OrganizationPackResponse
  -> ForumPackResponse
  -> HTML _ _
  -> ComponentHTML Input
renderView_Forums_Show' org_pack forum_pack plumbing_boards =
  H.div [P.class_ B.containerFluid] [

    H.div [P.class_ B.pageHeader] [
      H.h2_ [H.text forum.name],
      linkToP [] (OrganizationsForums org.name (Edit forum.name) []) "edit",
      H.p [P.class_ B.lead] [H.text forum_desc]
    ],

    H.div [P.class_ B.container] [
      H.div_ [linkToP [] (OrganizationsForumsBoards org.name forum.name New []) "add-board"]
    ],

    H.div [] [plumbing_boards]
  ]
  where
  org        = org_pack ^. _OrganizationPackResponse .. organization_ ^. _OrganizationResponse
  forum      = forum_pack ^. _ForumPackResponse .. forum_ ^. _ForumResponse
  forum_desc = maybe "No description." id forum.description
