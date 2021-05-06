package com.example.control_asistencia.services;

import android.app.IntentService;
import android.content.Intent;
import com.luxand.FSDK;

import androidx.annotation.Nullable;

public class FaceDetectionService extends IntentService {

    /*
    TODO: para optimizar la aplicación proximamente se desarrollará usando hilos de ejecución distintos para cada operacion atomica
     */

    public FaceDetectionService() {
        super("FaceDetectionService");
    }
    @Override
    protected void onHandleIntent(@Nullable Intent intent) {

        FSDK.Initialize();

    }
}
