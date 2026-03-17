module Image exposing (..)

import Dict exposing (Dict)
import File exposing (File)
import Task exposing (..)


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



-- Constructors


fromFile : File -> Task Never ( String, Image )
fromFile file =
    file
        |> File.toUrl
        |> Task.map (ImageArgs Upload)
        |> Task.map (\image -> ( File.name file, Loaded image ))



-- Image Selector


type alias ImageSelector =
    { selectedCategory : Category
    , searchQuery : String
    , selectedImage : Maybe String
    , availableImages : Dict String Image
    }


alterImageSelector : (ImageSelector -> ImageSelector) -> { r | imageSelector : ImageSelector } -> { r | imageSelector : ImageSelector }
alterImageSelector transform model =
    { model | imageSelector = transform model.imageSelector }
