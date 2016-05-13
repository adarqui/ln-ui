module LN.Input.Types (
  Input (..)
) where



import LN.Input.CreateThread   (InputCreateThread)
import LN.Input.LikeThreadPost (InputLikeThreadPost)
import LN.Input.OrderBy        (InputOrderBy)
import LN.Input.Profile        (InputProfile)
import LN.Input.ThreadPost     (InputThreadPost)
import LN.Router.Types         (Routes)
import LN.T



data Input a
  = Goto Routes a

  | GetUser String a
  | GetMe a
  | GetUsers a
  | GetUsers_MergeMap_ByUser (Array UserSanitizedResponse) a
  | GetUsers_MergeMap_ByUserId (Array Int) a

  | GetOrganizations a
  | GetOrganization String a
  | GetOrganizationForum String String a
  | GetOrganizationForumBoard String String String a
  | GetOrganizationForumBoardThread String String String String a

  | GetTeams a

  | GetForums a
  | GetForumsForOrg String a

  | GetBoardPacks a
  | GetBoardPacksForForum Int a

  | GetThreadPacks a
  | GetThreadPacksForBoard Int a

  | GetThreadPosts a
  | GetThreadPostsForThread Int a

  | GetThreadPost String a
  | GetThreadPostLikes a

  | GetPMs a
  | GetResources a
  | GetLeurons a

  | ConnectSocket a

  | CompThreadPost InputThreadPost a

  | CompCreateThread InputCreateThread a

  | CompOrderBy InputOrderBy a

  | CompProfile InputProfile a

  | CompLikeThreadPost InputLikeThreadPost a

  | Nop a