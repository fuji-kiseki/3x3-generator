module Image exposing (Category(..), Image(..), Model, Msg(..), fromFile, init, update)

import Dict exposing (Dict)
import File exposing (File)
import Task exposing (..)


type alias Model =
    { store : Dict String Image
    }


type Image
    = Empty
    | Loaded ImageArgs


type alias ImageArgs =
    { category : Category
    , url : String
    }


type Category
    = Upload
    | Url


type Msg
    = Set ( String, Image )


init : Model
init =
    { store = Dict.empty
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Set ( id, image ) ->
            ( { model | store = Dict.insert id image model.store }
            , Cmd.none
            )



-- Constructors


fromFile : File -> Task Never ( String, Image )
fromFile file =
    file
        |> File.toUrl
        |> Task.map (ImageArgs Upload)
        |> Task.map (\image -> ( File.name file, Loaded image ))
