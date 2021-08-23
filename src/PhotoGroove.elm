module PhotoGroove exposing (main)

import Array exposing (Array)
import Browser
import Html exposing (div, h1, img, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)



-- MAIN


main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }



-- MODEL


type alias Photo =
    { url : String }


type alias Model =
    { photos : List Photo, selectedUrl : String }


initialModel : Model
initialModel =
    { photos =
        [ { url = "1.jpeg" }
        , { url = "2.jpeg" }
        , { url = "3.jpeg" }
        ]
    , selectedUrl = "1.jpeg"
    }



-- UPDATE


type alias Msg =
    { description : String, data : String }


update : Msg -> Model -> Model
update msg model =
    if msg.description == "ClickedPhoto" then
        { model | selectedUrl = msg.data }

    else
        model



-- VIEW


view model =
    div [ class "container" ]
        [ h1 [] [ text "Photos Grooves" ]
        , div [ id "thumbnails" ] (List.map (viewThumbnail model.selectedUrl) model.photos)
        , img
            [ class "large"
            , src (urlPrefix ++ "large/" ++ model.selectedUrl)
            ]
            []
        ]


photoArray : Array Photo
photoArray =
    Array.fromList initialModel.photos


viewThumbnail selectedUrl thumb =
    img
        [ src (urlPrefix ++ thumb.url)
        , classList [ ( "selected", selectedUrl == thumb.url ) ]
        , onClick { description = "ClickedPhoto", data = thumb.url }
        ]
        []


urlPrefix : String
urlPrefix =
    "http://elm-in-action.com/"
