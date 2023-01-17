port module Main exposing (main)

import Json.Decode
import Json.Encode
import Platform


type alias Request =
    { pathname : String
    , method : String
    }


type alias Header =
    ( String, String )


type alias Headers =
    List Header


type alias Status =
    Int


type alias Body =
    String


type alias Response =
    { status : Status
    , headers : Headers
    , body : Body
    }


type alias User =
    { id : String
    , email : String
    }


type alias Users =
    List User


type alias Model =
    ()


type Message
    = OnRequest String
    | OnGetUsers String


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Message )
init flags =
    ( (), Cmd.none )


port sendResponse : Response -> Cmd message


port onRequest : (String -> message) -> Sub message


port getUsers : () -> Cmd message


port onGetUsers : (String -> message) -> Sub message


requestDecoder : Json.Decode.Decoder Request
requestDecoder =
    Json.Decode.map2 Request
        (Json.Decode.field "pathname" Json.Decode.string)
        (Json.Decode.field "method" Json.Decode.string)


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map2 User
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)


usersDecoder : Json.Decode.Decoder Users
usersDecoder =
    Json.Decode.list userDecoder


userEncoder : User -> Json.Encode.Value
userEncoder user =
    Json.Encode.object
        [ ( "id", Json.Encode.string user.id )
        , ( "email", Json.Encode.string user.email )
        ]


usersEncoder : Users -> Json.Encode.Value
usersEncoder users =
    Json.Encode.list userEncoder users


encodeUsers : Users -> String
encodeUsers users =
    users
        |> usersEncoder
        |> Json.Encode.encode 0


response : Status -> Headers -> Body -> ( Flags, Cmd Message )
response status headers body =
    ( ()
    , sendResponse
        { status = status
        , headers = headers
        , body = body
        }
    )


fetchUsers : ( Flags, Cmd Message )
fetchUsers =
    ( (), getUsers () )


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        OnRequest request ->
            case Json.Decode.decodeString requestDecoder request of
                Ok decodedRequest ->
                    case [ decodedRequest.method, decodedRequest.pathname ] of
                        [ "GET", "/" ] ->
                            response 200 [ ( "Content-Type", "text/plain" ) ] "Hello, world!"

                        [ "GET", "/users" ] ->
                            fetchUsers

                        _ ->
                            response 404 [ ( "Content-Type", "text/plain" ) ] "Route not found"

                Err _ ->
                    response 500 [ ( "Content-Type", "text/plain" ) ] "Unexpected error"

        OnGetUsers users ->
            case Json.Decode.decodeString usersDecoder users of
                Ok decodedUsers ->
                    response 200 [ ( "Content-Type", "application/json" ) ] (encodeUsers decodedUsers)

                Err _ ->
                    response 500 [ ( "Content-Type", "text/plain" ) ] "Error while decoding users"


subscriptions : Flags -> Sub Message
subscriptions flags =
    Sub.batch
        [ onRequest OnRequest
        , onGetUsers OnGetUsers
        ]


main : Program Flags Model Message
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
