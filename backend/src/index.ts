import express, { Express } from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import notificationsRouter from './routes/notifications';

const app: Express = express();
const PORT: number = process.env.PORT ? parseInt(process.env.PORT) : 80;
const MONGODB_URI: string = process.env.MONGODB_URI || 'mongodb://localhost:27017/health-monitoring';

app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

app.use(cors());
app.use(express.json());

app.use('/api/notifications', notificationsRouter);

mongoose.connect(MONGODB_URI)
  .then(() => {
    console.log('Connected to MongoDB');
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch((error: Error) => {
    console.error('MongoDB connection error:', error);
  }); 