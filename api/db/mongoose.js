require('dotenv').config();
const mongoose = require('mongoose');

const MONGODB_URI = process.env.MONGODB_URI;

if (!MONGODB_URI) {
  console.error('ERREUR: MONGODB_URI manquant dans le fichier .env');
  process.exit(1);
}

mongoose.Promise = global.Promise;

mongoose.connect(MONGODB_URI)
  .then(() => {
    console.log('Connecté à MongoDB avec succès :)');
  })
  .catch((e) => {
    console.error('Erreur de connexion à MongoDB :(');
    console.error(e);
    process.exit(1);
  });

mongoose.connection.on('disconnected', () => {
  console.warn('MongoDB déconnecté. Tentative de reconnexion...');
});

module.exports = { mongoose };