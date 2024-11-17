import express, { Request, Response, Router } from 'express';
import { Notification } from '../models/Notification';

const router: Router = express.Router();

// Получение уведомлений для врача
router.get('/doctor', async (req: Request, res: Response) => {
  try {
    const notifications = await Notification.find()
      .sort({ timestamp: -1 })
      .limit(50);
    res.json(notifications);
  } catch (error) {
    res.status(500).json({ error: 'Ошибка получения уведомлений' });
  }
});

// Создание уведомления о пропуске приема лекарств
router.post('/missed-medications', async (req: Request, res: Response) => {
  try {
    const { patientId, medicationName, missedDays } = req.body;
    
    const notification = new Notification({
      patientId,
      title: 'Пропуск приема лекарств',
      message: `Пациент пропустил прием препарата ${medicationName}: ${missedDays.join(', ')}`,
    });
    
    await notification.save();
    res.status(201).json(notification);
  } catch (error) {
    res.status(500).json({ error: 'Ошибка создания уведомления' });
  }
});

// Создание уведомления о запросе приема
router.post('/appointment-request', async (req: Request, res: Response) => {
  try {
    const { patientId, reason } = req.body;
    
    const notification = new Notification({
      patientId,
      title: 'Запрос на прием',
      message: `Пациент запрашивает прием. Причина: ${reason}`,
    });
    
    await notification.save();
    res.status(201).json(notification);
  } catch (error) {
    res.status(500).json({ error: 'Ошибка создания уведомления' });
  }
});

export default router; 