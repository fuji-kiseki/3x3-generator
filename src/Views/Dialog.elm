module Views.Dialog exposing (ModalConfig, viewDialog, viewHeader)

import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)


type alias ModalConfig msg =
    { onClose : msg
    , onConfirm : Maybe msg
    }


viewDialog : ModalConfig msg -> Bool -> List (Html msg) -> Html msg
viewDialog { onClose, onConfirm } open content =
    if open then
        div
            [ class "fixed inset-0 flex items-center justify-center bg-dn-foreground-200/20 backdrop-blur-sm" ]
            [ div
                [ class "flex flex-col justify-center w-3xl max-w-9/10 max-h-8/10 overflow-hidden rounded-xl border border-dn-border-100 bg-dn-background-100" ]
                [ div [ class "overflow-auto" ] content
                , footer
                    [ class "flex justify-between p-4 border-t border-dn-border-100 bg-dn-background-200/90 backdrop-blur-sm" ]
                    [ button [ baseBtnStyle, closeBtnStyle, onClick onClose ] [ text "Cancel" ]
                    , button
                        (baseBtnStyle
                            :: (case onConfirm of
                                    Nothing ->
                                        [ confirmBtnStyle False ]

                                    Just msg ->
                                        [ confirmBtnStyle True, onClick msg ]
                               )
                        )
                        [ text "Confirm" ]
                    ]
                ]
            ]

    else
        text ""


viewHeader : List (Html msg) -> Html msg
viewHeader content =
    header
        [ class "sticky top-0 p-4 border-b border-dn-border-100 bg-dn-background-200/90 backdrop-blur-sm" ]
        content


baseBtnStyle : Attribute msg
baseBtnStyle =
    class "px-3 py-2 rounded-md text-sm transition-colors"


closeBtnStyle : Attribute msg
closeBtnStyle =
    class "cursor-pointer border border-dn-border-100 bg-dn-background-100 text-dn-foreground-200 hover:bg-dn-background-200"


confirmBtnStyle : Bool -> Attribute msg
confirmBtnStyle isActive =
    classList
        [ ( "bg-dn-emphasis-100 text-dn-emphasis-foreground hover:bg-dn-emphasis-hover cursor-pointer"
          , isActive
          )
        , ( "bg-dn-background-200 text-dn-foreground-100 cursor-not-allowed"
          , not isActive
          )
        ]
