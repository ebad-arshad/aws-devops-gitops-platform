const express = require("express");
const config = require("./config");
const AuthController = require("./controllers/authController");

class App {
    constructor() {
        this.app = express();
        this.setMiddlewares();
        this.authController = new AuthController();
        this.setRoutes();
    }

    start() {
        this.server = this.app.listen(config.port, () => console.log(`Auth server listening on port ${config.port}`));
    }

    setMiddlewares() {
        this.app.use(express.json());
    }

    setRoutes() {
        this.app.post("/login", (req, res) => this.authController.login(req, res));
        this.app.post("/register", (req, res) => this.authController.register(req, res));
    }
}

module.exports = App;