const jwt = require("jsonwebtoken");

const verifyToken = (req, res, next) => {
    if (req.headers['Authorization'] || req.headers['authorization']) {
        const token = req.headers.authorization.split(' ')[1];

        try {
            const decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
            req.user = decoded.user;
        } catch (err) {
            return res.status(400).send("Invalid Token");
        }

        return next();
    }
    else return res.status(400).send('No token sent');
};

module.exports = verifyToken;