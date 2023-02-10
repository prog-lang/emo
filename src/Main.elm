port module Main exposing (..)

import Browser exposing (Document)
import Browser.Events as Events
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Keyboard.Event exposing (KeyboardEvent, decodeKeyboardEvent)



-- FLAGS


type alias Flags =
    ()



-- MODEL


type alias Model =
    { program : String
    , cpuState : String
    }



-- MSG


type Msg
    = KeyboardEvent Keyboard.Event.KeyboardEvent
    | GotCpuState String



-- MAIN


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- INIT


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( initModel, Cmd.none )


initModel : Model
initModel =
    { program = ""
    , cpuState = "UNKNOWN"
    }



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Emo"
    , body = viewBody model
    }


viewBody : Model -> List (Html Msg)
viewBody model =
    [ h1 [] [ text "CPU STATE:" ]
    , pre [] [ code [] [ text model.cpuState ] ]
    , h1 [] [ text "PROGRAM:" ]
    , pre [] [ code [] [ text model.program ] ]
    ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyboardEvent event ->
            updateOnKeyboardEvent event model

        GotCpuState state ->
            ( { model | cpuState = state }, Cmd.none )


updateOnKeyboardEvent : KeyboardEvent -> Model -> ( Model, Cmd Msg )
updateOnKeyboardEvent event model =
    case event.key of
        Nothing ->
            ( model, Cmd.none )

        Just key ->
            updateOnKeyDown event key model


updateOnKeyDown : KeyboardEvent -> String -> Model -> ( Model, Cmd Msg )
updateOnKeyDown event key model =
    case key of
        "Enter" ->
            if event.ctrlKey then
                ( model, cpuExecuteHexInstruction model.program )

            else
                ( { model | program = model.program ++ "\n" }, Cmd.none )

        "Backspace" ->
            ( { model | program = String.dropRight 1 model.program }, Cmd.none )

        other ->
            if String.length other == 1 then
                ( { model | program = model.program ++ other }, Cmd.none )

            else
                ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Events.onKeyDown <|
            Json.Decode.map KeyboardEvent decodeKeyboardEvent
        , cpuState GotCpuState
        ]



-- PORTS


port cpuState : (String -> msg) -> Sub msg


port cpuExecuteHexInstruction : String -> Cmd msg
