require('dotenv').config();

const express = require('express');
const bodyParser = require('body-parser');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');

const { mongoose } = require('./db/mongoose');
const { Project } = require('./db/models/project.model');
const { Task } = require('./db/models/task.model');
const { User } = require('./db/models/user.model');

const app = express();
const PORT = process.env.PORT || 3000;
const FRONTEND_URL = process.env.FRONTEND_URL || 'http://localhost:3000';

// Sécurité de base 

app.use(helmet());// Ajoute des en-têtes HTTP de sécurité (XSS, clickjacking, etc.)

const limiter = rateLimit({// Limite les requêtes pour éviter les attaques par force brute
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200,
  message: { error: 'Trop de requêtes, veuillez réessayer dans 15 minutes.' },
});
app.use(limiter);

const authLimiter = rateLimit({// Limite plus stricte pour les routes d'authentification
  windowMs: 15 * 60 * 1000,
  max: 20,
  message: { error: 'Trop de tentatives de connexion, réessayez dans 15 minutes.' },
});

// CORS 

const corsOptions = process.env.NODE_ENV === 'development'
  ? {
      // tous les localhost peu importe le port
      origin: (origin, callback) => {
        if (!origin || origin.startsWith('http://localhost')) {
          callback(null, true);
        } else {
          callback(new Error('Non autorisé par CORS'));
        }
      },
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: [
        'Origin',
        'X-Requested-With',
        'Content-Type',
        'Accept',
        'x-access-token',
        'x-refresh-token',
        '_id',
      ],
      exposedHeaders: ['x-access-token', 'x-refresh-token'],
      credentials: true,
    }
  : {
      // En production : uniquement votre vrai domaine
      origin: process.env.FRONTEND_URL,
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: [
        'Origin',
        'X-Requested-With',
        'Content-Type',
        'Accept',
        'x-access-token',
        'x-refresh-token',
        '_id',
      ],
      exposedHeaders: ['x-access-token', 'x-refresh-token'],
      credentials: true,
    };

app.use(cors(corsOptions));

// Parsers 

app.use(bodyParser.json({ limit: '10kb' })); // Limite la taille des corps de requête
app.use(bodyParser.urlencoded({ extended: true, limit: '10kb' }));

// Middleware utilitaire 

// Retourne les erreurs de validation sous forme propre
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  next();
};

// Middleware d'authentification 

const authenticate = (req, res, next) => {
  const token = req.header('x-access-token');
  if (!token) {
    return res.status(401).send({ message: 'Aucun token fourni.' });
  }
  jwt.verify(token, User.getJWTSecret(), (err, decoded) => {
    if (err) {
      console.error('Échec de vérification du token:', err.message);
      return res.status(401).send({ message: 'Accès non autorisé' });
    }
    req.user_id = decoded._id;
    User.findById(req.user_id)
      .then((user) => {
        if (!user) {
          return res.status(404).send({ msg: 'Utilisateur non trouvé' });
        }
        req.user = user;
        next();
      })
      .catch(() => res.status(500).send({ msg: 'Erreur serveur' }));
  });
};

const authenticateAdmin = (req, res, next) => {
  const token = req.header('x-access-token');
  if (!token) {
    return res.status(401).send({ error: 'Aucun token fourni' });
  }
  jwt.verify(token, User.getJWTSecret(), (err, decoded) => {
    if (err) {
      return res.status(401).send({ error: 'Token invalide' });
    }
    if (decoded.role !== 'administrator') {
      return res.status(403).send({ error: 'Rôle non autorisé' });
    }
    req.user_id = decoded._id;
    req.role = decoded.role;
    next();
  });
};

const verifySession = (req, res, next) => {
  const refreshToken = req.header('x-refresh-token');
  const _id = req.header('_id');

  User.findByIdAndToken(_id, refreshToken)
    .then((user) => {
      if (!user) {
        return Promise.reject({
          error: 'Utilisateur non trouvé ou token invalide',
        });
      }
      req.user_id = user._id;
      req.userObject = user;
      req.refreshToken = refreshToken;

      let isSessionValid = false;
      user.sessions.forEach((session) => {
        if (session.token === refreshToken) {
          if (!User.hasRefreshTokenExpired(session.expireAt)) {
            isSessionValid = true;
          }
        }
      });

      if (isSessionValid) {
        next();
      } else {
        return Promise.reject({ error: 'Session expirée ou invalide' });
      }
    })
    .catch((e) => {
      res.status(401).send(e);
    });
};

// Règles de validation 

const projectValidation = [
  body('title')
    .notEmpty().withMessage('Le titre est obligatoire')
    .trim()
    .isLength({ min: 1, max: 200 }).withMessage('Le titre doit faire entre 1 et 200 caractères'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 2000 }).withMessage('La description ne peut pas dépasser 2000 caractères'),
];

const signupValidation = [
  body('name')
    .notEmpty().withMessage('Le nom est obligatoire')
    .trim()
    .isLength({ min: 2, max: 100 }),
  body('email')
    .isEmail().withMessage('Email invalide')
    .normalizeEmail(),
  body('password')
    .isLength({ min: 8 }).withMessage('Le mot de passe doit faire au moins 8 caractères'),
  body('role')
    .isIn(['developer', 'manager', 'administrator']).withMessage('Rôle invalide'),
];

const taskValidation = [
  body('title')
    .notEmpty().withMessage('Le titre est obligatoire')
    .trim()
    .isLength({ min: 1, max: 200 }),
  body('dueDate')
    .notEmpty().withMessage('La date d\'échéance est obligatoire')
    .isISO8601().withMessage('Format de date invalide'),
];

// Routes — Projets 

app.get('/projects', authenticate, async (req, res) => {
  try {
    const projects = await Project.find({ _userId: req.user_id })
      .populate('developers', 'name email role')
      .populate('manager', 'name email role');
    res.send(projects);
  } catch (e) {
    res.status(500).send({ error: 'Erreur lors de la récupération des projets' });
  }
});

app.post('/projects', authenticate, projectValidation, handleValidationErrors, async (req, res) => {
  try {
    const user = await User.findById(req.user_id);
    if (!user || !user.canCreateProject()) {
      return res.status(403).send({ message: "Vous n'avez pas la permission de créer des projets" });
    }

    const { title, description, developers, managerId } = req.body;
    let developerIds = [];
    if (Array.isArray(developers)) {
      developerIds = developers.map(dev => {
        // Si c'est déjà un string ID
        if (typeof dev === 'string') return dev;
        // Si c'est un objet avec _id
        if (dev._id) return dev._id;
        // Si c'est un objet avec idUtilisateur (venant du Flutter)
        if (dev.idUtilisateur) return dev.idUtilisateur;
        return null;
      }).filter(id => id !== null);
    }
    let manager = null;
    if (managerId) {
      manager = await User.findById(managerId);
      if (!manager || manager.role !== 'manager') {
        return res.status(400).send({ message: 'Manager invalide' });
      }
    }

    const newProject = new Project({
      title,
      description,
      developers: developers || [],
      manager: manager ? manager._id : user._id,
      _userId: req.user_id,
    });

    const projectDoc = await newProject.save();
    const populated = await projectDoc.populate([
      { path: 'developers', select: 'name email role' },
      { path: 'manager', select: 'name email role' },
    ]);
    res.status(201).send(populated);
  } catch (e) {
    console.error(e);
    res.status(500).send({ error: 'Erreur lors de la création du projet' });
  }
});

app.patch('/projects/:id', authenticate, async (req, res) => {
  try {
    const updated = await Project.findOneAndUpdate(
      { _id: req.params.id, _userId: req.user_id },
      { $set: req.body },
      { new: true }
    )
      .populate('developers', 'name email role')
      .populate('manager', 'name email role');

    if (!updated) {
      return res.status(404).send({ message: 'Projet non trouvé' });
    }
    res.send(updated);
  } catch (e) {
    res.status(500).send({ error: 'Erreur lors de la mise à jour du projet' });
  }
});

app.delete('/projects/:id', authenticate, async (req, res) => {
  try {
    const removedProject = await Project.findOneAndDelete({
      _id: req.params.id,
      _userId: req.user_id,
    });
    if (!removedProject) {
      return res.status(404).send({ message: 'Projet non trouvé' });
    }
    await deleteTasksFromProject(removedProject._id);
    res.send(removedProject);
  } catch (e) {
    res.status(500).send({ error: 'Erreur lors de la suppression du projet' });
  }
});

// Routes — Tâches 

app.get('/projects/:projectId/tasks', authenticate, async (req, res) => {
  try {
    const tasks = await Task.find({ projectId: req.params.projectId });
    res.send(tasks);
  } catch (e) {
    res.status(500).send({ error: 'Erreur lors de la récupération des tâches' });
  }
});

app.post(
  '/projects/:projectId/tasks',
  authenticate,
  taskValidation,
  handleValidationErrors,
  async (req, res) => {
    try {
      const project = await Project.findOne({
        _id: req.params.projectId,
        _userId: req.user_id,
      });
      if (!project) {
        return res.status(404).send({ message: 'Projet non trouvé ou accès refusé' });
      }

      const newTask = new Task({
        title: req.body.title,
        description: req.body.description || '',
        projectId: req.params.projectId,
        dueDate: req.body.dueDate,
        completed: false,
        developerNames: req.body.developerNames || [],
        subtasks: req.body.subtasks || [],
      });

      const savedTask = await newTask.save();
      res.status(201).send(savedTask);
    } catch (e) {
      console.error(e);
      res.status(500).send({ error: 'Erreur lors de la création de la tâche' });
    }
  }
);

app.patch('/projects/:projectId/tasks/:taskId', authenticate, async (req, res) => {
  try {
    const project = await Project.findOne({
      _id: req.params.projectId,
      _userId: req.user_id,
    });
    if (!project) return res.status(404).send({ message: 'Projet non trouvé' });

    await Task.findOneAndUpdate(
      { _id: req.params.taskId, projectId: req.params.projectId },
      { $set: req.body }
    );
    res.send({ message: 'Tâche mise à jour avec succès.' });
  } catch (e) {
    res.status(500).send({ error: 'Erreur lors de la mise à jour de la tâche' });
  }
});

app.delete('/projects/:projectId/tasks/:taskId', authenticate, async (req, res) => {
  try {
    const project = await Project.findOne({
      _id: req.params.projectId,
      _userId: req.user_id,
    });
    if (!project) return res.status(404).send({ message: 'Projet non trouvé' });

    const removed = await Task.findOneAndDelete({
      _id: req.params.taskId,
      projectId: req.params.projectId,
    });
    res.send(removed);
  } catch (e) {
    res.status(500).send({ error: 'Erreur lors de la suppression de la tâche' });
  }
});

// Routes — Utilisateurs

app.post('/users', signupValidation, handleValidationErrors, async (req, res) => {
  try {
    const existingUser = await User.findOne({ email: req.body.email });
    if (existingUser) {
      return res.status(400).send({ msg: 'Un compte avec cet email existe déjà' });
    }
    const newUser = new User(req.body);
    await newUser.save();
    const refreshToken = await newUser.createSession();
    const accessToken = await newUser.generateAccessAuthToken();

    res
      .header('x-refresh-token', refreshToken)
      .header('x-access-token', accessToken)
      .send(newUser);
  } catch (e) {
    res.status(400).send(e);
  }
});

app.post('/users/login', authLimiter, async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ msg: 'Email et mot de passe obligatoires' });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ msg: 'Identifiants incorrects' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Identifiants incorrects' });
    }

    const refreshToken = await user.createSession();
    const accessToken = await user.generateAccessAuthToken();

    res
      .header('x-refresh-token', refreshToken)
      .header('x-access-token', accessToken)
      .json({
        token: accessToken,
        user: {
          _id: user._id,
          name: user.name,
          email: user.email,
          role: user.role,
        },
      });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post(
  '/users/signup',
  authLimiter,
  signupValidation,
  handleValidationErrors,
  async (req, res) => {
    try {
      const { name, email, password, role } = req.body;

      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return res.status(400).json({ msg: 'Un compte avec cet email existe déjà' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      let user = new User({ email, password: hashedPassword, name, role });
      user = await user.save();

      const refreshToken = await user.createSession();
      const accessToken = await user.generateAccessAuthToken();

      res
        .header('x-refresh-token', refreshToken)
        .header('x-access-token', accessToken)
        .json(user);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  }
);

app.get('/users/me/access-token', verifySession, (req, res) => {
  req.userObject
    .generateAccessAuthToken()
    .then((accessToken) => {
      res.header('x-access-token', accessToken).send({ accessToken });
    })
    .catch((e) => {
      res.status(400).send(e);
    });
});

app.get('/users/pending-approval', authenticateAdmin, async (req, res) => {
  try {
    const pendingUsers = await User.findPendingUsers();
    res.status(200).send(pendingUsers);
  } catch (e) {
    res.status(500).send({ msg: 'Erreur lors de la récupération des utilisateurs en attente' });
  }
});

app.patch('/users/approve/:userId', authenticateAdmin, async (req, res) => {
  try {
    const updatedUser = await User.findByIdAndUpdate(
      req.params.userId,
      { isApproved: true },
      { new: true }
    );
    if (!updatedUser) {
      return res.status(404).send({ msg: 'Utilisateur non trouvé' });
    }
    res.status(200).send({ msg: 'Utilisateur approuvé', user: updatedUser });
  } catch (e) {
    res.status(500).send({ msg: 'Erreur lors de l\'approbation' });
  }
});

app.delete('/users/:id', authenticateAdmin, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).send({ msg: 'Utilisateur non trouvé' });
    }
    await User.findByIdAndDelete(req.params.id);
    res.status(200).send({ msg: 'Utilisateur supprimé avec succès' });
  } catch (e) {
    res.status(500).send({ error: 'Erreur lors de la suppression de l\'utilisateur' });
  }
});

// Routes — Développeurs & Managers 

app.get('/developers', async (req, res) => {
  try {
    const developers = await User.findDevelopers();
    res.send(developers);
  } catch (e) {
    res.status(500).send({ error: 'Erreur lors de la récupération des développeurs' });
  }
});

app.get('/managers', async (req, res) => {
  try {
    const managers = await User.findManagers();
    res.status(200).send(managers);
  } catch (e) {
    res.status(500).send({ msg: 'Erreur lors de la récupération des managers' });
  }
});

// Routes — Dashboard

app.get('/dashboard/projects', authenticate, async (req, res) => {
  try {
    const projects = await Project.aggregate([
      { $match: { _userId: req.user._id } },
      { $group: { _id: '$status', count: { $sum: 1 } } },
    ]);
    res.status(200).send(projects);
  } catch (e) {
    res.status(500).send({ msg: 'Erreur lors de la récupération du dashboard' });
  }
});

// Route de santé (health check) 

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
  });
});

// Gestion des routes inexistantes 

app.use((req, res) => {
  res.status(404).json({ error: 'Route non trouvée' });
});

// Gestion globale des erreurs 

app.use((err, req, res, next) => {
  console.error('Erreur non gérée:', err);
  res.status(500).json({ error: 'Erreur interne du serveur' });
});

// Fonctions utilitaires

const deleteTasksFromProject = async (projectId) => {
  try {
    await Task.deleteMany({ projectId });
    console.log(`Tâches du projet ${projectId} supprimées.`);
  } catch (e) {
    console.error(`Erreur suppression tâches du projet ${projectId}`, e);
  }
};

//Démarrage du serveur 

app.listen(PORT, () => {
  console.log(`Serveur démarré sur le port ${PORT} en mode ${process.env.NODE_ENV}`);
});