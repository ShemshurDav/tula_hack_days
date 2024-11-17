"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const Notification_1 = require("../models/Notification");
const router = express_1.default.Router();
// Получение уведомлений для врача
router.get('/doctor', async (req, res) => {
    try {
        const notifications = await Notification_1.Notification.find()
            .sort({ timestamp: -1 })
            .limit(50);
        res.json(notifications);
    }
    catch (error) {
        res.status(500).json({ error: 'Ошибка получения уведомлений' });
    }
});
// Создание уведомления о пропуске приема лекарств
router.post('/missed-medications', async (req, res) => {
    try {
        const { patientId, medicationName, missedDays } = req.body;
        const notification = new Notification_1.Notification({
            patientId,
            title: 'Пропуск приема лекарств',
            message: `Пациент пропустил прием препарата ${medicationName}: ${missedDays.join(', ')}`,
        });
        await notification.save();
        res.status(201).json(notification);
    }
    catch (error) {
        res.status(500).json({ error: 'Ошибка создания уведомления' });
    }
});
// Создание уведомления о запросе приема
router.post('/appointment-request', async (req, res) => {
    try {
        const { patientId, reason } = req.body;
        const notification = new Notification_1.Notification({
            patientId,
            title: 'Запрос на прием',
            message: `Пациент запрашивает прием. Причина: ${reason}`,
        });
        await notification.save();
        res.status(201).json(notification);
    }
    catch (error) {
        res.status(500).json({ error: 'Ошибка создания уведомления' });
    }
});
exports.default = router;
