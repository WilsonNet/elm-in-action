module PhotoGroove exposing (main)

import Browser
import Html exposing (div, h1, img, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


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


update msg model =
    if msg.description == "ClickedPhoto" then
        { model | selectedUrl = msg.data }

    else
        model


initialModel =
    { photos =
        [ { url = "1.jpeg" }
        , { url = "2.jpeg" }
        , { url = "3.jpeg" }
        ]
    , selectedUrl = "1.jpeg"
    }


main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }


viewThumbnail selectedUrl thumb =
    img
        [ src (urlPrefix ++ thumb.url)
        , classList [ ( "selected", selectedUrl == thumb.url ) ]
        , onClick { description = "ClickedPhoto", data = thumb.url }
        ]
        []


urlPrefix =
    "http://elm-in-action.com/"
