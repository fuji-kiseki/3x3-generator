module Main exposing (..)

import Array exposing (Array)
import Browser
import Dict
import File exposing (File)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Image exposing (Image)
import Json.Encode as Encode
import Search
import Svg.Attributes
import Task exposing (..)
import Theme exposing (StoredTheme, Theme)
import View.Dialog as Dialog
import View.Icons exposing (viewMoon, viewSun)
import View.Image as Image
import View.Layout exposing (viewLayoutGrid)
import View.Switch as Switch
import View.Upload exposing (viewUpload)


type alias Model =
    { images : Array Image
    , image : Image.Model
    , category : Image.Category
    , search : Search.Model
    , modal : { target : Maybe Int }
    , theme : Theme.Model
    }


type Msg
    = GotFiles (List File)
    | ImageLoaded Int Image
    | OpenModal Int
    | CloseModal
    | ChangeCategory Image.Category
    | ToggleColorScheme
    | SystemThemeChanged Theme
    | StoredThemeChanged (Maybe StoredTheme)
    | Image Image.Msg
    | Search Search.Msg


main : Program Encode.Value Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : Encode.Value -> ( Model, Cmd Msg )
init flags =
    let
        theme =
            Theme.fromFlags flags
    in
    ( { images = Array.initialize 9 (\_ -> Image.Empty)
      , image = Image.init
      , search = Search.init
      , modal = { target = Nothing }
      , category = Image.Upload
      , theme = theme
      }
    , Theme.apply theme.systemTheme <| Maybe.withDefault Theme.Auto theme.storedTheme
    )


view : Model -> Html Msg
view { modal, images, category, theme, image, search } =
    div []
        [ button [ onClick ToggleColorScheme ]
            [ if Theme.Light == Theme.resolve theme.systemTheme theme.storedTheme then
                viewSun [ Svg.Attributes.class "h-6 w-6" ]

              else
                viewMoon [ Svg.Attributes.class "h-6 w-6" ]
            ]
        , viewLayoutGrid images OpenModal
        , Dialog.viewDialog
            { onClose = CloseModal
            , onConfirm =
                search.selected
                    |> Maybe.andThen (\id -> Dict.get id image.store)
                    |> Maybe.andThen
                        (\i ->
                            case i of
                                Image.Loaded { url } ->
                                    Maybe.map
                                        (\id ->
                                            { category = Image.Upload, url = url }
                                                |> Image.Loaded
                                                |> ImageLoaded id
                                        )
                                        modal.target

                                Image.Empty ->
                                    Nothing
                        )
            }
            (modal.target
                |> Maybe.map (\_ -> True)
                |> Maybe.withDefault False
            )
            [ Dialog.viewHeader
                [ div [ class "flex justify-between" ]
                    [ Switch.viewSwitch
                        { toMsg = ChangeCategory
                        , selected = category
                        }
                        [ { value = Image.Upload
                          , content = [ text "Files" ]
                          }
                        , { value = Image.Url
                          , content = [ text "Url" ]
                          }
                        ]
                    , Search.view search
                        (\input ->
                            Image <|
                                Image.Set
                                    ( search.query
                                    , Image.Loaded
                                        { category = Image.Upload
                                        , url = input
                                        }
                                    )
                        )
                    ]
                ]
            , Keyed.ul [ class "grid grid-cols-3 grid-flow-row gap-2 m-4" ]
                ((case category of
                    Image.Upload ->
                        ( "upload", viewUpload GotFiles )

                    _ ->
                        ( "nothing", text "" )
                 )
                    :: Image.imageList (Search << Search.SetSelected)
                        image.store
                        search.selected
                )
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotFiles files ->
            ( model
            , files
                |> List.head
                |> Maybe.map (Image.fromFile >> Task.perform (Image << Image.Set))
                |> Maybe.withDefault Cmd.none
            )

        ImageLoaded index image ->
            ( { model
                | images = Array.set index image model.images
                , modal = { target = Nothing }
              }
            , Cmd.none
            )

        OpenModal target ->
            ( { model | modal = { target = Just target } }, Cmd.none )

        CloseModal ->
            ( { model | modal = { target = Nothing } }, Cmd.none )

        ChangeCategory category ->
            ( { model | category = category }, Cmd.none )

        ToggleColorScheme ->
            let
                storedTheme =
                    Theme.toggle model.theme
            in
            ( { model
                | theme =
                    { systemTheme = model.theme.systemTheme
                    , storedTheme = Just storedTheme
                    }
              }
            , Theme.apply model.theme.systemTheme storedTheme
            )

        SystemThemeChanged systemTheme ->
            ( { model
                | theme =
                    { storedTheme = model.theme.storedTheme
                    , systemTheme = systemTheme
                    }
              }
            , Cmd.none
            )

        StoredThemeChanged storedTheme ->
            ( { model
                | theme =
                    { storedTheme = storedTheme
                    , systemTheme = model.theme.systemTheme
                    }
              }
            , Cmd.none
            )

        Image imageMsg ->
            let
                ( image, cmd ) =
                    Image.update imageMsg model.image
            in
            ( { model | image = image }, Cmd.map Image cmd )

        Search searchMsg ->
            let
                ( search, cmd ) =
                    Search.update searchMsg model.search
            in
            ( { model | search = search }, Cmd.map Search cmd )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Theme.subscriptions
        { onSystemThemeChanged = SystemThemeChanged
        , onStoredThemeChanged = StoredThemeChanged
        }
