const express = require('express');
const nodemailer = require('nodemailer');
const mySql = require('mysql2');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const cors = require('cors');

require('dotenv').config();
const auth = require("./middleware/auth")

//Setup multer
const upload = multer();

//DB connection
const sqlConnection = mySql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
});

sqlConnection.query('USE ' + process.env.DB_DATABASE, (err) => {
    if (err) return console.error(err.message);
    console.info(`Connected to database: ${process.env.DB_DATABASE}`);
});

//E-Mail setup
const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

const app = express();
app.use(express.json());
app.use(cors());

let codes = {};

// WELCOME ENDPOINT
app.get('/', async (req, res) => {
    res.status(200).send('<h1 style="text-align: center; color: orangered; padding-top: 2em; font-size: 70pt">Welcome to the Staccato API</h1>');
});

// LOGIN ENDPOINT
app.post('/user/login', async (req, res) => {
    console.log('POST => /user/login');

    const email = req.body['email'];
    const password = req.body['password'];

    sqlConnection.query('SELECT id, email, username, permission_level, password FROM user WHERE email = ?', [email], (err, result) => {
        if (err) {
            console.error(`ERROR while making request to DB:`);
            console.error(err);
            return res.status(500).send(err.message);
        }

        //Check if account exists
        if (result.length === 0) {
            console.error('No Account registered with this email found');
            return res.status(405).send('Account not found');
        }

        const user = result[0];

        //Check if password is correct
        bcrypt.compare(password, user.password, function (err, result) {
            if (err) return res.status(500).send('Error in Password Verification');
            if (result) {
                delete user['password'];
                // Password is correct
                // create JWT
                const token = jwt.sign({user}, process.env.ACCESS_TOKEN_SECRET, {expiresIn: 900}); // expires in 15 min
                // return JWT
                return res.status(200).send({
                    token,
                    user: {username: user.username, email: user.email, permission_level: user.permission_level}
                });
            } else {
                // Password is NOT correct
                return res.status(401).send('Password is incorrect');
            }
        });
    });
});

app.get('/profile_picture', auth, async (req, res) => {
    console.log('GET => /profile_picture');

    const email = req.user.email;

    sqlConnection.query("SELECT profile_picture FROM user where email = ?", [email], (err, results) => {
        if (err) {
            console.error('Error while inserting in DB: ');
            console.error(err);
            return res.status(500).send(err.message);
        }

        if (results.length === 0) {
            console.error('User not found');
            return res.status(405).send('Account not found');
        }

        const buffer = results[0]['profile_picture'];

        if (buffer === null) {
            console.log('User has no profile picture');
            return res.status(204).send('No Content');
        }

        console.log('Sending picture...');
        res.writeHead(200, {
            'Content-Type': 'image/jpg',
            'Content_Length': buffer.length,
        })
        res.end(buffer);
    });
});

// REGISTER ENDPOINT
app.post('/user', async (req, res) => {
    console.log('POST => /user');

    const username = req.body.username;
    const password = req.body.password;
    const email = req.body.email;
    const confirmationCode = req.body.code;

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = {
        username,
        email,
        permission_level: 1
    };

    if (confirmationCode === codes[email]) {
        //codes match
        sqlConnection.query('INSERT INTO user (username, email, password) VALUES (?, ?, ?)', [username, email, hashedPassword], (err) => {
            if (err) {
                console.error('Error while inserting in DB: ');
                console.error(err);
                return res.status(500).send('Database insert failed. Perhaps an account has already been registered with this email?');
            }

            console.log(`User '${username}' has been added to DB`);
            sqlConnection.query('SELECT id from user WHERE email = ?', [email], (err) => {
                if (err) {
                    console.error('Error while querying from DB: ');
                    console.error(err);
                    return res.status(500).send('Database request failed.');
                }

                delete codes[email];

                // create JWT
                const token = jwt.sign({user}, process.env.ACCESS_TOKEN_SECRET, {expiresIn: 900}); // expires in 15 min
                // return JWT
                return res.status(201).send({token, user});
            });
        });
    } else {
        //codes do not match
        console.error('Confirmation codes do not match');
        return res.status(300).send('Confirmation codes do not match');
    }
});

// DELETE USER
app.delete('/user', auth, async (req, res) => {
    console.log('DELETE => /user');

    sqlConnection.query('DELETE FROM user WHERE email = ?', [req.user.email], (err, result) => {
        if (err) {
            console.error('Error while deleting row from DB: ');
            console.error(err);
            return res.status(500).send(err.message);
        }

        //Check if account exists
        if (result.length === 0) {
            console.log('Email not found');
            return res.status(405).send('Account not found');
        }
        console.log(`User '${req.user.username}' successfully deleted`);

        res.status(200).send(`User successfully deleted`);
    });
});

// UPDATES USER DATA
app.put('/user', auth, async (req, res) => {
    console.log('PUT => /user');

    const username = req.body.username;
    const password = req.body.password;
    const email = req.body.email;
    const oldEmail = req.body['old_email'];

    const hashedPassword = bcrypt.hashSync(password, 10);
    sqlConnection.query('UPDATE user SET username = ?, password = ?,  email = ? WHERE email = ?', [username, hashedPassword, email, oldEmail], (err, result) => {
        if (err) {
            console.error('Error while updating row from DB: ');
            console.error(err);
            return res.status(500).send(err.message);
        }

        const user = {
            username,
            email,
            permission_level: req.user.permission_level
        };

        // create JWT
        const token = jwt.sign({user}, process.env.ACCESS_TOKEN_SECRET, {expiresIn: 900}); // expires in 15 min
        // return JWT
        res.status(201).send({token, user});
    });
});

// Creates Codes for Email verification?
app.post('/user/code', async (req, res) => {
    console.log('POST => /user/code');
    const email = req.body['email'];
    let searchedEmail;

    try {
        searchedEmail = await sqlConnection.promise().query('SELECT email FROM user WHERE email = ?', [email]);
    }
    catch (ex) {
        return res.status(500).send(ex.message);
    }

    if (searchedEmail[0].length > 0) {
        console.log('E-Mail already exists in the database');
        return res.status(409).send('Account already exists');
    }

    const min = 1;
    const max = 999999;
    const code = (Math.floor(Math.random() * (max - min)) + min).toString().padStart(6, '0');
    console.log(`The code for the user '${email}' is '${code}'`);

    //Save code for 5 minutes
    codes[email] = code;
    setTimeout((emailOfUser) => {
        delete codes[emailOfUser];
        console.log(`Confirmation code of user '${emailOfUser}' has been deleted`);
    }, 5 * 60 * 1000)

    //Send code via email
    const mailOptions = {
        from: 'noreply@foxel.at',
        to: email,
        subject: 'Staccato confirmation code',
        text: code
    }

    transporter.sendMail(mailOptions, (error, info) => {
        if (error) {
            console.error('Fehler beim Senden der E-Mail an ' + email + ':', error);
            res.status(514).send('Failed to send E-Mail');
        } else {
            console.log('E-Mail wurde an ' + email + ' gesendet: ' + info.response);
            res.status(227).send('Confirmation code sent');
        }
    })
});

// Sets updates User profile picture?
app.patch('/user/profile_picture', auth, upload.single('profile_picture'), async (req, res) => {
    console.log('PATCH => /user/profile_picture');

    const imageBuffer = req.file.buffer;

    sqlConnection.query('UPDATE user SET profile_picture = ? WHERE email = ?', [imageBuffer, req.user.email], (err) => {
        if (err) {
            console.error('Error while uploading profile-picture to DB: ');
            console.error(err);
            return res.status(500).send(err.message);
        }

        console.log('New profile picture has been saved to the database');
        res.status(204).send('Picture successfully saved');
    });
});

app.get('/audiofile', auth, async (req, res) => {
    console.log('GET => /audiofile');

    if (req.user.permission_level < 2) return res.status(401).send('Unauthorized for this endpoint. Need at least a permission level of 2.')

    sqlConnection.query('SELECT file, name, displayed_name from audiofile WHERE name = ? and user = ?', [req.body.name, req.user.id], (err, result) => {
        if (err) {
            console.error('Error while fetching userID: ');
            console.error(err);
            return res.status(500).send(err.message);
        }

        res.status(200).send({name: result[0].name, displayed_name: result[0].displayed_name, buffer: result[0].file});
    });
});

app.get('/audiofile/all', auth, async (req, res) => {
    console.log('GET => /audiofile/all');

    if (req.user.permission_level < 2) return res.status(401).send('Unauthorized for this endpoint. Need at least a permission level of 2.')

    sqlConnection.query('SELECT file, name, displayed_name, note_analysis_result from audiofile WHERE user = ?', [req.user.id], (err, result) => {
        if (err) {
            console.error('Error while fetching userID: ');
            console.error(err);
            return res.status(500).send(err.message);
        }

        let audios = [];
        for (const file of result) {
            audios.push({name: file.name, displayed_name: file.displayed_name, buffer: file.file,
                note_analysis_result: file.note_analysis_result});
        }

        res.status(200).send(audios);
    });
});

app.post('/audiofile', auth, upload.single('audio'), async (req, res) => {
    console.log('POST => /audiofile');

    if (req.user.permission_level < 2) return res.status(401).send('Unauthorized for this endpoint. Need at least a permission level of 2.')

    sqlConnection.query('SELECT id from user WHERE email = ?', [req.user.email], (err, result) => {
        if (err) {
            console.error('Error while fetching userID: ');
            console.error(err);
            return res.status(500).send(err.message);
        }

        const audio = JSON.parse(req.body.data).audioFile;
        const id = result[0].id;

        sqlConnection.query('INSERT INTO audiofile (name, user, displayed_name, note_analysis_result, accord_analysis_result, file) VALUES (?, ?, ?, ?, ?, ?)',
            [audio.fileName, id, audio.displayedName, JSON.stringify(audio.noteAnalysis), JSON.stringify(audio.accordAnalysis), req.file.buffer],
            (error) => {
                if (error) {
                    console.error('Error while updating audiofile: ');
                    console.error(error);
                    return res.status(500).send(error.message);
                }
                console.log('Audiofile has been updated');
                res.status(204).send('Audiofile successfully updated');
            });
    });
});

// Update Audiofile data
app.put('/audiofile', auth, async (req, res) => {
    console.log('PUT => /audio')

    if (req.user.permission_level < 2) return res.status(401).send('Unauthorized for this endpoint. Need at least a permission level of 2.');

    const audio = req.body.audioFile;

    sqlConnection.query('UPDATE audiofile SET displayed_name = ?, note_analysis_result = ?, accord_analysis_result = ? WHERE name = ?',
        [audio.displayedName, JSON.stringify(audio.noteAnalysis), JSON.stringify(audio.accordAnalysis), audio.fileName],
        (err) => {
            if (err) {
                console.error('Error while updating audiofile: ');
                console.error(err);
                return res.status(500).send(err.message);
            }

            console.log('Audiofile has been updated');
            res.status(200).send('Audiofile successfully updated');
        });
});

// Delete Audiofile
app.delete('/audiofile', auth, async (req, res) => {
    console.log('DELETE => /audio');

    if (req.user.permission_level < 2) return res.status(401).send('Unauthorized for this endpoint. Need at least a permission level of 2.');

    sqlConnection.query('DELETE from audiofile WHERE name = ?', [req.body.name], (err) => {
        if (err) {
            console.error('Error while deleting audiofile: ');
            console.error(err);
            return res.status(500).send(err.message);
        }

        console.log('Audiofile has been deleted');
        res.status(200).send('Audiofile successfully deleted');
    });
});

app.get('/ai', async (req, res) => {
    const options = {
        root: __dirname
    };

    const path = 'ai.h5';
    res.sendFile(path, options, (err) => {
        if (err) {
            console.error('Error while fetching AI: ');
            console.error(err);
        } else {
            console.log('Sent AI');
        }
    });
})

app.listen(process.env.PORT, () => console.log('Listening on ' + process.env.PORT));