import mongoose from 'mongoose';

const notificationSchema = new mongoose.Schema({
  patientId: { type: String, required: true },
  title: { type: String, required: true },
  message: { type: String, required: true },
  timestamp: { type: Date, default: Date.now },
  isRead: { type: Boolean, default: false },
});

export const Notification = mongoose.model('Notification', notificationSchema); 