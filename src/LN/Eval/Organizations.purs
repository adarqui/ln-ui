module LN.Eval.Organizations (
  {-
  eval_GetOrganizationForum,
  eval_GetOrganizationForumBoard,
  eval_GetOrganizationForumBoardThread,
  eval_GetOrganizationForumBoardThreadPost,
  -}
  eval_Organization
) where



import Data.Array                      (head, deleteAt, modifyAt, nub)
import Data.Either                     (Either(..))
import Data.Functor                    (($>))
import Data.Map                        as M
import Data.Maybe                      (Maybe(..), maybe)
import Halogen                         (gets, modify)
import Optic.Core                      ((^.), (..), (.~))
import Prelude                         (class Eq, bind, pure, ($), (<>))

import LN.Api                          (rd, getOrganizationPacks', getOrganizationPack', postOrganization', putOrganization', getThreadPostPack')
import LN.Api.Internal.String          as ApiS
import LN.Component.Types              (EvalEff)
import LN.Helpers.Map                  (idmapFrom)
import LN.Input.Organization           (InputOrganization(..), Organization_Act(..), Organization_Mod(..))
import LN.Input.Types                  (Input(..))
import LN.Router.Types                 (Routes(..), CRUD(..))
import LN.State.Loading                ( l_currentOrganization, l_organizations
                                       , l_currentForum
                                       , l_currentBoard
                                       , l_currentThread
                                       , l_currentThreadPost)
import LN.State.Loading.Helpers        (setLoading, clearLoading)
import LN.State.Organization           (OrganizationRequestState, defaultOrganizationRequestState)
import LN.T.Internal.Convert           (organizationResponseToOrganizationRequest)
import LN.T                            ( OrganizationPackResponses(..), OrganizationPackResponse(..)
                                       , OrganizationResponse(..)
                                       , _OrganizationResponse, name_
                                       , _OrganizationRequest, OrganizationRequest(..), displayName_, description_, company_, location_
                                       , _UserPackResponse, _UserResponse, user_, email_
                                       , ForumPackResponse(..)
                                       , BoardPackResponse(..)
                                       , ThreadPackResponse(..)
                                       , ThreadPostPackResponse(..))



{-
eval_GetOrganizationForum :: EvalEff
eval_GetOrganizationForum eval (GetOrganizationForum org_name forum_name next) = do

  pure next

  modify (_{ currentForum = Nothing })

  modify $ setLoading l_currentForum

  e_forum <- rd $ ApiS.getForumPack_ByOrganizationName' forum_name org_name

  modify $ clearLoading l_currentForum

  case e_forum of

    Left err -> eval (AddErrorApi "eval_GetOrganizationForum::ApiS.getForumPack_ByOrganizationName'" err next)

    Right pack@(ForumPackResponse forum) -> do
      modify (_{ currentForum = Just pack })
      eval (GetBoardsForForum forum.forumId next)
      pure next
      -}



{-
eval_GetOrganizationForumBoard :: EvalEff
eval_GetOrganizationForumBoard eval (GetOrganizationForumBoard org_name forum_name board_name next) = do

  modify (_{ currentBoard = Nothing })

  m_forum <- gets _.currentForum
  case m_forum of
       Nothing    -> eval (AddError "eval_GetOrganizationForumBoard" "Forum doesn't exist" next)
       Just forum -> go forum

  where
  go (ForumPackResponse forum_pack) = do

    modify $ setLoading l_currentBoard

    e_board <- rd $ ApiS.getBoardPack_ByForumId' board_name forum_pack.forumId

    modify $ clearLoading l_currentBoard

    case e_board of

      Left err                             -> eval (AddErrorApi "eval_GetOrganizationForumBoard::ApiS.getBoardPack_ByForumId'" err next)

      Right pack@(BoardPackResponse board) -> do
        modify (_{ currentBoard = Just pack })
        eval (GetThreadsForBoard board.boardId next)
        pure next
        -}



{-
eval_GetOrganizationForumBoardThread :: EvalEff
eval_GetOrganizationForumBoardThread eval (GetOrganizationForumBoardThread org_name forum_name board_name thread_name next) = do

  modify (_{ currentThread = Nothing })

  m_board <- gets _.currentBoard
  case m_board of
    Nothing    -> eval (AddError "eval_GetOrganizationForumBoardThread" "Board doesn't exist" next)
    Just  pack -> go pack

  where
  go (BoardPackResponse pack) = do

    modify $ setLoading l_currentThread

    e_thread <- rd $ ApiS.getThreadPack_ByBoardId' thread_name pack.boardId

    modify $ clearLoading l_currentThread

    case e_thread of

      Left err                               -> eval (AddErrorApi "eval_getOrganizationForumBoardThread::ApiS.getThreadPack_ByBoardId'" err next)

      Right pack@(ThreadPackResponse thread) -> do
        modify (_{ currentThread = Just pack })
        eval (GetThreadPostsForThread thread.threadId next)
        pure next
-}


{-
eval_GetOrganizationForumBoardThreadPost :: EvalEff
eval_GetOrganizationForumBoardThreadPost eval (GetOrganizationForumBoardThreadPost org_name forum_name board_name thread_name post_id next) = do

  modify (_{ currentThreadPost = Nothing })

  modify $ setLoading l_currentThreadPost

  e_post <- rd $ getThreadPostPack' post_id

  modify $ clearLoading l_currentThreadPost

  case e_post of

    Left err                                 -> eval (AddErrorApi "eval_getOrganizationForumBoardThreadPost::getThreadPostPack'" err next)

    Right pack@(ThreadPostPackResponse post) -> do
      modify (_{ currentThreadPost = Just pack })
      pure next
      -}



eval_Organization :: EvalEff
eval_Organization eval (CompOrganization sub next) = do

  m_me <- gets _.me

  case sub of

    InputOrganization_Act q -> do
      case q of
        Gets            -> act_gets
        GetId org_id    -> act_get_id org_id
        GetSid org_name -> act_get_sid org_name



    InputOrganization_Mod q -> do
      case q of
        SetDisplayName name  -> mod $ set (\req -> _OrganizationRequest .. displayName_ .~ name $ req)
        SetDescription s     -> mod $ set (\req -> _OrganizationRequest .. description_ .~ Just s $ req)
        RemoveDescription    -> mod $ set (\req -> _OrganizationRequest .. description_ .~ Nothing $ req)
        SetCompany company   -> mod $ set (\req -> _OrganizationRequest .. company_ .~ company $ req)
        SetLocation location -> mod $ set (\req -> _OrganizationRequest .. location_ .~ location $ req)
        Create               -> mod_create
        EditP org_id         -> mod_edit org_id


    _   -> pure next

 where
  append :: forall a. Eq a => Maybe (Array a) -> a -> Maybe (Array a)
  append Nothing a    = Just [a]
  append (Just arr) a = Just $ nub $ arr <> [a]
  set v req           = Just (v req)
  mod new             = modify (\st->st{ currentOrganizationRequest = maybe Nothing new st.currentOrganizationRequest }) $> next


  act_gets = do
    modify (_{ organizations = (M.empty :: M.Map Int OrganizationPackResponse) })
    modify $ setLoading l_organizations
    e_organizations <- rd $ getOrganizationPacks'
    modify $ clearLoading l_organizations
    case e_organizations of
      Left err                                             -> eval (AddErrorApi "eval_Organizations(Act/Gets)::getOrganizationPacks'" err next)
      Right (OrganizationPackResponses organization_packs) -> do
        let
          organizations_map =
            idmapFrom (\(OrganizationPackResponse pack) -> pack.organizationId) organization_packs.organizationPackResponses
        modify (_{ organizations = organizations_map })
        pure next



  act_get_id org_id = do
    modify (_{ currentOrganization = Nothing })
    modify $ setLoading l_currentOrganization
    e_org <- rd $ getOrganizationPack' org_id
    modify $ clearLoading l_currentOrganization
    case e_org of
      Left err   -> eval (AddErrorApi "eval_Organization(Act/GetId)::getOrganizationPack'" err next)
      Right pack -> do
        modify (_{ currentOrganization = Just pack })
        pure next



  act_get_sid org_name = do
    modify (_{ currentOrganization = Nothing })
    modify $ setLoading l_currentOrganization
    e_org <- rd $ ApiS.getOrganizationPack' org_name
    modify $ clearLoading l_currentOrganization
    case e_org of
      Left err   -> eval (AddErrorApi "eval_Organization(Act/GetSid)::ApiS.getOrganizationPack'" err next)
      Right pack -> do
        modify (_{ currentOrganization = Just pack })
        pure next



  mod_create = do
    m_me  <- gets _.me
    m_req <- gets _.currentOrganizationRequest
    case m_req, m_me of
         Just (OrganizationRequest req), Just me -> do
           e_organization <- rd $ postOrganization' (OrganizationRequest req{ email = me ^. _UserPackResponse .. user_ ^. _UserResponse .. email_ })
           case e_organization of
                Left err                                  -> eval (AddErrorApi "eval_Organization(Mod/Create)::postOrganization'" err next)
                Right (OrganizationResponse organization) -> do
                  eval (Goto (Organizations (Show organization.name) []) next)
         _, _  -> eval (AddError "eval_Organization(Mod/Create)" "Organization request doesn't exist" next)



  mod_edit org_id = do
    m_req <- gets _.currentOrganizationRequest
    case m_req of
         Nothing  -> eval (AddError "eval_Organization(Mod/Edit)" "Organization request doesn't exist" next)
         Just req -> do
           e_org <- rd $ putOrganization' org_id req
           case e_org of
                Left err  -> eval (AddErrorApi "eval_Organization(Mod/Edit)::putOrganization" err next)
                Right org -> do
                  modify (\st->st{ currentOrganizationRequest = Just $ organizationResponseToOrganizationRequest org })
                  eval (Goto (Organizations (Show $ org ^. _OrganizationResponse .. name_) []) next)
                  pure next
