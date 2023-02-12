module Editor exposing (Model, Move(..), Msg(..), getText, init, update, view)

import Array exposing (Array)
import Html exposing (Html, code, div, pre, span, text)
import Html.Attributes exposing (style)


type Msg
    = Symbol Char
    | Enter
    | Move Move


type Move
    = Left
    | Right
    | Up
    | Down


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


lineToHtml : Int -> Line -> List (Html msg)
lineToHtml cursor =
    let
        background index =
            if index == cursor then
                [ style "background-color" "black"
                , style "color" "white"
                ]

            else
                [ style "background-color" "white" ]

        makeSpan index char =
            span (background index) [ char |> String.fromChar |> text ]
    in
    Array.push '\n'
        >> Array.indexedMap makeSpan
        >> Array.toList


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
                |> List.indexedMap
                    (\lineNumber line ->
                        lineToHtml
                            (if lineNumber == model.line then
                                model.col

                             else
                                -1
                            )
                            line
                    )
                |> List.concat
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

        -- TODO: at the moment, pressing Enter simply adds a new line at the
        -- very end of the file. Implement Enter behavious properly.
        Enter ->
            { model
                | lines = Array.push emptyLine model.lines
                , line = model.line + 1
                , col = 0
            }

        Move move ->
            updateOnMove move model


updateOnMove : Move -> Model -> Model
updateOnMove move model =
    let
        currentLine =
            Array.get model.line model.lines |> Maybe.withDefault emptyLine
    in
    case move of
        Left ->
            if model.col > 0 then
                { model | col = model.col - 1 }

            else
                model

        Right ->
            if model.col < Array.length currentLine then
                { model | col = model.col + 1 }

            else
                model

        Up ->
            if model.line > 0 then
                { model | line = model.line - 1 }

            else
                model

        Down ->
            if model.line < Array.length model.lines - 1 then
                { model | line = model.line + 1 }

            else
                model


insert : Char -> Model -> Model
insert char model =
    let
        currentLine =
            Array.get model.line model.lines |> Maybe.withDefault Array.empty

        lineAfterInsert =
            if model.col >= Array.length currentLine then
                Array.push char currentLine

            else
                Array.set model.col char currentLine
    in
    { model
        | lines = Array.set model.line lineAfterInsert model.lines
        , col = model.col + 1
    }
