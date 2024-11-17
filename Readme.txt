Making any changes related to flutter_background_services requires u to stop the app and run/rebuild it again. Hot reload & Hot restart dont work with it

Start these services first for debug: MongoDB, redis, before starting server

To start redis:
Open WSL ubuntu terminal in VS code
sudo service redis-server start
redis-cli
flushall (inside redis cli)
monitor (inside redis cli)


Build backend (using docker):
1. Run maven clean & maven install commands in the cartpuller2-backend directory
2. docker compose up --build

Launch flutter apps in debug more or use `flutter build apk` to build an apk
Note: if there are any errors with flutter try `flutter clean` & `flutter run` cmds or use `flutter doctor` to see if flutter has all the dependencies installed
Note: App has been made & tested for android

Run ngrok reverse proxy after installation:
ngrok http --domain=insect-ready-minnow.ngrok-free.app 8080
(make sure to update the url in `constant.dart` in all 3 apps after running ngrok)
(replace the `--domain` link by you own ngrok static site)

Bug: Ngrok throttles the connections per minute so you might encounter an error while using the app

Order Flow:

SENT 
  -> ACCEPTED (Accepted by a cartpuller within 2km)
  -> RIDER_ASSIGNED (Rider is assigned within 4km, but order is not picked up by rider)
  -> DELIVERY_IN_PROGRESS (Rider has picked up the order from cartpuller; cartpuller is no longer involved in fulfilling the order)
  -> DELIVERED (Order has been delivered to the customer)

