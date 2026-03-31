module Search exposing (Model, Msg(..), init, update)


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
