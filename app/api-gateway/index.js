const express = require("express");
const httpProxy = require("http-proxy");
const config = require('./config');
const authMiddleware = require("./middlewares/authMiddleware");
const roleMiddleware = require("./middlewares/roleMiddleware");
const morgan = require('morgan');
const proxy = httpProxy.createProxyServer();
const app = express();

// Pass user info to services
proxy.on('proxyReq', function (proxyReq, req, _res, _options) {
  if (req.user) {
    proxyReq.setHeader('x-user', JSON.stringify(req.user));
  }
});

const APP_VERSION = process.env.APP_VERSION || "v1.0.0";
// Health check 

app.use(morgan((tokens, req, res) => {
    return JSON.stringify({
        method: tokens.method(req, res),
        url: tokens.url(req, res),
        status: tokens.status(req, res),
        responseTime: tokens.res(req, res, 'content-length'),
        time: tokens['response-time'](req, res) + 'ms',
        service: "api-gateway-service"
    });
}));

app.get('/apis/healthz', (req, res) => {
  const healthcheck = {
    version: APP_VERSION,
    podName: process.env.HOSTNAME,
    message: 'OK',
    uptime: process.uptime(),
    timestamp: Date.now(),
    service: 'api-gateway-service'
  };
  try {
    res.status(200).send(healthcheck);
  } catch (error) {
    res.status(503).send({ message: 'Service Unavailable' });
  }
});

app.use("/apis/auth", (req, res) => {
  proxy.web(req, res, { target: config.authUrl });
});

app.use("/apis/product/healthz", (req, res) => {
  proxy.web(req, res, { target: `${config.productUrl}/healthz` });
});

app.use("/apis/order/healthz", (req, res) => {
  proxy.web(req, res, { target: `${config.orderUrl}/healthz` });
});

// Route requests to the product service
// Allow both buyer and seller to view products
app.use("/apis/product/view", authMiddleware, (req, res) => {
  proxy.web(req, res, { target: `${config.productUrl}/view` });
});

// Allow only seller to update products
app.use("/apis/product", authMiddleware, roleMiddleware("seller"), (req, res) => {
  proxy.web(req, res, { target: config.productUrl });
});

// Route requests to the order service
// Allow only buyer to order
app.use("/apis/order", authMiddleware, roleMiddleware("buyer"), (req, res) => {
  proxy.web(req, res, { target: config.orderUrl });
});

const port = process.env.PORT || 5000;
app.listen(port, () => {
  console.log(`API Gateway listening on port ${port}`);
});