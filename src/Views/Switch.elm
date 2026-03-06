module Views.Switch exposing (..)

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)


switch : List (Html msg) -> Html msg
switch content =
    div
        [ class "flex w-fit p-0.5 bg-dn-background-100 border border-dn-border-200 rounded-sm" ]
        content


type alias Control value action =
    { label : String
    , value : value
    , action : value -> action
    }


viewControl : value -> Control value action -> Html action
viewControl selected ctl =
    button
        [ onClick (ctl.action ctl.value)
        , class "rounded-xs px-2 py-1 cursor-pointer transition-colors"
        , classList
            [ ( "bg-dn-border-100 text-dn-foreground-200"
              , selected == ctl.value
              )
            , ( "text-dn-foreground-100 hover:bg-dn-background-200"
              , selected /= ctl.value
              )
            ]
        ]
        [ text ctl.label ]
