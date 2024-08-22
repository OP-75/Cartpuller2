Making any changes related to flutter_background_services requires u to stop the app and run/rebuild it again. Hot reload & Hot restart dont work with it

Start these services first: MongoDB, redis, before starting server

Build backend:
docker compose up --build

Launch flutter apps in debug more or use `flutter build apk` to build an apk
Note: if there are any errors with flutter try `flutter clean` & `flutter run` cmds or use `flutter doctor` to see if flutter has all the dependencies installed
Note: App has been made & tested for android

Run ngrok reverse proxy after installation:
ngrok http --domain=insect-ready-minnow.ngrok-free.app 8080
(make sure to update the url in all 3 apps after running ngrok)
(replace the `--domain` link by you own ngrok static site)

Bug: Ngrok throttles the connections per minute so you might encounter an error while using the app
