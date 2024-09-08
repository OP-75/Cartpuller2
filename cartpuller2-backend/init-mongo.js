// Initializes mongo collections & DB for docker
// Use the database you want to initialize
db = db.getSiblingDB('Cartpuller2');

// Create collections and insert initial data
db.createCollection('Active_Cartpullers');
db.createCollection('Active_Riders');
db.createCollection('Orders');
db.createCollection('Users');
db.createCollection('Vegetables');

db.Vegetables.insertMany([
  { "title": "Potato", "price": 7},
  { "title": "Avacado", "price": 108}
]);

//added later, check if it throws ant error
db.Orders.createIndex( { deliveryLocation : "2dsphere" } )
db.Active_Cartpullers.createIndex( { location : "2dsphere" } )
db.Active_Riders.createIndex( { location : "2dsphere" } )
