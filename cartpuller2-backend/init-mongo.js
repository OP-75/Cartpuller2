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
