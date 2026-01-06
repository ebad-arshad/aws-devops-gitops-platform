const express = require("express");
const config = require("./config");
const validateMiddleware = require("./middlewares/validateMiddleware");
const getUserMiddleware = require("./middlewares/getUserMiddleware");
const OrderController = require("./controllers/orderController");
const { orderSchema } = require("./validators/orderValidator");
const messageBroker = require("./utils/messageBroker");

class App {
    constructor() {
        this.app = express();
        this.setupMessageBroker();
        this.setMiddlewares();
        this.orderController = new OrderController();
        this.setRoutes();
    }

    start() {
        this.server = this.app.listen(config.port, () => console.log(`Order server listening on port ${config.port}`));
    }

    setupMessageBroker() {
        messageBroker.connect();
    }

    setMiddlewares() {
        this.app.use(express.json());
        this.app.use(getUserMiddleware);
    }

    setRoutes() {
        this.app.get("/", (req, res) => this.orderController.getOrders(req, res));
        this.app.get("/:id", (req, res) => this.orderController.getOrder(req, res));
        this.app.post("/:productId", validateMiddleware(orderSchema), (req, res) => this.orderController.createOrder(req, res));
    }
}

module.exports = App;