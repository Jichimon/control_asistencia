package com.example.control_asistencia.controllers.tasks;

import android.os.AsyncTask;

import com.example.control_asistencia.controllers.MainController;
import com.example.control_asistencia.models.Face;
import com.example.control_asistencia.models.UserImages;
import com.example.control_asistencia.services.DatabaseConnectionService;
import com.example.control_asistencia.services.ImageHandlerService;
import com.luxand.FSDK;

import java.util.ArrayList;

public class SetNewUserTemplates extends AsyncTask<UserImages, Integer, Integer> {

    //properties
    private final ImageHandlerService imageHandler = ImageHandlerService.getInstance();
    private final DatabaseConnectionService db = DatabaseConnectionService.getInstance(null);

    @Override
    protected Integer doInBackground(UserImages... userImages) {
        ArrayList<byte[]> images = userImages[0].getImages();
        int userId = userImages[0].getUserId();

        db.openWritable();
        for (byte[] eachImageData : images) {

            //HImage es la estructura de datos para imagenes con la que trabaja FaceSDK
            FSDK.HImage image = imageHandler.convertBytesBufferToHImage(eachImageData);
            FSDK.MirrorImage(image, false);

            FSDK.TFacePosition facePosition = detectFaceInHImage(image);
            if (facePosition == null) {
                FSDK.FreeImage(image);
                return MainController.NO_FACE_IN_THE_IMAGE;
            }

            FSDK.FSDK_FaceTemplate faceTemplate = getFaceTemplate(image, facePosition);
            if (faceTemplate == null) {
                FSDK.FreeImage(image);
                return MainController.CREATE_USER_ERROR;
            }

            // ya tenemos el template, creamos el Face y lo metemos a la Database
            Face newFace = new Face(userId, faceTemplate.template);
            int res = ((int) db.insertFaceToDB(newFace));
            if (res == MainController.CREATE_USER_ERROR) {
                FSDK.FreeImage(image);
                return res;
            }
            FSDK.FreeImage(image);
        }
        return MainController.SUCCESSFULLY_COMPLETED;
    }

    //metodos auxiliares

    private FSDK.TFacePosition detectFaceInHImage(FSDK.HImage image) {

        //Funcion que regula que la sensibilidad de la detección
        FSDK.SetFaceDetectionThreshold(5); //menor 1; mayor 5; 1-5;
        //20x20px es el tamaño minimo del face en la imagen para que el sdk lo detecte
        int internalResizeWidth = 512; //dimensionar la imagen a:
        FSDK.SetFaceDetectionParameters(false, false, internalResizeWidth);
        FSDK.TFacePosition facePosition = new FSDK.TFacePosition();
        int detectResponse = FSDK.DetectFace(image, facePosition);

        //handle response
        System.out.println("detect Face response_GetTemplateFromHImage: " + detectResponse);
        if (detectResponse == FSDK.FSDKE_OK) {
            return facePosition;
        }
        return null;
    }

    private FSDK.FSDK_FaceTemplate getFaceTemplate(FSDK.HImage image, FSDK.TFacePosition facePosition) {

        FSDK.FSDK_FaceTemplate faceTemplate = new FSDK.FSDK_FaceTemplate();
        //handle response
        if (facePosition != null) {
            //get template from the face already located
            int getTemplateResponse = FSDK.GetFaceTemplateInRegion(image, facePosition, faceTemplate);
            System.out.println("get Template Response_GetTemplateFromHImage: " + getTemplateResponse);
            if (getTemplateResponse == FSDK.FSDKE_OK) {
                return faceTemplate;
            }
        }
        return null;
    }
}
