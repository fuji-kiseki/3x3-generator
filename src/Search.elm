module Search exposing (Model, Msg(..), init, update, view)

import Html exposing (Html)
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Decode


type alias Model =
    { query : String
    , selected : Maybe String
    }


type Msg
    = SetQuery String
    | SetSelected String


init : Model
init =
    Model "" Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetQuery query ->
            ( { model | query = query }, Cmd.none )

        SetSelected selected ->
            ( { model | selected = Just selected }, Cmd.none )


view : Model -> (String -> msg) -> Html msg
view model msg =
    Html.form
        [ attribute "role" "search"
        , class "flex w-fit px-2 rounded-lg border bg-dn-background-100 border-dn-border-100"
        ]
        [ Html.input
            [ type_ "text"
            , name "url"
            , placeholder "url"
            , value model.query
            , on "keydown" <| onKeydown (msg model.query)
            , class "w-full px-2 py-1 bg-transparent outline-none"
            , class "text-dn-foreground-300"
            , class "placeholder:text-dn-foreground-100"
            , class "caret-dn-foreground-100"
            ]
            []
        ]


onKeydown : msg -> Decode.Decoder msg
onKeydown msg =
    Decode.field "key" Decode.string
        |> Decode.andThen
            (\key ->
                if key == "Enter" then
                    Decode.succeed msg

                else
                    Decode.fail ""
            )
