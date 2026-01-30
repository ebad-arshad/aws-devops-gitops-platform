const express = require("express");
const config = require("./config");
const ProductController = require("./controllers/productController");
const validateMiddleware = require("./middlewares/validateMiddleware");
const { createProductSchema, updateProductSchema } = require("./validators/productValidator");
const getUserMiddleware = require("./middlewares/getUserMiddleware");
const MessageBroker = require("./utils/messageBroker");

class App {
    constructor() {
        this.app = express();
        this.setupMessageBroker();
        this.setMiddlewares();
        this.productController = new ProductController();
        this.setRoutes();
    }

    start() {
        this.server = this.app.listen(config.port, () => console.log(`Product server listening on port ${config.port}`));
    }

    setupMessageBroker() {
        const messageBroker = new MessageBroker();
        messageBroker.connect();
    }

    setMiddlewares() {
        this.app.use(express.json());
    }

    setRoutes() {
        this.app.get("/healthz", (req, res) => {
            res.status(200).send({
                status: 'OK',
                service: 'product-service',
                uptime: process.uptime(),
                timestamp: Date.now()
            });
        });
        this.app.get("/view", (req, res) => this.productController.getProducts(req, res));
        this.app.get("/view/:id", (req, res) => this.productController.getProduct(req, res));

        this.app.post("/", getUserMiddleware, validateMiddleware(createProductSchema), (req, res) => this.productController.createProduct(req, res));
        this.app.put("/:id", getUserMiddleware, validateMiddleware(updateProductSchema), (req, res) => this.productController.updateProduct(req, res));
        this.app.delete("/:id", getUserMiddleware, (req, res) => this.productController.deleteProduct(req, res));
    }
}

module.exports = App;