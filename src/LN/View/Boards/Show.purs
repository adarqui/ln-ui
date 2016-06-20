module LN.View.Boards.Show (
  renderView_Boards_Show,
  renderView_Boards_Show'
) where



import Daimyo.Data.ArrayList           (listToArray)
import Data.Map                        as M
import Data.Maybe                      (Maybe(..), maybe)
import Halogen                         (ComponentHTML, HTML)
import Halogen.HTML.Indexed            as H
import Halogen.HTML.Properties.Indexed as P
import Halogen.Themes.Bootstrap3       as B
import Optic.Core                      ((^.), (..))
import Prelude                         (id, show, map, negate, ($), (<>))

import LN.Access                       (orgOwner, orgMember)
import LN.Input.Types                  (Input)
import LN.Router.Link                  (linkToP, linkToP_Classes, linkToP_Glyph')
import LN.Router.Types                 (Routes(..), CRUD(..))
import LN.Router.Class.Params          (emptyParams)
import LN.State.Types                  (State)
import LN.View.Helpers
import LN.View.Threads.Index           (renderView_Threads_Index')
import LN.View.Module.Loading          (renderLoading)
import LN.View.Module.OrderBy          (renderOrderBy)
import LN.T                            ( Param(..)
                                       , OrganizationPackResponse, ForumPackResponse
                                       , _OrganizationPackResponse, _OrganizationResponse, organization_, isOwner_
                                       , _ForumPackResponse, _ForumResponse, forum_
                                       , _BoardPackResponse, _BoardResponse, board_
                                       , _BoardStatResponse, stat_
                                       , BoardPackResponse
                                       , ThreadPackResponse
                                       , ThreadResponse(..)
                                       , ThreadPostResponse(..)
                                       , UserSanitizedResponse(..)
                                       , latestThread_, latestThreadPost_, latestThreadPostUser_)




renderView_Boards_Show :: State -> ComponentHTML Input
renderView_Boards_Show st =

  case st.currentOrganization, st.currentForum, st.currentBoard of

       Just org_pack, Just forum_pack, Just board_pack ->

         renderView_Boards_Show' org_pack forum_pack board_pack st.threads $
           renderView_Threads_Index' st.meId org_pack forum_pack board_pack st.threads st.threadsPageInfo st.currentPage st.usersMap

       _, _, _                                         -> renderLoading



renderView_Boards_Show'
  :: OrganizationPackResponse
  -> ForumPackResponse
  -> BoardPackResponse
  -> M.Map Int ThreadPackResponse
  -> HTML _ _
  -> ComponentHTML Input
renderView_Boards_Show' org_pack forum_pack board_pack thread_packs plumbing_threads =
  H.div [P.class_ B.containerFluid] [
    H.div [P.class_ B.pageHeader] [
      H.h2_ [H.text board.name],
      H.p [P.class_ B.lead] [H.text board_desc],

      -- TODO FIXME: clean this nested junk up
      if orgOwner org_pack
         then
           buttonGroup_HorizontalSm1 [
             glyphButtonLinkDef_Pencil $ OrganizationsForumsBoards org.name forum.name (Edit board.name) emptyParams,
             glyphButtonLinkDef_Plus $ OrganizationsForumsBoardsThreads org.name forum.name board.name New emptyParams,
             glyphButtonLinkDef_Trash $ OrganizationsForumsBoards org.name forum.name (Delete board.name) emptyParams
           ]
         else
           if orgMember org_pack
              then
                buttonGroup_HorizontalSm1 [
                  glyphButtonLinkDef_Plus $ OrganizationsForumsBoardsThreads org.name forum.name board.name New emptyParams
                ]
              else H.div_ []

    ],
    H.div [P.class_ B.clearfix] [H.span [P.classes [B.pullLeft]] [
      renderOrderBy $ OrganizationsForumsBoards org.name forum.name (Show board.name) emptyParams
    ]],
    H.div [] [plumbing_threads]
  ]
  where
  org        = org_pack ^. _OrganizationPackResponse .. organization_ ^. _OrganizationResponse
  forum      = forum_pack ^. _ForumPackResponse .. forum_ ^. _ForumResponse
  board      = board_pack ^. _BoardPackResponse .. board_ ^. _BoardResponse
  board_desc = maybe "No description." id board.description
