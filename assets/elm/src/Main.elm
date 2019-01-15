port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events as HE exposing (onClick)
import Json.Encode as JE



-- JavaScript usage: app.ports.websocketIn.send(response);


port websocketIn : (String -> msg) -> Sub msg



-- JavaScript usage: app.ports.websocketOut.subscribe(handler);


port websocketOut : String -> Cmd msg


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



{- MODEL -}


type alias Note =
    { key : String
    , pitch : Pitch
    , name : String
    , touched : Bool
    }


type Pitch
    = Flat
    | Natural


type alias Piano =
    List Note


type Instrument
    = Keyboard Piano


type alias Musician =
    { userId : String, name : String, instrument : Maybe Instrument }


type alias Band =
    List Musician


piano : Piano
piano =
    [ { pitch = Natural, key = "C4", name = "C", touched = False }
    , { pitch = Flat, key = "C#4", name = "C#", touched = False }
    , { pitch = Natural, key = "D4", name = "D", touched = False }
    , { pitch = Flat, key = "D#4", name = "D#", touched = False }
    , { pitch = Natural, key = "E4", name = "E", touched = False }
    , { pitch = Natural, key = "F4", name = "F", touched = False }
    , { pitch = Flat, key = "F#4", name = "F#", touched = False }
    , { pitch = Natural, key = "G4", name = "G", touched = False }
    , { pitch = Flat, key = "G#4", name = "G#", touched = False }
    , { pitch = Natural, key = "A4", name = "A", touched = False }
    , { pitch = Flat, key = "A#4", name = "A#", touched = False }
    , { pitch = Natural, key = "B4", name = "B", touched = False }
    , { pitch = Natural, key = "C5", name = "C", touched = False }
    ]


type alias Model =
    { responses : List String
    , band : Band
    , piano : Piano
    , roomId : Maybe String
    , view : ViewState
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { responses = []
      , band = []
      , piano = piano
      , roomId = Nothing
      , view = Lobby
      }
    , Cmd.none
    )



{- UPDATE -}


type ViewState
    = Lobby
    | Room


type Msg
    = Submit String
    | WebsocketIn String
    | ViewState ViewState


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Submit value ->
            ( model
            , websocketOut value
            )

        WebsocketIn value ->
            ( { model | responses = value :: model.responses }
            , Cmd.none
            )

        ViewState value ->
            ( { model | view = value }, Cmd.none )



{- SUBSCRIPTIONS -}


subscriptions : Model -> Sub Msg
subscriptions model =
    websocketIn WebsocketIn



{- VIEW -}


renderLobby : Model -> Html Msg
renderLobby model =
    div []
        [ button [ onClick (ViewState Room) ] [ text "crick me" ]
        , text "lobby me"
        ]


renderRoom : Model -> Html Msg
renderRoom model =
    div []
        [ ul []
            (List.map
                (\l ->
                    button
                        [ classList
                            [ ( "natural", l.pitch == Natural )
                            , ( "flat", l.pitch == Flat )
                            , ( "touched-natural", l.pitch == Natural && l.touched )
                            , ( "touched-flat", l.pitch == Flat && l.touched )
                            ]
                        , onClick (Submit l.key)
                        ]
                        [ text l.name ]
                )
                model.piano
            )
        ]


view : Model -> Html Msg
view model =
    case model.view of
        Lobby ->
            renderLobby model

        Room ->
            renderRoom model
