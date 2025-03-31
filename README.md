# ✨About The Project



  This project combines the Shelf package and the Get It package.

    Shelf can be used with pure Dart to make it easier to create and compose web servers and parts of web servers.

    Get It is a simple service locator for Dart and Flutter projects with some additional extras heavily inspired by Splat.

    GetIt can be used instead of InheritedWidget or Provider to access objects, for example.

# 💻Typical usage:

    Accessing service objects, such as REST API clients or databases, so that they can be easily mocked by accessing

Views/AppModels/Managers/BLoCs from Flutter Views

# 👀Why GetIt?

    As your application grows, at some point you will need to put your application logic into classes that are separate from your Widgets.

     Avoiding widgets from having direct dependencies makes your code better organized and easier to test and maintain.

# 🛑Versions

## Flutter Version 3.16.5

## Dart Version Dart 3.2.3

### This is a project for study purposes.

# 🛑Running the sample

## Running with the Dart SDK

You can run the example with the [Dart SDK](https://dart.dev/get-dart)

like this:

    
    $ dart run bin/server.dart
    
    Server listening on port 3500
    
    
    
    
    ## Running with Docker
    
    
    
    If you have [Docker Desktop](https://www.docker.com/get-started) installed, you
    
    can build and run with the `docker` command:
    
    
    

$ docker build . -t myserver

$ docker run -it -p 8080:3500 myserver

Server listening on port 8080

    
    
    
    You should see the logging printed in the first terminal:
    

2021-05-06T15:47:04.620417  0:00:00.000158 GET     [200] /

2021-05-06T15:47:08.392928  0:00:00.001216 GET     [200] /echo/I_love_Dart

```