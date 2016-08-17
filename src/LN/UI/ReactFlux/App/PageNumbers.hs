{-# LANGUAGE BangPatterns      #-}
{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE Rank2Types        #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE TypeFamilies      #-}

module LN.UI.ReactFlux.App.PageNumbers (
    view
  , view_
  , view1
  , view2
  , runPageInfo
) where



import           Control.Monad                         (forM_)
import           React.Flux                            hiding (view)
import qualified Web.Bootstrap3                        as B

import           LN.UI.Core.Helpers.DataText           (tshow)
import           LN.UI.Core.Helpers.GHCJS              (JSString)
import           LN.UI.Core.PageInfo                   (PageInfo (..),
                                                        runPageInfo)
import           LN.UI.Core.PageNumbers                (buildPages)
import           LN.UI.Core.Router                     (RouteWith (..),
                                                        emptyParams, updateParams_Offset_Limit)
import           LN.UI.ReactFlux.Helpers.ReactFluxDOM  (ahrefName, classNames_)
import           LN.UI.ReactFlux.Helpers.ReactFluxView (defineViewWithSKey)
import           LN.UI.ReactFlux.Types                 (HTMLView_)



view
  :: PageInfo
  -> RouteWith
  -> HTMLView_
view = view_ "page-numbers"



view1
  :: PageInfo
  -> RouteWith
  -> HTMLView_
view1 = view_ "page-numbers-1"



view2
  :: PageInfo
  -> RouteWith
  -> HTMLView_
view2 = view_ "page-numbers-2"



view_
  :: JSString
  -> PageInfo
  -> RouteWith
  -> HTMLView_

view_ !key !page_info' !route_with' =
  defineViewWithSKey key (page_info', route_with') $ \(page_info, route_with@(RouteWith route params)) -> do
    let
      (prev, pages, next, limit) = buildPages page_info route_with
      route_page page            = RouteWith route (updateParams_Offset_Limit ((page-1)*limit) limit params)
    case pages of
      []     -> mempty
      _      ->
        div_ $ do
          ul_ [classNames_ [B.pagination, B.paginationSm]] $ do
            li_ ["key" $= "pg-prev"] $ ahrefName "prev" (route_page prev)
            forM_ (zip [(1::Int)..] pages) $
              \(idx, page_number) ->
                if idx == 1
                  then
                    -- in page 1, we don't want offset/limit showing
                    --
                    li_ ["key" @= idx] $ ahrefName (tshow page_number) (RouteWith route emptyParams)
                  else
                    -- else, append offset/limit to everything
                    --
                    li_ ["key" @= idx] $ ahrefName (tshow page_number) (route_page page_number)
            li_ ["key" $= "pg-next"] $ ahrefName "next" (route_page next)
