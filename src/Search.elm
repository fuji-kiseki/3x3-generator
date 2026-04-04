module Search exposing (Model, Msg(..), init, update, view)

import Html exposing (Html)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)


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


view : Model -> (String -> msg) -> (String -> msg) -> Html msg
view model onSubmitMsg onInputMsg =
    Html.form
        [ attribute "role" "search"
        , onSubmit <| onSubmitMsg model.query
        , class "flex w-fit px-2 rounded-lg border bg-dn-background-100 border-dn-border-100"
        ]
        [ Html.input
            [ type_ "text"
            , name "url"
            , placeholder "url"
            , value model.query
            , onInput onInputMsg
            , class "w-full px-2 py-1 bg-transparent outline-none"
            , class "text-dn-foreground-300"
            , class "placeholder:text-dn-foreground-100"
            , class "caret-dn-foreground-100"
            ]
            []
        ]
