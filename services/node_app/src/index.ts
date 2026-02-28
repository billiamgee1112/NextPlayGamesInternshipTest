import express from 'express';

const app = express();

app.get('/', (req, res) => {
  res.json({ message: 'Hello from Node app' });
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Listening on ${port}`));
