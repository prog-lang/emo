module Editor exposing (Model, Msg(..), getText, init, update, view)

import Array exposing (Array)
import Html exposing (Html, code, div, pre, text)
import Html.Attributes exposing (style)


type Msg
    = Symbol Char
    | Enter


type alias Model =
    { lines : Array Line
    , line : Int
    , col : Int
    }


type alias Line =
    Array Char


init : Model
init =
    { lines = emptyLine |> List.singleton |> Array.fromList
    , line = 0
    , col = 0
    }


getText : Model -> String
getText model =
    model.lines
        |> Array.toList
        |> List.map lineToString
        |> String.concat


emptyLine : Line
emptyLine =
    Array.empty


lineToString : Line -> String
lineToString =
    Array.toList >> String.fromList >> (\string -> string ++ "\n")


view : Model -> List (Html msg)
view model =
    let
        leftPadding =
            model.lines
                |> Array.length
                |> String.fromInt
                |> String.length
                |> (+) 1

        lineNumbers =
            model.lines
                |> Array.length
                |> List.range 1
                |> List.map String.fromInt
                |> List.map (String.padLeft leftPadding ' ')
                |> List.map (\s -> s ++ " ")
                |> String.join "\n"

        listOfLines =
            model.lines
                |> Array.toList
                |> List.map (lineToString >> text)
    in
    div
        [ style "display" "flex"
        , style "height" "100vh"
        , style "overflow" "scroll"
        ]
        [ pre
            [ style "background-color" "#efefef"
            , style "margin-right" "5px"
            , style "min-height" "100%"
            , style "height" "max-content"
            ]
            [ code [] [ text lineNumbers ] ]
        , pre
            [ style "min-height" "100%"
            , style "height" "max-content"
            ]
            [ code [] listOfLines ]
        ]
        |> List.singleton


update : Msg -> Model -> Model
update msg model =
    case msg of
        Symbol char ->
            insert char model

        Enter ->
            { model
                | lines = Array.push emptyLine model.lines
                , line = model.line + 1
                , col = 0
            }


insert : Char -> Model -> Model
insert char model =
    let
        lastLineIndex =
            Array.length model.lines - 1

        newLastLine =
            model.lines
                |> Array.get lastLineIndex
                |> Maybe.withDefault emptyLine
                |> Array.push char
    in
    { model
        | lines = Array.set lastLineIndex newLastLine model.lines
        , col = model.col + 1
    }
