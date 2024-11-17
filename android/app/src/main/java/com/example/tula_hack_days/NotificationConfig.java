package com.example.tula_hack_days;

import android.graphics.Bitmap;
import androidx.core.app.NotificationCompat.BigPictureStyle;

public class NotificationConfig {
    public static BigPictureStyle setBigPicture(BigPictureStyle style, Bitmap bitmap) {
        return style.bigPicture(bitmap).bigLargeIcon((Bitmap) null);
    }
} 