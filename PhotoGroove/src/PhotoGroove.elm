module PhotoGroove exposing (main)

import Browser
import Html exposing (Html, button, div, h1, img, input, label, small, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Random



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init =
            \flags ->
                ( initialModel
                , Cmd.none
                )
        , view = view
        , update = update
        , subscriptions = \model -> Sub.none
        }



-- MODEL


type alias Photo =
    { url : String }


type ThumbnailSize
    = Small
    | Medium
    | Large


type alias Model =
    { status : Status
    , chosenSize : ThumbnailSize
    }


type Status
    = Loading
    | Loaded (List Photo) String
    | Errored String


initialModel : Model
initialModel =
    { status = Loading
    , chosenSize = Medium
    }



-- UPDATE


type Msg
    = ClickedPhoto String
    | ClickedSize ThumbnailSize
    | ClickedSurpriseMe
    | GotRandomPhoto Photo
    | GotPhotos (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedPhoto url ->
            ( { model | status = selectUrl url model.status }, Cmd.none )

        ClickedSurpriseMe ->
            case model.status of
                Loaded (firstPhoto :: otherPhotos) _ ->
                    Random.uniform firstPhoto otherPhotos
                        |> Random.generate GotRandomPhoto
                        |> Tuple.pair model

                Loaded [] _ ->
                    ( model, Cmd.none )

                Loading ->
                    ( model, Cmd.none )

                Errored errorMessage ->
                    ( model, Cmd.none )

        ClickedSize size ->
            ( { model | chosenSize = size }, Cmd.none )

        GotRandomPhoto photo ->
            ( { model | status = selectUrl photo.url model.status }, Cmd.none )

        GotPhotos result ->
            case result of
                Ok responseStr ->
                    let
                        urls =
                            String.split "," responseStr
                        photos =
                            List.map (\url -> { url = url }) urls
                        firstUrl = 
                            List.head photos
                    in
                    ( { model | status = Loaded photos firstUrl }, Cmd.none )


                Err httpError ->
                    ( { model | status = Errored "Server Error!" }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "content" ] <|
        case model.status of
            Loaded photos selectedUrl ->
                viewLoaded photos selectedUrl model.chosenSize

            Loading ->
                [ h1 [] [ text "Loading..." ] ]

            Errored errorMessage ->
                [ text ("Error: " ++ errorMessage) ]


viewLoaded : List Photo -> String -> ThumbnailSize -> List (Html Msg)
viewLoaded photos selectedUrl chosenSize =
    [ h1 [] [ text "Photos Grooves" ]
    , button
        [ onClick ClickedSurpriseMe ]
        [ text "Surpresinha!" ]
    , div [ id "choose-size" ]
        (List.map viewSizeChooser [ Small, Medium, Large ])
    , div [ id "thumbnails", class (sizeToString chosenSize) ] (List.map (viewThumbnail selectedUrl) photos)
    , img
        [ class "large"
        , src (urlPrefix ++ "large/" ++ selectedUrl)
        ]
        []
    ]


selectUrl : String -> Status -> Status
selectUrl url status =
    case status of
        Loaded photos _ ->
            Loaded photos url

        Loading ->
            status

        Errored errorMessage ->
            status


viewThumbnail : String -> Photo -> Html Msg
viewThumbnail selectedUrl thumb =
    img
        [ src (urlPrefix ++ thumb.url)
        , classList [ ( "selected", selectedUrl == thumb.url ) ]
        , onClick (ClickedPhoto thumb.url)
        ]
        []


viewSizeChooser : ThumbnailSize -> Html Msg
viewSizeChooser size =
    label []
        [ input [ type_ "radio", name "size", onClick (ClickedSize size) ] []
        , text (sizeToString size)
        ]


sizeToString : ThumbnailSize -> String
sizeToString size =
    case size of
        Small ->
            "small"

        Medium ->
            "med"

        Large ->
            "large"


urlPrefix : String
urlPrefix =
    "http://elm-in-action.com/"
