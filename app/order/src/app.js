const express = require("express");
const config = require("./config");
const validateMiddleware = require("./middlewares/validateMiddleware");
const getUserMiddleware = require("./middlewares/getUserMiddleware");
const OrderController = require("./controllers/orderController");
const { orderSchema } = require("./validators/orderValidator");
const MessageBroker = require("./utils/messageBroker");
const morgan = require('morgan');

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
        const messageBroker = new MessageBroker();
        messageBroker.connect();
    }

    setMiddlewares() {
        this.app.use(express.json());
    }

    setRoutes() {
        const APP_VERSION = process.env.APP_VERSION || "v1.0.0";
        this.app.use(morgan((tokens, req, res) => {
            return JSON.stringify({
                method: tokens.method(req, res),
                url: tokens.url(req, res),
                status: tokens.status(req, res),
                responseTime: tokens.res(req, res, 'content-length'),
                time: tokens['response-time'](req, res) + 'ms',
                service: "order-service"
            });
        }));
        this.app.get("/healthz", (req, res) => {
            res.status(200).send({
                version: APP_VERSION,
                podName: process.env.HOSTNAME,
                status: 'OK',
                service: 'order-service',
                uptime: process.uptime(),
                timestamp: Date.now()
            });
        });
        
        this.app.use(getUserMiddleware);
        
        this.app.get("/", (req, res) => this.orderController.getOrders(req, res));
        this.app.get("/:id", (req, res) => this.orderController.getOrder(req, res));
        this.app.post("/:productId", validateMiddleware(orderSchema), (req, res) => this.orderController.createOrder(req, res));
    }
}

module.exports = App;